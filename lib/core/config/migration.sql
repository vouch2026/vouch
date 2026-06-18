-- 1. Modify student_sanction_records total_absences type to numeric
ALTER TABLE student_sanction_records ALTER COLUMN total_absences TYPE NUMERIC(3,1);

-- 2. Modify sanction_rules to support range and type details
-- Drop the old unique constraint
ALTER TABLE sanction_rules DROP CONSTRAINT IF EXISTS sanction_rules_scope_id_academic_term_id_absence_count_key;

-- Add new columns
ALTER TABLE sanction_rules ADD COLUMN IF NOT EXISTS min_absence NUMERIC(3,1) DEFAULT 0;
ALTER TABLE sanction_rules ADD COLUMN IF NOT EXISTS max_absence NUMERIC(3,1);
ALTER TABLE sanction_rules ADD COLUMN IF NOT EXISTS sanction_type VARCHAR(50) NOT NULL DEFAULT 'Donation';
ALTER TABLE sanction_rules ADD COLUMN IF NOT EXISTS required_value DECIMAL(10,2);

-- Migrate existing data
UPDATE sanction_rules SET min_absence = absence_count WHERE min_absence = 0 AND absence_count IS NOT NULL;

-- Drop old absence_count column
ALTER TABLE sanction_rules DROP COLUMN IF EXISTS absence_count;

-- Add new unique constraint
ALTER TABLE sanction_rules ADD CONSTRAINT unique_scope_term_min_absence UNIQUE (scope_id, academic_term_id, min_absence);


-- 3. Create excuse_requests table
CREATE TABLE IF NOT EXISTS excuse_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  reason VARCHAR(500) NOT NULL,
  supporting_document_url VARCHAR(2048) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected'
  rejection_reason VARCHAR(255),
  scope_type scope_type NOT NULL,
  scope_id UUID NOT NULL,
  academic_term_id UUID NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  reviewed_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(student_id, event_id)
);

-- Enable RLS
ALTER TABLE excuse_requests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to support re-running migration)
DROP POLICY IF EXISTS "Students can view their own excuses" ON excuse_requests;
DROP POLICY IF EXISTS "Students can submit excuses" ON excuse_requests;
DROP POLICY IF EXISTS "Officers can view excuses in their scope" ON excuse_requests;
DROP POLICY IF EXISTS "Officers can review excuses in their scope" ON excuse_requests;

-- 4. Create excuse_requests policies
CREATE POLICY "Students can view their own excuses" ON excuse_requests
  FOR SELECT TO authenticated USING (student_id = public.get_my_id());

CREATE POLICY "Students can submit excuses" ON excuse_requests
  FOR INSERT TO authenticated WITH CHECK (student_id = public.get_my_id());

CREATE POLICY "Officers can view excuses in their scope" ON excuse_requests
  FOR SELECT TO authenticated USING (
    public.has_scope_permission('view_events', scope_type, scope_id) OR
    public.has_scope_permission('override_attendance', scope_type, scope_id) OR
    public.has_scope_permission('receive_sanction_items', scope_type, scope_id)
  );

CREATE POLICY "Officers can review excuses in their scope" ON excuse_requests
  FOR UPDATE TO authenticated USING (
    public.has_scope_permission('override_attendance', scope_type, scope_id) OR
    public.has_scope_permission('receive_sanction_items', scope_type, scope_id)
  );

-- Create automatic timestamp update trigger
CREATE TRIGGER update_excuse_requests_updated_at 
BEFORE UPDATE ON excuse_requests 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. Update has_scope_permission to support matching by organization ID
CREATE OR REPLACE FUNCTION public.has_scope_permission(
    p_action TEXT,
    p_scope_type public.scope_type,
    p_scope_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT id INTO v_user_id FROM public.users WHERE auth_id = auth.uid();
    IF v_user_id IS NULL THEN RETURN FALSE; END IF;

    -- Check Super Admin
    IF public.is_super_admin() THEN RETURN TRUE; END IF;

    -- Check Organization Members (Officers)
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

    -- Check User Roles (System-wide roles like Dean, Program Head)
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
