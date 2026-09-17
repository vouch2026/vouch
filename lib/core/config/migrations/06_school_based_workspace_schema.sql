-- Migration: 06_school_based_workspace_schema.sql
-- Description: Enable school-based organization/workspace types in database constraints and get_my_workspaces()

-- 1. Update organizations type check constraint
ALTER TABLE public.organizations DROP CONSTRAINT IF EXISTS organizations_type_check;
ALTER TABLE public.organizations 
  ADD CONSTRAINT organizations_type_check 
  CHECK (type IN ('school-based', 'campus-based', 'faculty-based', 'program-based', 'institutional', 'faculty', 'program', 'comselec'));

-- 2. Update get_my_workspaces() function
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
END;
$$;
