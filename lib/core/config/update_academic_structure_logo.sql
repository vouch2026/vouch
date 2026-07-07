-- ==============================================================================
-- VOUCH DB UPDATE: ADD LOGO_URL TO ACADEMIC STRUCTURE (CAMPUS, FACULTY, PROGRAM)
-- ==============================================================================
-- Run this script in your Supabase SQL editor. It adds logo_url columns dynamically
-- if they don't already exist and updates the workspaces queries to return them.

DO $$
BEGIN
    -- 1. Add logo_url to faculties if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'faculties' 
          AND column_name = 'logo_url'
    ) THEN
        ALTER TABLE public.faculties ADD COLUMN logo_url VARCHAR(2048);
    END IF;

    -- 2. Add logo_url to programs if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'programs' 
          AND column_name = 'logo_url'
    ) THEN
        ALTER TABLE public.programs ADD COLUMN logo_url VARCHAR(2048);
    END IF;
END $$;

-- 3. DROP OLD DEFINITIONS OF WORKSPACE FUNCTIONS TO PREVENT COMPILATION ISSUES
DROP FUNCTION IF EXISTS public.get_my_workspaces() CASCADE;
DROP FUNCTION IF EXISTS public.get_workspace_by_id(UUID) CASCADE;

-- 4. RE-CREATE GET_MY_WORKSPACES WITH LOGO_URL RETRIEVAL
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

-- 5. RE-CREATE GET_WORKSPACE_BY_ID WITH LOGO_URL RETRIEVAL
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
