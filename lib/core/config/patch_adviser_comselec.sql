-- ==============================================================================
-- VOUCH DB PATCH: ADD ADVISER ROLE & COMSELEC WORKSPACE SELECTOR UPDATES
-- ==============================================================================
-- Run this script in your Supabase SQL editor. It updates functions and seeding 
-- incrementally without losing any existing table data.

-- 1. SEED ADVISER ROLE AND MAP PERMISSIONS
INSERT INTO public.roles (name, hierarchy_level) 
VALUES ('Adviser', 65) 
ON CONFLICT (name) DO UPDATE SET hierarchy_level = EXCLUDED.hierarchy_level;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r, public.permissions p
WHERE r.name = 'Adviser' AND p.action IN (
    'view_events', 'view_announcements', 'view_members', 'view_officers', 'view_documents', 'view_activity_cards'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- 2. DROP OLD DEFINITIONS OF MODIFIED RETURN TABLE FUNCTIONS TO AVOID CONFLICTS
DROP FUNCTION IF EXISTS public.get_my_workspaces() CASCADE;
DROP FUNCTION IF EXISTS public.get_workspace_by_id(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.get_workspace_role_and_permissions(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.assign_organization_officer(UUID, UUID, UUID, UUID, UUID) CASCADE;

-- 3. RE-CREATE FUNCTIONS WITH UPDATED SCHEMA AND LOGIC

-- get_my_workspaces
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
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT public.get_my_id() INTO v_user_id;
    IF v_user_id IS NULL THEN
        RETURN;
    END IF;

    -- 1. Student Organizations where the user is a member/officer
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
    WHERE om.user_id = v_user_id AND om.status = 'active';

    -- 2. Faculty workspaces where the user is Dean
    RETURN QUERY
    SELECT 
        f.id,
        f.name,
        f.code,
        'faculty'::VARCHAR AS type,
        f.logo_url,
        NULL::VARCHAR AS banner_url,
        'active'::VARCHAR AS status,
        f.campus_id,
        f.id AS faculty_id,
        NULL::UUID AS program_id
    FROM public.faculties f
    WHERE f.dean_id = v_user_id;

    -- 3. Program workspaces where the user is Program Head
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.code,
        'program'::VARCHAR AS type,
        p.logo_url,
        NULL::VARCHAR AS banner_url,
        'active'::VARCHAR AS status,
        f.campus_id,
        p.faculty_id,
        p.id AS program_id
    FROM public.programs p
    JOIN public.faculties f ON p.faculty_id = f.id
    WHERE p.program_head_id = v_user_id;

    -- 4. COMSELEC workspaces where the user is an active member (chair, commissioner, or voter)
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
    WHERE cm.user_id = v_user_id AND cm.status = 'active';
END;
$$;

-- get_workspace_by_id
CREATE OR REPLACE FUNCTION public.get_workspace_by_id(p_workspace_id UUID)
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
SECURITY DEFINER
AS $$
BEGIN
    -- Check organizations
    IF EXISTS (SELECT 1 FROM public.organizations WHERE organizations.id = p_workspace_id) THEN
        RETURN QUERY
        SELECT 
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
        WHERE o.id = p_workspace_id;
        RETURN;
    END IF;

    -- Check comselecs
    IF EXISTS (SELECT 1 FROM public.comselecs WHERE comselecs.id = p_workspace_id) THEN
        RETURN QUERY
        SELECT 
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
        WHERE c.id = p_workspace_id;
        RETURN;
    END IF;

    -- Check faculties
    IF EXISTS (SELECT 1 FROM public.faculties WHERE faculties.id = p_workspace_id) THEN
        RETURN QUERY
        SELECT 
            f.id,
            f.name,
            f.code,
            'faculty'::VARCHAR AS type,
            f.logo_url,
            NULL::VARCHAR AS banner_url,
            'active'::VARCHAR AS status,
            f.campus_id,
            f.id AS faculty_id,
            NULL::UUID AS program_id
        FROM public.faculties f
        WHERE f.id = p_workspace_id;
        RETURN;
    END IF;

    -- Check programs
    IF EXISTS (SELECT 1 FROM public.programs WHERE programs.id = p_workspace_id) THEN
        RETURN QUERY
        SELECT 
            p.id,
            p.name,
            p.code,
            'program'::VARCHAR AS type,
            p.logo_url,
            NULL::VARCHAR AS banner_url,
            'active'::VARCHAR AS status,
            f.campus_id,
            p.faculty_id,
            p.id AS program_id
        FROM public.programs p
        JOIN public.faculties f ON p.faculty_id = f.id
        WHERE p.id = p_workspace_id;
        RETURN;
    END IF;
END;
$$;

-- get_workspace_role_and_permissions
CREATE OR REPLACE FUNCTION public.get_workspace_role_and_permissions(
    p_workspace_id UUID,
    p_workspace_type TEXT
)
RETURNS TABLE (
    role_name VARCHAR,
    hierarchy_level INT,
    permissions JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT public.get_my_id() INTO v_user_id;
    IF v_user_id IS NULL THEN
        RETURN;
    END IF;

    IF p_workspace_type = 'faculty' THEN
        -- Check if they are dean
        IF EXISTS (SELECT 1 FROM public.faculties WHERE id = p_workspace_id AND dean_id = v_user_id) THEN
            RETURN QUERY
            SELECT 
                r.name,
                r.hierarchy_level,
                COALESCE(jsonb_agg(p.action) FILTER (WHERE p.action IS NOT NULL), '[]'::jsonb)
            FROM public.roles r
            LEFT JOIN public.role_permissions rp ON r.id = rp.role_id
            LEFT JOIN public.permissions p ON rp.permission_id = p.id
            WHERE r.name = 'Faculty Dean'
            GROUP BY r.id, r.name, r.hierarchy_level;
        END IF;

    ELSIF p_workspace_type = 'program' THEN
        -- Check if they are program head
        IF EXISTS (SELECT 1 FROM public.programs WHERE id = p_workspace_id AND program_head_id = v_user_id) THEN
            RETURN QUERY
            SELECT 
                r.name,
                r.hierarchy_level,
                COALESCE(jsonb_agg(p.action) FILTER (WHERE p.action IS NOT NULL), '[]'::jsonb)
            FROM public.roles r
            LEFT JOIN public.role_permissions rp ON r.id = rp.role_id
            LEFT JOIN public.permissions p ON rp.permission_id = p.id
            WHERE r.name = 'Program Head'
            GROUP BY r.id, r.name, r.hierarchy_level;
        END IF;

    ELSIF p_workspace_type = 'comselec' THEN
        -- Comselec workspaces
        RETURN QUERY
        SELECT 
            r.name,
            r.hierarchy_level,
            COALESCE(jsonb_agg(p.action) FILTER (WHERE p.action IS NOT NULL), '[]'::jsonb)
        FROM public.comselec_members cm
        JOIN public.roles r ON cm.role_id = r.id
        LEFT JOIN public.role_permissions rp ON r.id = rp.role_id
        LEFT JOIN public.permissions p ON rp.permission_id = p.id
        WHERE cm.user_id = v_user_id 
          AND cm.comselec_id = p_workspace_id 
          AND cm.status = 'active'
        GROUP BY r.id, r.name, r.hierarchy_level
        ORDER BY r.hierarchy_level DESC
        LIMIT 1;

    ELSE
        -- Organization workspaces
        RETURN QUERY
        SELECT 
            r.name,
            r.hierarchy_level,
            COALESCE(jsonb_agg(p.action) FILTER (WHERE p.action IS NOT NULL), '[]'::jsonb)
        FROM public.organization_members om
        JOIN public.roles r ON om.role_id = r.id
        LEFT JOIN public.role_permissions rp ON r.id = rp.role_id
        LEFT JOIN public.permissions p ON rp.permission_id = p.id
        WHERE om.user_id = v_user_id 
          AND om.organization_id = p_workspace_id 
          AND om.status = 'active'
        GROUP BY r.id, r.name, r.hierarchy_level
        ORDER BY r.hierarchy_level DESC
        LIMIT 1;
    END IF;
END;
$$;

-- assign_organization_officer
CREATE OR REPLACE FUNCTION assign_organization_officer(
    p_org_id UUID,
    p_user_id UUID,
    p_role_id UUID,
    p_term_id UUID,
    p_assigned_by UUID
) RETURNS VOID AS $$
DECLARE
    v_actual_assigned_by_id UUID;
    v_actual_user_id UUID;
    v_org_type TEXT;
    v_scope_id UUID;
    v_scope_type public.scope_type;
BEGIN
    -- Standardize ID: The app might send Auth UID or internal User ID
    SELECT id INTO v_actual_assigned_by_id 
    FROM public.users 
    WHERE id = p_assigned_by OR auth_id = p_assigned_by
    LIMIT 1;
    
    SELECT id INTO v_actual_user_id 
    FROM public.users 
    WHERE id = p_user_id OR auth_id = p_user_id
    LIMIT 1;

    -- Fetch Org Info for Scope Mapping
    SELECT type, 
           CASE 
             WHEN type = 'campus-based' THEN campus_id 
             WHEN type = 'faculty-based' THEN faculty_id
             WHEN type = 'program-based' THEN program_id
           END
    INTO v_org_type, v_scope_id
    FROM public.organizations WHERE id = p_org_id;

    v_scope_type := CASE 
                      WHEN v_org_type = 'campus-based' THEN 'Institutional'::public.scope_type
                      WHEN v_org_type = 'faculty-based' THEN 'Faculty'::public.scope_type
                      WHEN v_org_type = 'program-based' THEN 'Program'::public.scope_type
                    END;

    -- 1. Insert or Update membership (Organization Context)
    INSERT INTO organization_members (organization_id, user_id, role_id, academic_term_id, status)
    VALUES (p_org_id, v_actual_user_id, p_role_id, p_term_id, 'active')
    ON CONFLICT (organization_id, user_id) 
    DO UPDATE SET 
        role_id = EXCLUDED.role_id,
        academic_term_id = EXCLUDED.academic_term_id,
        status = 'active',
        assigned_at = CURRENT_TIMESTAMP;

    -- If the role is 'Adviser', update the adviser_name in organizations table
    IF EXISTS (SELECT 1 FROM public.roles WHERE id = p_role_id AND name = 'Adviser') THEN
        UPDATE public.organizations 
        SET adviser_name = (SELECT first_name || ' ' || last_name FROM public.users WHERE id = v_actual_user_id)
        WHERE id = p_org_id;
    END IF;

    -- 2. Log the action
    INSERT INTO governance_audit_logs (organization_id, action, performed_by_user_id, target_user_id, details)
    VALUES (
        p_org_id, 
        'assign_officer', 
        v_actual_assigned_by_id, 
        v_actual_user_id, 
        jsonb_build_object(
            'role_id', p_role_id,
            'term_id', p_term_id,
            'assigned_by', v_actual_assigned_by_id
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
