-- Migration: 08_fix_comselec_workspace_retrieval.sql
-- Description: Fix get_my_workspaces() to include COMSELECs and backfill existing student voters into comselec_members

-- 1. Redefine get_my_workspaces() RPC to return COMSELECs
CREATE OR REPLACE FUNCTION public.get_my_workspaces()
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    code VARCHAR,
    type VARCHAR,
    logo_url VARCHAR,
    banner_url VARCHAR,
    status VARCHAR,
    campus_id UUID,
    faculty_id UUID,
    program_id UUID
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT public.get_my_id() INTO v_user_id;
    IF v_user_id IS NULL THEN
        RETURN;
    END IF;

    -- 1. Organizations (School-based, Campus-based, Faculty-based, Program-based)
    RETURN QUERY
    SELECT DISTINCT
        o.id,
        o.name,
        o.code,
        o.type::VARCHAR,
        o.logo_url,
        o.banner_url,
        o.status,
        o.campus_id,
        o.faculty_id,
        o.program_id
    FROM public.organizations o
    JOIN public.organization_members om ON o.id = om.organization_id
    WHERE om.user_id = v_user_id 
      AND om.status = 'active'
      AND (om.expired_at IS NULL OR om.expired_at > CURRENT_TIMESTAMP);

    -- 2. Faculty Workspaces (where user is Dean)
    RETURN QUERY
    SELECT 
        f.id,
        f.name,
        f.code,
        'faculty'::VARCHAR AS type,
        f.logo_url,
        f.banner_url,
        'active'::VARCHAR AS status,
        f.campus_id,
        f.id AS faculty_id,
        NULL::UUID AS program_id
    FROM public.faculties f
    WHERE f.dean_id = v_user_id;

    -- 3. Program Workspaces (where user is Program Head)
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.code,
        'program'::VARCHAR AS type,
        p.logo_url,
        p.banner_url,
        'active'::VARCHAR AS status,
        f.campus_id,
        p.faculty_id,
        p.id AS program_id
    FROM public.programs p
    JOIN public.faculties f ON p.faculty_id = f.id
    WHERE p.program_head_id = v_user_id;

    -- 4. COMSELEC Workspaces (where user is an active member/voter)
    RETURN QUERY
    SELECT DISTINCT
        c.id,
        c.name,
        c.code,
        'comselec'::VARCHAR AS type,
        c.logo_url,
        c.banner_url,
        c.status,
        c.campus_id,
        NULL::UUID AS faculty_id,
        NULL::UUID AS program_id
    FROM public.comselecs c
    JOIN public.comselec_members cm ON c.id = cm.comselec_id
    WHERE cm.user_id = v_user_id 
      AND cm.status = 'active'
      AND (cm.expired_at IS NULL OR cm.expired_at > CURRENT_TIMESTAMP);
END;
$$;

-- 2. Ensure all comselec_members are set to active
UPDATE public.comselec_members SET status = 'active' WHERE status IS NULL OR status != 'active';

-- 3. Backfill student voters for all existing COMSELECs safely without relying on a specific ON CONFLICT target
DO $$
DECLARE
    v_voter_role_id UUID;
    c RECORD;
BEGIN
    SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Voters' LIMIT 1;
    IF v_voter_role_id IS NULL THEN
        SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Students' LIMIT 1;
    END IF;

    FOR c IN SELECT id, school_id, campus_id, COALESCE(type, 'campus-based') AS type FROM public.comselecs LOOP
        IF c.type = 'school-based' THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id, status)
            SELECT DISTINCT c.id, u.id, v_voter_role_id, 'active'
            FROM public.users u
            LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
            LEFT JOIN public.roles ro ON ur.role_id = ro.id
            WHERE (
                c.school_id IS NULL 
                OR u.school_id = c.school_id 
                OR u.school_id IS NULL
                OR u.campus_id IN (SELECT id FROM public.campuses WHERE school_id = c.school_id OR school_id IS NULL)
            )
              AND (ro.name IS NULL OR ro.name IN ('Students', 'Student', 'Voters', 'Member'))
              AND (u.account_status IS NULL OR u.account_status != 'deleted')
              AND NOT EXISTS (
                  SELECT 1 FROM public.user_roles ur2
                  JOIN public.roles r2 ON ur2.role_id = r2.id
                  WHERE ur2.user_id = u.id
                    AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                    AND ur2.is_active = true
              )
              AND NOT EXISTS (
                  SELECT 1 FROM public.comselec_members cm_ex
                  WHERE cm_ex.comselec_id = c.id AND cm_ex.user_id = u.id
              )
            ON CONFLICT DO NOTHING;

        ELSIF c.type = 'campus-based' THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id, status)
            SELECT DISTINCT c.id, u.id, v_voter_role_id, 'active'
            FROM public.users u
            LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
            LEFT JOIN public.roles ro ON ur.role_id = ro.id
            WHERE (
                c.campus_id IS NULL
                OR u.campus_id = c.campus_id
                OR u.campus_id IS NULL
                OR u.program_id IN (
                    SELECT pr.id FROM public.programs pr 
                    JOIN public.faculties fa ON pr.faculty_id = fa.id 
                    WHERE fa.campus_id = c.campus_id
                )
            )
              AND (ro.name IS NULL OR ro.name IN ('Students', 'Student', 'Voters', 'Member'))
              AND (u.account_status IS NULL OR u.account_status != 'deleted')
              AND NOT EXISTS (
                  SELECT 1 FROM public.user_roles ur2
                  JOIN public.roles r2 ON ur2.role_id = r2.id
                  WHERE ur2.user_id = u.id
                    AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                    AND ur2.is_active = true
              )
              AND NOT EXISTS (
                  SELECT 1 FROM public.comselec_members cm_ex
                  WHERE cm_ex.comselec_id = c.id AND cm_ex.user_id = u.id
              )
            ON CONFLICT DO NOTHING;
        END IF;
    END LOOP;
END $$;
