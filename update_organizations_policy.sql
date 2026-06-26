-- SQL script to allow organization officers to update their own organization's details (such as description and branding assets).
-- Copy and run this script in your Supabase dashboard SQL Editor.

CREATE POLICY "Officers can update their own organization details" ON public.organizations
  FOR UPDATE TO authenticated
  USING (
    public.is_super_admin() OR
    EXISTS (
      SELECT 1 FROM public.organization_members om
      WHERE om.user_id = public.get_my_id()
      AND om.organization_id = id
      AND om.role_id IS NOT NULL
      AND om.status = 'active'
    )
  );
