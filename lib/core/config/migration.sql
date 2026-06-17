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
