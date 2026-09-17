-- Migration: 07_schools_schema.sql
-- Description: Create schools table, add RLS select policies, and link school_id foreign keys

CREATE TABLE IF NOT EXISTS public.schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    logo_url VARCHAR(2048),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS and add public read access policy
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to schools" ON public.schools;
CREATE POLICY "Allow public read access to schools" 
ON public.schools FOR SELECT 
USING (true);

DROP POLICY IF EXISTS "Super admins can manage schools" ON public.schools;
CREATE POLICY "Super admins can manage schools" 
ON public.schools FOR ALL 
TO authenticated 
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

-- Seed default university/school
INSERT INTO public.schools (name, code, description)
VALUES ('Davao Oriental State University', 'DORSU', 'Main University System')
ON CONFLICT (code) DO NOTHING;

-- Add school_id foreign key references
ALTER TABLE public.campuses ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES public.schools(id) ON DELETE SET NULL;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES public.schools(id) ON DELETE SET NULL;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES public.schools(id) ON DELETE SET NULL;

-- Link existing campuses, users, and organizations to default school
UPDATE public.campuses 
SET school_id = (SELECT id FROM public.schools WHERE code = 'DORSU' LIMIT 1)
WHERE school_id IS NULL;

UPDATE public.users 
SET school_id = (SELECT id FROM public.schools WHERE code = 'DORSU' LIMIT 1)
WHERE school_id IS NULL;

UPDATE public.organizations 
SET school_id = (SELECT id FROM public.schools WHERE code = 'DORSU' LIMIT 1)
WHERE school_id IS NULL;

-- 5. Update create_organization_with_members() RPC to support p_school_id
DROP FUNCTION IF EXISTS public.create_organization_with_members(TEXT, TEXT, TEXT, TEXT, UUID, UUID, UUID[], TEXT, TEXT);
DROP FUNCTION IF EXISTS public.create_organization_with_members(TEXT, TEXT, TEXT, TEXT, UUID, UUID, UUID[], TEXT, TEXT, UUID);

CREATE OR REPLACE FUNCTION public.create_organization_with_members(
    p_name TEXT,
    p_code TEXT,
    p_description TEXT,
    p_type TEXT,
    p_campus_id UUID DEFAULT NULL,
    p_faculty_id UUID DEFAULT NULL,
    p_program_ids UUID[] DEFAULT '{}',
    p_logo_url TEXT DEFAULT NULL,
    p_banner_url TEXT DEFAULT NULL,
    p_school_id UUID DEFAULT NULL
) RETURNS UUID 
SET search_path = public, pg_temp
AS $$
DECLARE
    v_org_id UUID;
    v_primary_program_id UUID;
    v_effective_school_id UUID;
    v_member_role_id UUID;
BEGIN
    IF NOT public.is_super_admin() THEN
        RAISE EXCEPTION 'Access denied: only Super Admins can create organizations.';
    END IF;

    IF p_program_ids IS NOT NULL AND array_length(p_program_ids, 1) > 0 THEN
        v_primary_program_id := p_program_ids[1];
    ELSE
        v_primary_program_id := NULL;
    END IF;

    v_effective_school_id := p_school_id;
    IF v_effective_school_id IS NULL THEN
        SELECT id INTO v_effective_school_id FROM public.schools WHERE code = 'DORSU' LIMIT 1;
    END IF;

    -- Fetch default Member role ID safely
    SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Member' LIMIT 1;
    IF v_member_role_id IS NULL THEN
        SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Students' LIMIT 1;
    END IF;

    INSERT INTO organizations (name, code, description, type, campus_id, faculty_id, program_id, logo_url, banner_url, school_id)
    VALUES (p_name, p_code, p_description, p_type, p_campus_id, p_faculty_id, v_primary_program_id, p_logo_url, p_banner_url, v_effective_school_id)
    RETURNING id INTO v_org_id;

    IF p_type = 'school-based' THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT DISTINCT v_org_id, u.id, v_member_role_id
        FROM public.users u
        LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
        LEFT JOIN public.roles r ON ur.role_id = r.id
        WHERE (
            v_effective_school_id IS NULL 
            OR u.school_id = v_effective_school_id 
            OR u.school_id IS NULL
            OR u.campus_id IN (SELECT id FROM public.campuses WHERE school_id = v_effective_school_id OR school_id IS NULL)
        )
          AND (r.name IS NULL OR r.name IN ('Students', 'Student', 'Voters', 'Member'))
          AND (u.account_status IS NULL OR u.account_status != 'deleted')
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur2
              JOIN public.roles r2 ON ur2.role_id = r2.id
              WHERE ur2.user_id = u.id
                AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                AND ur2.is_active = true
          )
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'campus-based' AND p_campus_id IS NOT NULL THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT DISTINCT v_org_id, u.id, v_member_role_id
        FROM public.users u
        LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
        LEFT JOIN public.roles r ON ur.role_id = r.id
        WHERE u.campus_id = p_campus_id
          AND (r.name IS NULL OR r.name IN ('Students', 'Student', 'Voters', 'Member'))
          AND (u.account_status IS NULL OR u.account_status != 'deleted')
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur2
              JOIN public.roles r2 ON ur2.role_id = r2.id
              WHERE ur2.user_id = u.id
                AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                AND ur2.is_active = true
          )
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'faculty-based' AND p_faculty_id IS NOT NULL THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT DISTINCT v_org_id, u.id, v_member_role_id
        FROM public.users u
        LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
        LEFT JOIN public.roles r ON ur.role_id = r.id
        WHERE u.faculty_id = p_faculty_id
          AND (r.name IS NULL OR r.name IN ('Students', 'Student', 'Voters', 'Member'))
          AND (u.account_status IS NULL OR u.account_status != 'deleted')
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur2
              JOIN public.roles r2 ON ur2.role_id = r2.id
              WHERE ur2.user_id = u.id
                AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                AND ur2.is_active = true
          )
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'program-based' AND p_program_ids IS NOT NULL AND array_length(p_program_ids, 1) > 0 THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT DISTINCT v_org_id, u.id, v_member_role_id
        FROM public.users u
        LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
        LEFT JOIN public.roles r ON ur.role_id = r.id
        WHERE u.program_id = ANY(p_program_ids)
          AND (r.name IS NULL OR r.name IN ('Students', 'Student', 'Voters', 'Member'))
          AND (u.account_status IS NULL OR u.account_status != 'deleted')
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur2
              JOIN public.roles r2 ON ur2.role_id = r2.id
              WHERE ur2.user_id = u.id
                AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                AND ur2.is_active = true
          )
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN v_org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Update handle_new_user() trigger function to extract school_uuid and auto-member
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger 
SET search_path = public, pg_temp
AS $$
DECLARE
    new_user_id UUID;
    target_role_id UUID;
    v_role TEXT;
    v_position TEXT;
    v_scope_type public.scope_type;
    v_scope_id UUID;
    v_school_id UUID;
    v_faculty_id UUID;
    v_program_id UUID;
    v_campus_id UUID;
    v_auto_activate BOOLEAN := false;
BEGIN
    v_role := new.raw_user_meta_data->>'role';
    v_position := new.raw_user_meta_data->>'position';

    IF v_role IN ('super_admin', 'comselec_chairman', 'comselec_chair', 'comselec_commissioner', 'faculty') THEN
        v_role := 'student';
    END IF;
    v_school_id := (NULLIF(new.raw_user_meta_data->>'school_uuid', ''))::uuid;
    v_campus_id := (NULLIF(new.raw_user_meta_data->>'campus_id', ''))::uuid;
    v_faculty_id := (NULLIF(new.raw_user_meta_data->>'faculty_id', ''))::uuid;
    v_program_id := (NULLIF(new.raw_user_meta_data->>'program_id', ''))::uuid;

    BEGIN
        SELECT COALESCE((value->>'enabled')::boolean, false) INTO v_auto_activate
        FROM public.system_settings
        WHERE key = 'auto_activate_registrations';
    EXCEPTION WHEN OTHERS THEN
        v_auto_activate := false;
    END;

    IF v_campus_id IS NULL AND v_faculty_id IS NOT NULL THEN
        SELECT campus_id INTO v_campus_id FROM public.faculties WHERE id = v_faculty_id;
    END IF;

    IF v_school_id IS NULL AND v_campus_id IS NOT NULL THEN
        SELECT school_id INTO v_school_id FROM public.campuses WHERE id = v_campus_id;
    END IF;

    IF v_school_id IS NULL THEN
        SELECT id INTO v_school_id FROM public.schools WHERE code = 'DORSU' LIMIT 1;
    END IF;

    INSERT INTO public.users (
        auth_id, email, first_name, last_name, student_id_number, 
        school_id, campus_id, faculty_id, program_id, year, account_status
    )
    VALUES (
        new.id, new.email, 
        COALESCE(new.raw_user_meta_data->>'first_name', ''),
        COALESCE(new.raw_user_meta_data->>'last_name', ''), 
        COALESCE(NULLIF(new.raw_user_meta_data->>'school_id', ''), NULLIF(new.raw_user_meta_data->>'student_id_number', ''), 'PENDING-' || substr(new.id::text, 1, 8)),
        v_school_id, v_campus_id, v_faculty_id, v_program_id,
        (NULLIF(new.raw_user_meta_data->>'year_level', ''))::int,
        CASE 
            WHEN v_auto_activate THEN 'active'
            ELSE COALESCE(new.raw_user_meta_data->>'status', 'pending')
        END
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        school_id = EXCLUDED.school_id,
        campus_id = EXCLUDED.campus_id,
        faculty_id = EXCLUDED.faculty_id,
        program_id = EXCLUDED.program_id,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO new_user_id;

    IF v_role = 'super_admin' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Super Admin';
        v_scope_type := 'Institutional';
        v_scope_id := '00000000-0000-0000-0000-000000000000';
    ELSIF v_role = 'student' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Students';
        v_scope_type := 'Program';
        v_scope_id := v_program_id;
    ELSIF v_role = 'voter' OR v_role = 'voters' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Voters';
        v_scope_type := 'Program';
        v_scope_id := v_program_id;
    ELSIF v_role = 'personnel' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Personnel';
        v_scope_type := 'Faculty';
        v_scope_id := v_faculty_id;
    ELSIF v_role = 'comselec_chairman' OR v_role = 'comselec_chair' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Comselec Chair';
        v_scope_type := 'Institutional';
        v_scope_id := COALESCE(v_campus_id, '00000000-0000-0000-0000-000000000000'::uuid);
    ELSIF v_role = 'comselec_commissioner' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Comselec Commissioner';
        v_scope_type := 'Institutional';
        v_scope_id := COALESCE(v_campus_id, '00000000-0000-0000-0000-000000000000'::uuid);
    ELSE
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Students';
        v_scope_type := 'Program';
        v_scope_id := v_program_id;
    END IF;

    IF target_role_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id, is_active)
        VALUES (new_user_id, target_role_id, v_scope_type, v_scope_id, true)
        ON CONFLICT (user_id, role_id, scope_type, scope_id) DO NOTHING;
    END IF;

    -- Auto-assign new student user to existing organizations
    IF v_role = 'student' OR target_role_id = (SELECT id FROM public.roles WHERE name = 'Students' LIMIT 1) THEN
        IF v_school_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, COALESCE((SELECT id FROM public.roles WHERE name = 'Member' LIMIT 1), (SELECT id FROM public.roles WHERE name = 'Students' LIMIT 1))
            FROM public.organizations 
            WHERE type = 'school-based' AND (school_id = v_school_id OR school_id IS NULL)
            ON CONFLICT DO NOTHING;
        END IF;

        IF v_campus_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, COALESCE((SELECT id FROM public.roles WHERE name = 'Member' LIMIT 1), (SELECT id FROM public.roles WHERE name = 'Students' LIMIT 1))
            FROM public.organizations 
            WHERE type = 'campus-based' AND campus_id = v_campus_id
            ON CONFLICT DO NOTHING;
        END IF;

        IF v_faculty_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, COALESCE((SELECT id FROM public.roles WHERE name = 'Member' LIMIT 1), (SELECT id FROM public.roles WHERE name = 'Students' LIMIT 1))
            FROM public.organizations 
            WHERE type = 'faculty-based' AND faculty_id = v_faculty_id
            ON CONFLICT DO NOTHING;
        END IF;

        IF v_program_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, COALESCE((SELECT id FROM public.roles WHERE name = 'Member' LIMIT 1), (SELECT id FROM public.roles WHERE name = 'Students' LIMIT 1))
            FROM public.organizations 
            WHERE type = 'program-based' AND program_id = v_program_id
            ON CONFLICT DO NOTHING;
        END IF;

        -- Auto-assign student as Voter in COMSELECs
        IF v_school_id IS NOT NULL THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id)
            SELECT id, new_user_id, COALESCE((SELECT id FROM public.roles WHERE name = 'Voters' LIMIT 1), (SELECT id FROM public.roles WHERE name = 'Students' LIMIT 1))
            FROM public.comselecs 
            WHERE type = 'school-based' AND (school_id = v_school_id OR school_id IS NULL)
            ON CONFLICT DO NOTHING;
        END IF;

        IF v_campus_id IS NOT NULL THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id)
            SELECT id, new_user_id, COALESCE((SELECT id FROM public.roles WHERE name = 'Voters' LIMIT 1), (SELECT id FROM public.roles WHERE name = 'Students' LIMIT 1))
            FROM public.comselecs 
            WHERE (type = 'campus-based' OR type IS NULL) AND campus_id = v_campus_id
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Backfill existing school-based organizations with student members
DO $$
DECLARE
    v_member_role_id UUID;
    r RECORD;
BEGIN
    SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Member' LIMIT 1;
    IF v_member_role_id IS NULL THEN
        SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Students' LIMIT 1;
    END IF;

    FOR r IN SELECT id, school_id FROM public.organizations WHERE type = 'school-based' LOOP
        INSERT INTO public.organization_members (organization_id, user_id, role_id)
        SELECT DISTINCT r.id, u.id, v_member_role_id
        FROM public.users u
        LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
        LEFT JOIN public.roles ro ON ur.role_id = r.id
        WHERE (
            r.school_id IS NULL 
            OR u.school_id = r.school_id 
            OR u.school_id IS NULL
            OR u.campus_id IN (SELECT id FROM public.campuses WHERE school_id = r.school_id OR school_id IS NULL)
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
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- 8. COMSELEC School-Based Support & Auto-Voters RPC
ALTER TABLE public.comselecs ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES public.schools(id) ON DELETE SET NULL;
ALTER TABLE public.comselecs ADD COLUMN IF NOT EXISTS type VARCHAR(50) DEFAULT 'campus-based';

DROP FUNCTION IF EXISTS public.create_comselec_with_members(TEXT, TEXT, TEXT, UUID, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.create_comselec_with_members(TEXT, TEXT, TEXT, UUID, TEXT, TEXT, TEXT, UUID);

CREATE OR REPLACE FUNCTION public.create_comselec_with_members(
    p_name TEXT,
    p_code TEXT,
    p_description TEXT,
    p_campus_id UUID DEFAULT NULL,
    p_logo_url TEXT DEFAULT NULL,
    p_banner_url TEXT DEFAULT NULL,
    p_type TEXT DEFAULT 'campus-based',
    p_school_id UUID DEFAULT NULL
) RETURNS UUID 
SET search_path = public, pg_temp
AS $$
DECLARE
    v_comselec_id UUID;
    v_effective_school_id UUID;
    v_voter_role_id UUID;
BEGIN
    IF NOT public.is_super_admin() THEN
        RAISE EXCEPTION 'Access denied: only Super Admins can create COMSELECs.';
    END IF;

    v_effective_school_id := p_school_id;
    IF v_effective_school_id IS NULL AND p_type = 'school-based' THEN
        SELECT id INTO v_effective_school_id FROM public.schools WHERE code = 'DORSU' LIMIT 1;
    END IF;

    -- Fetch default Voter role ID safely
    SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Voters' LIMIT 1;
    IF v_voter_role_id IS NULL THEN
        SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Students' LIMIT 1;
    END IF;

    INSERT INTO comselecs (name, code, description, type, campus_id, school_id, logo_url, banner_url)
    VALUES (p_name, p_code, p_description, p_type, p_campus_id, v_effective_school_id, p_logo_url, p_banner_url)
    RETURNING id INTO v_comselec_id;

    -- Automatically assign comselec chair and commissioners from user_roles
    INSERT INTO comselec_members (comselec_id, user_id, role_id)
    SELECT DISTINCT v_comselec_id, ur.user_id, ur.role_id
    FROM public.user_roles ur
    JOIN public.roles r ON ur.role_id = r.id
    WHERE r.name IN ('Comselec Chair', 'Comselec Commissioner', 'COMSELEC Commissioner')
      AND (
          (p_type = 'campus-based' AND ur.scope_id = p_campus_id)
          OR (p_type = 'school-based' AND (ur.scope_id = v_effective_school_id OR ur.scope_type = 'Institutional'))
      )
      AND ur.is_active = true
    ON CONFLICT DO NOTHING;

    -- Auto-assign student voters into comselec_members
    IF p_type = 'school-based' THEN
        INSERT INTO comselec_members (comselec_id, user_id, role_id)
        SELECT DISTINCT v_comselec_id, u.id, v_voter_role_id
        FROM public.users u
        LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
        LEFT JOIN public.roles r ON ur.role_id = r.id
        WHERE (
            v_effective_school_id IS NULL 
            OR u.school_id = v_effective_school_id 
            OR u.school_id IS NULL
            OR u.campus_id IN (SELECT id FROM public.campuses WHERE school_id = v_effective_school_id OR school_id IS NULL)
        )
          AND (r.name IS NULL OR r.name IN ('Students', 'Student', 'Voters', 'Member'))
          AND (u.account_status IS NULL OR u.account_status != 'deleted')
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur2
              JOIN public.roles r2 ON ur2.role_id = r2.id
              WHERE ur2.user_id = u.id
                AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                AND ur2.is_active = true
          )
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'campus-based' AND p_campus_id IS NOT NULL THEN
        INSERT INTO comselec_members (comselec_id, user_id, role_id)
        SELECT DISTINCT v_comselec_id, u.id, v_voter_role_id
        FROM public.users u
        LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
        LEFT JOIN public.roles r ON ur.role_id = r.id
        WHERE u.campus_id = p_campus_id
          AND (r.name IS NULL OR r.name IN ('Students', 'Student', 'Voters', 'Member'))
          AND (u.account_status IS NULL OR u.account_status != 'deleted')
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur2
              JOIN public.roles r2 ON ur2.role_id = r2.id
              WHERE ur2.user_id = u.id
                AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                AND ur2.is_active = true
          )
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN v_comselec_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Backfill existing COMSELECs with student voters
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
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id)
            SELECT DISTINCT c.id, u.id, v_voter_role_id
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
            ON CONFLICT DO NOTHING;
        ELSIF c.campus_id IS NOT NULL THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id)
            SELECT DISTINCT c.id, u.id, v_voter_role_id
            FROM public.users u
            LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
            LEFT JOIN public.roles ro ON ur.role_id = ro.id
            WHERE u.campus_id = c.campus_id
              AND (ro.name IS NULL OR ro.name IN ('Students', 'Student', 'Voters', 'Member'))
              AND (u.account_status IS NULL OR u.account_status != 'deleted')
              AND NOT EXISTS (
                  SELECT 1 FROM public.user_roles ur2
                  JOIN public.roles r2 ON ur2.role_id = r2.id
                  WHERE ur2.user_id = u.id
                    AND r2.name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Comselec Chair', 'Comselec Commissioner')
                    AND ur2.is_active = true
              )
            ON CONFLICT DO NOTHING;
        END IF;
    END LOOP;
END $$;





