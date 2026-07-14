-- Safe update script for Representative Promotion & Demotion features
-- Run this in your Supabase SQL Editor to update the database functions.

-- 1. Drop existing assign_organization_officer function to avoid conflict with signature change
DROP FUNCTION IF EXISTS public.assign_organization_officer(UUID, UUID, UUID, UUID, UUID);

-- 2. Create updated assign_organization_officer with optional p_expired_at parameter
CREATE OR REPLACE FUNCTION public.assign_organization_officer(
    p_org_id UUID,
    p_user_id UUID,
    p_role_id UUID,
    p_term_id UUID,
    p_assigned_by UUID,
    p_expired_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
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

    -- Insert or Update membership (Organization Context) with expiration
    INSERT INTO organization_members (organization_id, user_id, role_id, academic_term_id, status, expired_at)
    VALUES (p_org_id, v_actual_user_id, p_role_id, p_term_id, 'active', p_expired_at)
    ON CONFLICT (organization_id, user_id) 
    DO UPDATE SET 
        role_id = EXCLUDED.role_id,
        academic_term_id = EXCLUDED.academic_term_id,
        status = 'active',
        assigned_at = CURRENT_TIMESTAMP,
        expired_at = EXCLUDED.expired_at;

    -- If the role is 'Adviser', update the adviser_name in organizations table
    IF EXISTS (SELECT 1 FROM public.roles WHERE id = p_role_id AND name = 'Adviser') THEN
        UPDATE public.organizations 
        SET adviser_name = (SELECT first_name || ' ' || last_name FROM public.users WHERE id = v_actual_user_id)
        WHERE id = p_org_id;
    END IF;

    -- Log the action
    INSERT INTO governance_audit_logs (organization_id, action, performed_by_user_id, target_user_id, details)
    VALUES (
        p_org_id, 
        'assign_officer', 
        v_actual_assigned_by_id, 
        v_actual_user_id, 
        jsonb_build_object(
            'role_id', p_role_id,
            'term_id', p_term_id,
            'scope_type', v_scope_type,
            'scope_id', v_scope_id,
            'expired_at', p_expired_at
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Modify get_workspace_role_and_permissions to clean up expired roles lazily
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
    -- Lazy cleanup of expired roles
    UPDATE public.organization_members
    SET role_id = NULL,
        expired_at = NULL,
        status = 'active'
    WHERE expired_at IS NOT NULL AND expired_at <= CURRENT_TIMESTAMP;

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

-- 4. Modify get_my_workspaces to also clean up expired roles lazily
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
    -- Lazy cleanup of expired roles
    UPDATE public.organization_members
    SET role_id = NULL,
        expired_at = NULL,
        status = 'active'
    WHERE expired_at IS NOT NULL AND expired_at <= CURRENT_TIMESTAMP;

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
        p.campus_id,
        NULL::UUID AS faculty_id,
        p.id AS program_id
    FROM public.programs p
    WHERE p.program_head_id = v_user_id;
END;
$$;
