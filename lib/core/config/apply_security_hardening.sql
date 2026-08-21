-- ==============================================================================
-- NON-DESTRUCTIVE SECURITY HARDENING & MIGRATION SCRIPT FOR SUPABASE
-- Project: Vouch V2
-- File: lib/core/config/apply_security_hardening.sql
-- Description: Applies RLS policies, CVE-2018-1058 search_path hardening,
--              storage bucket security, auth trigger sanitization, and
--              non-destructive academic year resets to an existing live database.
-- Note: This script NEVER drops existing data tables or runs destructive DELETEs.
-- ==============================================================================

-- ------------------------------------------------------------
-- 1. HELPER FUNCTIONS FOR RBAC & IDENTIFICATION
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.get_my_id()
RETURNS UUID 
SET search_path = public, pg_temp
AS $$
    SELECT id FROM public.users WHERE auth_id = auth.uid() OR id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN 
SET search_path = public, pg_temp
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        JOIN public.users u ON ur.user_id = u.id
        WHERE (u.auth_id = auth.uid() OR u.id = auth.uid())
          AND r.name = 'Super Admin'
          AND ur.is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.has_scope_permission(
    p_action TEXT, 
    p_scope_type public.scope_type, 
    p_scope_id UUID
) 
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
              (o.type = 'campus-based' AND p_scope_type::text = 'Institutional' AND (o.campus_id = p_scope_id OR o.id = p_scope_id)) OR
              (o.type = 'faculty-based' AND p_scope_type::text = 'Faculty' AND (o.faculty_id = p_scope_id OR o.id = p_scope_id)) OR
              (o.type = 'program-based' AND p_scope_type::text = 'Program' AND (o.program_id = p_scope_id OR o.id = p_scope_id))
          )
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

-- ------------------------------------------------------------
-- 2. AUTHENTICATION TRIGGER SANITIZATION (PREVENT METADATA ROLE INJECTION)
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER 
SET search_path = public, pg_temp
AS $$
DECLARE
    default_role_id UUID;
    target_role_id UUID;
    requested_role TEXT;
BEGIN
    -- Force search_path
    SET LOCAL search_path = public, pg_temp;

    -- Fetch default student role
    SELECT id INTO default_role_id FROM public.roles WHERE name = 'Students' LIMIT 1;
    IF default_role_id IS NULL THEN
        SELECT id INTO default_role_id FROM public.roles WHERE name = 'Student' LIMIT 1;
    END IF;

    requested_role := LOWER(COALESCE(new.raw_user_meta_data->>'role', 'student'));

    -- Sanitize role input to prevent privilege escalation via metadata injection
    IF requested_role IN ('super_admin', 'superadmin', 'comselec_chairman', 'comselec_chair', 'comselec_commissioner', 'faculty_dean', 'program_head', 'faculty') THEN
        target_role_id := default_role_id;
    ELSE
        SELECT id INTO target_role_id FROM public.roles WHERE LOWER(name) = requested_role LIMIT 1;
        IF target_role_id IS NULL THEN
            target_role_id := default_role_id;
        END IF;
    END IF;

    INSERT INTO public.users (
        id,
        auth_id,
        email,
        first_name,
        last_name,
        student_id_number,
        campus_id,
        faculty_id,
        program_id,
        year,
        profile_photo_url,
        account_status,
        created_at
    )
    VALUES (
        new.id,
        new.id,
        new.email,
        new.raw_user_meta_data->>'first_name',
        new.raw_user_meta_data->>'last_name',
        COALESCE(new.raw_user_meta_data->>'student_id_number', 'TEMP-' || substring(new.id::text, 1, 8)),
        NULLIF(new.raw_user_meta_data->>'campus_id', '')::UUID,
        NULLIF(new.raw_user_meta_data->>'faculty_id', '')::UUID,
        NULLIF(new.raw_user_meta_data->>'program_id', '')::UUID,
        NULLIF(new.raw_user_meta_data->>'year', '')::INT,
        new.raw_user_meta_data->>'profile_photo_url',
        'active',
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        auth_id = EXCLUDED.auth_id,
        email = EXCLUDED.email,
        first_name = COALESCE(EXCLUDED.first_name, public.users.first_name),
        last_name = COALESCE(EXCLUDED.last_name, public.users.last_name);

    IF target_role_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role_id, is_active)
        VALUES (new.id, target_role_id, true)
        ON CONFLICT (user_id, role_id) DO UPDATE SET is_active = true;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------
-- 3. RLS TABLE POLICIES (HARDENING ACCESS CONTROL)
-- ------------------------------------------------------------

-- Enable RLS on core tables (idempotent)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_card_clearance_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_card_clearance_signatures ENABLE ROW LEVEL SECURITY;

-- Users Table Policies
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.users;
DROP POLICY IF EXISTS "Super admins can update any profile" ON public.users;

CREATE POLICY "Users can view their own profile" ON public.users FOR SELECT USING (auth.uid() = auth_id OR auth.uid() = id OR public.get_my_id() = id);
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE USING (auth.uid() = auth_id OR auth.uid() = id OR public.get_my_id() = id);
CREATE POLICY "Public profiles are viewable by everyone" ON public.users FOR SELECT USING (true);
CREATE POLICY "Super admins can update any profile" ON public.users FOR UPDATE TO authenticated USING (public.is_super_admin());

-- FCM Device Tokens Security
DROP POLICY IF EXISTS "Users can view their own device tokens" ON public.user_fcm_tokens;
DROP POLICY IF EXISTS "Users can insert their own device tokens" ON public.user_fcm_tokens;
DROP POLICY IF EXISTS "Users can update their own device tokens" ON public.user_fcm_tokens;
DROP POLICY IF EXISTS "Users can delete their own device tokens" ON public.user_fcm_tokens;

CREATE POLICY "Users can view their own device tokens" ON public.user_fcm_tokens FOR SELECT TO authenticated USING (user_id = auth.uid() OR user_id = public.get_my_id() OR public.is_super_admin());
CREATE POLICY "Users can insert their own device tokens" ON public.user_fcm_tokens FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid() OR user_id = public.get_my_id() OR public.is_super_admin());
CREATE POLICY "Users can update their own device tokens" ON public.user_fcm_tokens FOR UPDATE TO authenticated USING (user_id = auth.uid() OR user_id = public.get_my_id() OR public.is_super_admin());
CREATE POLICY "Users can delete their own device tokens" ON public.user_fcm_tokens FOR DELETE TO authenticated USING (user_id = auth.uid() OR user_id = public.get_my_id() OR public.is_super_admin());

-- Academic Terms Policies
DROP POLICY IF EXISTS "Academic terms are viewable by everyone" ON public.academic_terms;
DROP POLICY IF EXISTS "Super admins can manage academic terms" ON public.academic_terms;
DROP POLICY IF EXISTS "Super admins and authorized officers can manage academic terms" ON public.academic_terms;

CREATE POLICY "Academic terms are viewable by everyone" ON public.academic_terms FOR SELECT USING (true);
CREATE POLICY "Super admins and authorized officers can manage academic terms" ON public.academic_terms 
  FOR ALL TO authenticated 
  USING (
    public.is_super_admin() OR 
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE (ur.user_id = public.get_my_id() OR ur.user_id = auth.uid()) AND ur.is_active = true
    ) OR
    EXISTS (
      SELECT 1 FROM public.organization_members om
      WHERE om.user_id = public.get_my_id() AND om.role_id IS NOT NULL AND om.status = 'active'
    )
  );

-- Clearance Request & Signature Policies (Prevent Signature Forgery & Scope Exposure)
DROP POLICY IF EXISTS "Users and officers can view clearance requests" ON public.activity_card_clearance_requests;
CREATE POLICY "Users and officers can view clearance requests" ON public.activity_card_clearance_requests
  FOR SELECT TO authenticated
  USING (
    public.is_super_admin() OR
    student_id = public.get_my_id() OR
    student_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.organization_members om
      WHERE om.user_id = public.get_my_id()
        AND om.organization_id = activity_card_clearance_requests.organization_id
        AND om.role_id IS NOT NULL
        AND om.status = 'active'
    ) OR
    EXISTS (SELECT 1 FROM public.programs pr WHERE pr.program_head_id = public.get_my_id()) OR
    EXISTS (SELECT 1 FROM public.faculties f WHERE f.dean_id = public.get_my_id())
  );

DROP POLICY IF EXISTS "Students can insert their own clearance requests" ON public.activity_card_clearance_requests;
CREATE POLICY "Students can insert their own clearance requests" ON public.activity_card_clearance_requests
  FOR INSERT TO authenticated
  WITH CHECK (
    student_id = public.get_my_id() OR student_id = auth.uid()
  );

DROP POLICY IF EXISTS "Users and officers can view signatures" ON public.activity_card_clearance_signatures;
CREATE POLICY "Users and officers can view signatures" ON public.activity_card_clearance_signatures
  FOR SELECT TO authenticated
  USING (
    public.is_super_admin() OR
    EXISTS (
      SELECT 1 FROM public.activity_card_clearance_requests req
      WHERE req.id = activity_card_clearance_signatures.clearance_request_id
        AND (
          req.student_id = public.get_my_id() OR
          req.student_id = auth.uid() OR
          EXISTS (
            SELECT 1 FROM public.organization_members om
            WHERE om.user_id = public.get_my_id()
              AND om.organization_id = req.organization_id
              AND om.role_id IS NOT NULL
              AND om.status = 'active'
          ) OR
          EXISTS (SELECT 1 FROM public.programs pr WHERE pr.program_head_id = public.get_my_id()) OR
          EXISTS (SELECT 1 FROM public.faculties f WHERE f.dean_id = public.get_my_id())
        )
    )
  );

DROP POLICY IF EXISTS "Students can request signatures without pre-setting status" ON public.activity_card_clearance_signatures;
CREATE POLICY "Students can request signatures without pre-setting status" ON public.activity_card_clearance_signatures
  FOR INSERT TO authenticated
  WITH CHECK (
    (status IS NULL OR status = 'Pending') AND
    signed_by_user_id IS NULL AND
    signed_at IS NULL AND
    EXISTS (
      SELECT 1 FROM public.activity_card_clearance_requests req
      WHERE req.id = activity_card_clearance_signatures.clearance_request_id
        AND (req.student_id = public.get_my_id() OR req.student_id = auth.uid())
    )
  );

-- ------------------------------------------------------------
-- 4. STORAGE BUCKET HARDENING & STORAGE OBJECT POLICIES
-- ------------------------------------------------------------

-- Configure native bucket constraints (idempotent)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES 
  ('org-pictures', 'org-pictures', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('announcement-pictures', 'announcement-pictures', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('event-pictures', 'event-pictures', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('highlight-pictures', 'highlight-pictures', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('ids', 'ids', false, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('receipt-pictures', 'receipt-pictures', false, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('excuse-pictures', 'excuse-pictures', false, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif', 'application/pdf'])
ON CONFLICT (id) DO UPDATE SET 
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- BUCKET 1: org-pictures
DROP POLICY IF EXISTS "Allow public select on org pictures" ON storage.objects;
CREATE POLICY "Allow public select on org pictures" ON storage.objects FOR SELECT TO public USING (bucket_id = 'org-pictures');

DROP POLICY IF EXISTS "Allow officers and super admins to upload org pictures" ON storage.objects;
CREATE POLICY "Allow officers and super admins to upload org pictures" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'org-pictures' AND
    (
      public.is_super_admin() OR
      EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = public.get_my_id() AND ur.is_active = true) OR
      EXISTS (SELECT 1 FROM public.organization_members om WHERE om.user_id = public.get_my_id() AND om.role_id IS NOT NULL AND om.status = 'active') OR
      EXISTS (SELECT 1 FROM public.comselec_members cm WHERE cm.user_id = public.get_my_id() AND cm.role_id IS NOT NULL AND cm.status = 'active')
    )
  );

DROP POLICY IF EXISTS "Allow officers and super admins to update org pictures" ON storage.objects;
CREATE POLICY "Allow officers and super admins to update org pictures" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'org-pictures' AND
    (
      public.is_super_admin() OR
      owner = auth.uid() OR
      owner_id = auth.uid()::text OR
      EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = public.get_my_id() AND ur.is_active = true) OR
      EXISTS (SELECT 1 FROM public.organization_members om WHERE om.user_id = public.get_my_id() AND om.role_id IS NOT NULL AND om.status = 'active')
    )
  );

-- BUCKET 5: ids (Profile Photos & Student IDs)
DROP POLICY IF EXISTS "Allow students and super admins to view IDs" ON storage.objects;
CREATE POLICY "Allow students and super admins to view IDs" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'ids');

DROP POLICY IF EXISTS "Allow students to upload their own ID" ON storage.objects;
CREATE POLICY "Allow students to upload their own ID" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'ids' AND
    (
      public.is_super_admin() OR
      (storage.foldername(storage.objects.name))[1] = public.get_my_id()::text OR
      (storage.foldername(storage.objects.name))[1] = auth.uid()::text OR
      (storage.foldername(storage.objects.name))[1] = 'verification_ids' OR
      split_part(storage.filename(storage.objects.name), '_', 2) = (SELECT student_id_number FROM public.users WHERE auth_id = auth.uid() OR id = auth.uid()) OR
      split_part(storage.filename(storage.objects.name), '_', 2) = (SELECT email FROM public.users WHERE auth_id = auth.uid() OR id = auth.uid()) OR
      split_part(storage.filename(storage.objects.name), '_', 2) = (SELECT email FROM auth.users WHERE id = auth.uid()) OR
      split_part(storage.filename(storage.objects.name), '_', 2) = public.get_my_id()::text OR
      split_part(storage.filename(storage.objects.name), '_', 2) = auth.uid()::text
    )
  );

-- ------------------------------------------------------------
-- 5. WORKSPACE RETRIEVAL & NON-DESTRUCTIVE ACADEMIC RESET
-- ------------------------------------------------------------

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
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT public.get_my_id() INTO v_user_id;
    IF v_user_id IS NULL THEN RETURN; END IF;

    IF p_workspace_type = 'faculty' THEN
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
          AND (cm.expired_at IS NULL OR cm.expired_at > CURRENT_TIMESTAMP)
        GROUP BY r.id, r.name, r.hierarchy_level
        ORDER BY r.hierarchy_level DESC
        LIMIT 1;

    ELSE
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
          AND (om.expired_at IS NULL OR om.expired_at > CURRENT_TIMESTAMP)
        GROUP BY r.id, r.name, r.hierarchy_level
        ORDER BY r.hierarchy_level DESC
        LIMIT 1;
    END IF;
END;
$$;

-- Non-Destructive Academic Reset (Archives records, leaves events/fees/payments intact)
CREATE OR REPLACE FUNCTION public.reset_academic_year_data()
RETURNS VOID 
SET search_path = public, pg_temp
AS $$
DECLARE
    v_member_role_id UUID;
    v_voter_role_id UUID;
BEGIN
    IF NOT public.is_super_admin() THEN
        RAISE EXCEPTION 'Access denied: only Super Admins can execute academic year reset.';
    END IF;

    SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Member';
    SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Voters';

    UPDATE public.organization_members SET role_id = v_member_role_id WHERE role_id IS DISTINCT FROM v_member_role_id;
    UPDATE public.comselec_members SET role_id = v_voter_role_id WHERE role_id IS DISTINCT FROM v_voter_role_id;

    UPDATE public.organizations SET adviser_name = NULL WHERE id IS NOT NULL;
    UPDATE public.organization_settings SET clearance_period_start = NULL, clearance_period_end = NULL, restrict_clearance_request = FALSE WHERE organization_id IS NOT NULL;
    UPDATE public.comselec_settings SET clearance_period_start = NULL, clearance_period_end = NULL WHERE comselec_id IS NOT NULL;

    -- Non-destructive archiving of clearance requests and sanctions
    UPDATE public.activity_card_clearance_requests SET status = 'Archived' WHERE status <> 'Archived';
    UPDATE public.student_sanction_records SET status = 'Completed' WHERE status IN ('Pending Item', 'In Progress');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger Recursion Guard for single_active_term
CREATE OR REPLACE FUNCTION public.single_active_term()
RETURNS TRIGGER 
SET search_path = public, pg_temp
AS $$
DECLARE
    v_old_academic_year VARCHAR(20);
BEGIN
    IF pg_trigger_depth() > 1 THEN RETURN NEW; END IF;

    IF NEW.is_active = TRUE THEN
        SELECT academic_year INTO v_old_academic_year FROM public.academic_terms WHERE is_active = TRUE AND id <> NEW.id LIMIT 1;
        UPDATE public.academic_terms SET is_active = FALSE WHERE id <> NEW.id;

        IF v_old_academic_year IS NOT NULL AND v_old_academic_year <> NEW.academic_year THEN
            PERFORM public.reset_academic_year_data();
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------
-- 6. SYSTEM PRIVILEGES & ANON ROLE ACCESS
-- ------------------------------------------------------------

GRANT USAGE ON SCHEMA public, auth TO anon, authenticated, supabase_storage_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated, supabase_storage_admin;
GRANT SELECT ON public.campuses, public.faculties, public.programs, public.roles, public.academic_terms, public.organizations, public.comselecs TO anon;
GRANT SELECT ON auth.users TO authenticated, supabase_storage_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO authenticated, supabase_storage_admin;

-- ==============================================================================
-- END OF MIGRATION SCRIPT
-- ==============================================================================
