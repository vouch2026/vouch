-- Migration: 'School' scope_type + officer permission branch for school orgs.
--
-- IMPORTANT — enum transaction note:
--   ALTER TYPE ... ADD VALUE cannot run inside a transaction block. The
--   Supabase migration runner wraps files in a transaction, so if applying
--   this file errors with "ALTER TYPE ... ADD VALUE cannot be executed inside
--   a transaction block", run ONLY this line once via the Supabase Dashboard
--   SQL editor (autocommit), then re-apply this file (everything else is
--   re-runnable / IF NOT EXISTS guarded):
--     ALTER TYPE scope_type ADD VALUE IF NOT EXISTS 'School';
--
-- After the enum holds 'School', school-based orgs (e.g. USC) can own events /
-- fees / announcements with scope_type='School', scope_id=school_id.

ALTER TYPE scope_type ADD VALUE IF NOT EXISTS 'School';

-- Extend officer scope checks: a school-based org's officers hold permission
-- over scope ('School', their school_id). Copied from the base
-- has_scope_permission body with one added branch; user_roles branch already
-- works for 'School' via enum equality.
CREATE OR REPLACE FUNCTION public.has_scope_permission(p_action TEXT, p_scope_type public.scope_type, p_scope_id UUID)
RETURNS BOOLEAN
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT public.get_my_id() INTO v_user_id;
    IF v_user_id IS NULL THEN RETURN FALSE; END IF;

    IF public.is_super_admin() THEN RETURN TRUE; END IF;

    IF EXISTS (
        SELECT 1 FROM public.organization_members om
        JOIN public.organizations o ON om.organization_id = o.id
        JOIN public.role_permissions rp ON om.role_id = rp.role_id
        JOIN public.permissions p ON rp.permission_id = p.id
        WHERE om.user_id = v_user_id
        AND p.action = p_action
        AND om.status = 'active'
        AND (
            (o.type = 'school-based' AND p_scope_type::text = 'School' AND (o.school_id = p_scope_id OR o.id = p_scope_id)) OR
            (o.type = 'campus-based' AND p_scope_type::text = 'Institutional' AND (o.campus_id = p_scope_id OR o.id = p_scope_id)) OR
            (o.type = 'faculty-based' AND p_scope_type::text = 'Faculty' AND (o.faculty_id = p_scope_id OR o.id = p_scope_id)) OR
            (o.type = 'program-based' AND p_scope_type::text = 'Program' AND (o.program_id = p_scope_id OR o.id = p_scope_id))
        )
    ) THEN RETURN TRUE; END IF;

    IF EXISTS (
        SELECT 1 FROM public.comselec_members cm
        JOIN public.comselecs c ON cm.comselec_id = c.id
        JOIN public.role_permissions rp ON cm.role_id = rp.role_id
        JOIN public.permissions p ON rp.permission_id = p.id
        WHERE cm.user_id = v_user_id
        AND p.action = p_action
        AND cm.status = 'active'
        AND p_scope_type::text = 'Institutional'
        AND (c.campus_id = p_scope_id OR c.id = p_scope_id)
    ) THEN RETURN TRUE; END IF;

    IF EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.role_permissions rp ON ur.role_id = rp.role_id
        JOIN public.permissions p ON rp.permission_id = p.id
        WHERE ur.user_id = v_user_id
        AND p.action = p_action
        AND ur.scope_type = p_scope_type
        AND ur.scope_id = p_scope_id
        AND ur.is_active = true
    ) THEN RETURN TRUE; END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
