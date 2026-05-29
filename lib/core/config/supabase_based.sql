-- ==========================================
-- VOUCH CORE SCHEMA (v2 Final - Fully Optimized)
-- ==========================================
-- ==========================================
-- VOUCH TEARDOWN SCRIPT
-- ==========================================

-- 1. Drop all tables (CASCADE handles foreign key dependencies)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Drop legacy profiles table if it exists
DROP TABLE IF EXISTS public.profiles CASCADE;

DROP TABLE IF EXISTS activity_card_clearance_signatures CASCADE;
DROP TABLE IF EXISTS activity_card_clearance_requests CASCADE;
DROP TABLE IF EXISTS student_sanction_records CASCADE;
DROP TABLE IF EXISTS announcements CASCADE;
DROP TABLE IF EXISTS student_payments CASCADE;
DROP TABLE IF EXISTS payment_receiver CASCADE;
DROP TABLE IF EXISTS student_attendance CASCADE;
DROP TABLE IF EXISTS sanction_rules CASCADE;
DROP TABLE IF EXISTS event_ratings CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS fees CASCADE;
DROP TABLE IF EXISTS organization_members CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS permissions CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;
DROP TABLE IF EXISTS programs CASCADE;
DROP TABLE IF EXISTS faculties CASCADE;
DROP TABLE IF EXISTS campuses CASCADE;
DROP TABLE IF EXISTS academic_terms CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Robustly drop all versions of the organization creation function
DO $$ 
DECLARE
    _sql text;
BEGIN
    SELECT 'DROP FUNCTION ' || string_agg(oid::regprocedure::text, '; DROP FUNCTION ')
    FROM pg_proc 
    WHERE proname = 'create_organization_with_members' 
      AND pronamespace = 'public'::regnamespace
    INTO _sql;
    IF _sql IS NOT NULL THEN
        EXECUTE _sql;
    END IF;
EXCEPTION WHEN OTHERS THEN 
    NULL;
END $$;

-- 2. Drop all custom ENUM types
DROP TYPE IF EXISTS sanction_status CASCADE;
DROP TYPE IF EXISTS signature_status CASCADE;
DROP TYPE IF EXISTS clearance_status CASCADE;
DROP TYPE IF EXISTS payment_status CASCADE;
DROP TYPE IF EXISTS attendance_status CASCADE;
DROP TYPE IF EXISTS scope_type CASCADE;
DROP TYPE IF EXISTS semester_type CASCADE;

-- 3. Drop custom utility functions
DROP FUNCTION IF EXISTS single_active_term() CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- ==========================================
-- 0. UTILITY FUNCTIONS
-- ==========================================
-- Automatically updates the updated_at timestamp on row changes
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ language 'plpgsql';

-- Ensures ONLY ONE term is active at a time
CREATE OR REPLACE FUNCTION single_active_term()
RETURNS TRIGGER AS $$
BEGIN
IF NEW.is_active = TRUE THEN
    UPDATE academic_terms SET is_active = FALSE WHERE id <> NEW.id;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- 1. ENUMS
-- ==========================================
CREATE TYPE semester_type AS ENUM ('1st', '2nd', 'Summer');
-- Includes 'Institutional' for campus-wide Comselec clearances
CREATE TYPE scope_type AS ENUM ('Faculty', 'Program', 'Institutional'); 
CREATE TYPE attendance_status AS ENUM ('Pending', 'Present', 'Late', 'Incomplete', 'Absent', 'Excused');
CREATE TYPE payment_status AS ENUM ('Pending', 'Paid', 'Rejected');
CREATE TYPE clearance_status AS ENUM ('Pending', 'Cleared', 'Rejected');
CREATE TYPE signature_status AS ENUM ('Pending', 'Signed', 'Rejected');
CREATE TYPE sanction_status AS ENUM ('Pending Item', 'Item Received');

-- ==========================================
-- 2. BASE TABLES (No Foreign Key Dependencies)
-- ==========================================

CREATE TABLE roles (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name VARCHAR(100) NOT NULL UNIQUE,
hierarchy_level INT NOT NULL
);

CREATE TABLE permissions (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
action VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE role_permissions (
role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE academic_terms (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
academic_year VARCHAR(20) NOT NULL, 
semester semester_type NOT NULL,
is_active BOOLEAN DEFAULT false,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
UNIQUE(academic_year, semester)
);

CREATE TRIGGER ensure_single_active_term
BEFORE INSERT OR UPDATE ON academic_terms
FOR EACH ROW EXECUTE FUNCTION single_active_term();

CREATE TABLE campuses (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name VARCHAR(255) NOT NULL,
location VARCHAR(255) NOT NULL,
description TEXT,
logo_url VARCHAR(2048),
status VARCHAR(20) DEFAULT 'active',
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_campuses_updated_at BEFORE UPDATE ON campuses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- 3. CORE ENTITIES (Users, Faculties, Programs)
-- ==========================================

CREATE TABLE users (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
auth_id UUID UNIQUE, -- References auth.users in Supabase
student_id_number VARCHAR(50) UNIQUE NOT NULL,
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
email VARCHAR(255) UNIQUE NOT NULL,
profile_photo_url VARCHAR(2048),
id_front_url VARCHAR(2048), -- From legacy profiles
id_back_url VARCHAR(2048),  -- From legacy profiles
year INT,
account_status VARCHAR(20) DEFAULT 'active', -- Maps to 'status' in legacy profiles
organization_ids TEXT[] DEFAULT '{}',        -- From legacy profiles
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE faculties (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
campus_id UUID NOT NULL REFERENCES campuses(id) ON DELETE CASCADE,
name VARCHAR(255) NOT NULL,
code VARCHAR(50) NOT NULL UNIQUE,
dean_id UUID REFERENCES users(id) ON DELETE SET NULL,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_faculties_updated_at BEFORE UPDATE ON faculties FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE programs (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
faculty_id UUID NOT NULL REFERENCES faculties(id) ON DELETE CASCADE,
name VARCHAR(255) NOT NULL,
code VARCHAR(50) NOT NULL UNIQUE,
program_head_id UUID REFERENCES users(id) ON DELETE SET NULL,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_programs_updated_at BEFORE UPDATE ON programs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Circular Reference handling
ALTER TABLE users ADD COLUMN campus_id UUID REFERENCES campuses(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN faculty_id UUID REFERENCES faculties(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN program_id UUID REFERENCES programs(id) ON DELETE SET NULL;

-- ==========================================
-- 4. GOVERNANCE & ORGANIZATIONS
-- ==========================================

CREATE TABLE organizations (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name VARCHAR(255) NOT NULL,
code VARCHAR(50) NOT NULL UNIQUE,
description TEXT,
logo_url VARCHAR(2048),
banner_url VARCHAR(2048),
status VARCHAR(20) DEFAULT 'active',
type VARCHAR(50) DEFAULT 'campus-based',
campus_id UUID REFERENCES campuses(id) ON DELETE SET NULL,
faculty_id UUID REFERENCES faculties(id) ON DELETE SET NULL,
program_id UUID REFERENCES programs(id) ON DELETE SET NULL,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE organization_members (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
role_id UUID REFERENCES roles(id) ON DELETE SET NULL,
academic_term_id UUID REFERENCES academic_terms(id) ON DELETE SET NULL,
status VARCHAR(20) DEFAULT 'active', -- active, expired, pending, removed, archived
assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
expired_at TIMESTAMP WITH TIME ZONE,
joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
UNIQUE(organization_id, user_id, academic_term_id)
);

CREATE TABLE user_roles (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL, 
assigned_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
is_active BOOLEAN DEFAULT true,
UNIQUE(user_id, role_id, scope_type, scope_id)
);

CREATE TABLE governance_audit_logs (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
action VARCHAR(100) NOT NULL,
performed_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
target_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
details JSONB,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 5. REQUIREMENTS (EVENTS, FEES & SANCTIONS)
-- ==========================================

CREATE TABLE fees (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name VARCHAR(255) NOT NULL,
description TEXT,
amount DECIMAL(10, 2) NOT NULL,
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL,
is_mandatory BOOLEAN DEFAULT true,
due_date DATE NOT NULL,
academic_term_id UUID NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT, 
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL
);

CREATE TRIGGER update_fees_updated_at BEFORE UPDATE ON fees FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE events (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name VARCHAR(255) NOT NULL,
event_date DATE NOT NULL,
short_description VARCHAR(255),
full_description TEXT,
image_url VARCHAR(2048),
location VARCHAR(255) NOT NULL,
time_in_start TIME NOT NULL,
time_in_end TIME NOT NULL,
time_out_start TIME NOT NULL,
time_out_end TIME NOT NULL,
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL, 
is_mandatory BOOLEAN DEFAULT true,
academic_term_id UUID REFERENCES academic_terms(id) ON DELETE RESTRICT,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL
);

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE announcements (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
title VARCHAR(255) NOT NULL,
content TEXT NOT NULL,
type VARCHAR(50) DEFAULT 'General',
link_url VARCHAR(2048),
image_url VARCHAR(2048),
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL,
academic_term_id UUID NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL
);

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE event_ratings (
id SERIAL PRIMARY KEY,
event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
rating INT CHECK (rating >= 1 AND rating <= 5),
comment TEXT,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
UNIQUE(event_id, user_id)
);

CREATE TABLE sanction_rules (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL,
academic_term_id UUID NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT,
absence_count INT NOT NULL, 
item_description VARCHAR(255) NOT NULL, 
created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
UNIQUE(scope_id, academic_term_id, absence_count) 
);

-- ==========================================
-- 6. FULFILLMENT (ATTENDANCE, PAYMENTS & SANCTIONS)
-- ==========================================

CREATE TABLE student_attendance (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
actual_time_in TIMESTAMP WITH TIME ZONE,
actual_time_out TIMESTAMP WITH TIME ZONE,
status attendance_status DEFAULT 'Pending',
scanned_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
override_reason VARCHAR(255),
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
UNIQUE(student_id, event_id)
);

CREATE TRIGGER update_attendance_updated_at BEFORE UPDATE ON student_attendance FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE INDEX idx_student_attendance_student_id ON student_attendance(student_id);
CREATE INDEX idx_student_attendance_event_id ON student_attendance(event_id);

CREATE TABLE payment_receiver (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
bank_type VARCHAR(100) NOT NULL,
account_name VARCHAR(255) NOT NULL,
account_number VARCHAR(100) NOT NULL,
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL,
created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE student_payments (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
fee_id UUID NOT NULL REFERENCES fees(id) ON DELETE CASCADE,
reference_number VARCHAR(50) NOT NULL,
proof_photo_url VARCHAR(2048),
payment_receiver_id UUID REFERENCES payment_receiver(id) ON DELETE SET NULL,
rejection_note TEXT,
status payment_status DEFAULT 'Pending',
amount_paid DECIMAL(10, 2) NOT NULL,
paid_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
received_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL
);

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON student_payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE INDEX idx_student_payments_student_id ON student_payments(student_id);
CREATE INDEX idx_student_payments_fee_id ON student_payments(fee_id);

CREATE TABLE student_sanction_records (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL,
academic_term_id UUID NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT,
total_absences INT NOT NULL,
required_item VARCHAR(255) NOT NULL, 
status sanction_status DEFAULT 'Pending Item',
received_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL, 
received_at TIMESTAMP WITH TIME ZONE,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_sanctions_updated_at BEFORE UPDATE ON student_sanction_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE INDEX idx_student_sanctions_student_id ON student_sanction_records(student_id);

-- ==========================================
-- 7. THE CLEARANCE WORKFLOW
-- ==========================================

CREATE TABLE activity_card_clearance_requests (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL,
academic_term_id UUID NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT, 
status clearance_status DEFAULT 'Pending',
requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
completed_at TIMESTAMP WITH TIME ZONE
);

CREATE TRIGGER update_clearance_requests_updated_at 
BEFORE UPDATE ON activity_card_clearance_requests 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_clearance_requests_student_id ON activity_card_clearance_requests(student_id);

CREATE TABLE activity_card_clearance_signatures (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
clearance_request_id UUID NOT NULL REFERENCES activity_card_clearance_requests(id) ON DELETE CASCADE,
required_role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
required_scope_id UUID NOT NULL, 
status signature_status DEFAULT 'Pending',
signed_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
signed_at TIMESTAMP WITH TIME ZONE,
remarks VARCHAR(255)
);

CREATE INDEX idx_clearance_signatures_request_id ON activity_card_clearance_signatures(clearance_request_id);

-- ==============================================================================
-- 8. SECURITY, AUTH & RBAC POLICIES
-- ==============================================================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE campuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculties ENABLE ROW LEVEL SECURITY;
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_sanction_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_card_clearance_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_card_clearance_signatures ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- HELPER FUNCTION FOR RBAC
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
RETURN EXISTS (
SELECT 1 FROM public.user_roles ur
JOIN public.roles r ON ur.role_id = r.id
WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
AND r.name = 'Super Admin'
AND ur.is_active = true
);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------
-- POLICIES
-- ------------------------------------------------------------

-- Users
CREATE POLICY "Users can view their own profile" ON users FOR SELECT USING (auth.uid() = auth_id);
CREATE POLICY "Users can update their own profile" ON users FOR UPDATE USING (auth.uid() = auth_id);
CREATE POLICY "Public profiles are viewable by everyone" ON users FOR SELECT USING (true);
CREATE POLICY "Super admins can update any profile" ON users FOR UPDATE TO authenticated USING (public.is_super_admin());

-- Roles & RBAC
CREATE POLICY "Roles are viewable by authenticated users" ON roles FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "User roles are viewable by authenticated users" ON user_roles FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Permissions are viewable by authenticated users" ON permissions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Role permissions are viewable by authenticated users" ON role_permissions FOR SELECT USING (auth.role() = 'authenticated');

-- Academic Structure
CREATE POLICY "Campuses are viewable by everyone" ON campuses FOR SELECT USING (true);
CREATE POLICY "Faculties are viewable by everyone" ON faculties FOR SELECT USING (true);
CREATE POLICY "Programs are viewable by everyone" ON programs FOR SELECT USING (true);
CREATE POLICY "Organizations are viewable by everyone" ON organizations FOR SELECT USING (true);
CREATE POLICY "Academic terms are viewable by everyone" ON academic_terms FOR SELECT USING (true);

-- Manage policies (Super Admin only)
CREATE POLICY "Super admins can manage campuses" ON campuses FOR ALL TO authenticated USING (public.is_super_admin());
CREATE POLICY "Super admins can manage faculties" ON faculties FOR ALL TO authenticated USING (public.is_super_admin());
CREATE POLICY "Super admins can manage programs" ON programs FOR ALL TO authenticated USING (public.is_super_admin());
CREATE POLICY "Super admins can manage organizations" ON organizations FOR ALL TO authenticated USING (public.is_super_admin());
CREATE POLICY "Super admins can manage academic terms" ON academic_terms FOR ALL TO authenticated USING (public.is_super_admin());

-- Organization Members
CREATE POLICY "Members can view their own memberships" ON organization_members FOR SELECT 
USING (user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid()));
CREATE POLICY "Organization members are viewable by everyone" ON organization_members FOR SELECT USING (true);
CREATE POLICY "Super admins can manage organization memberships" ON organization_members FOR ALL TO authenticated USING (public.is_super_admin());

-- Events
CREATE POLICY "Events are viewable by everyone" ON events FOR SELECT USING (true);
CREATE POLICY "Officers can create events" ON events FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = events.scope_type
    AND ur.scope_id = events.scope_id
    AND p.action = 'create_event'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);
CREATE POLICY "Officers can update events" ON events FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = events.scope_type
    AND ur.scope_id = events.scope_id
    AND p.action = 'edit_event'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);
CREATE POLICY "Officers can delete events" ON events FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = events.scope_type
    AND ur.scope_id = events.scope_id
    AND p.action = 'delete_event'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);

-- Announcements
CREATE POLICY "Announcements are viewable by everyone" ON announcements FOR SELECT USING (true);
CREATE POLICY "Officers can create announcements" ON announcements FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = announcements.scope_type
    AND ur.scope_id = announcements.scope_id
    AND p.action = 'create_announcement'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);
CREATE POLICY "Officers can update announcements" ON announcements FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = announcements.scope_type
    AND ur.scope_id = announcements.scope_id
    AND p.action = 'edit_announcement'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);
CREATE POLICY "Officers can delete announcements" ON announcements FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = announcements.scope_type
    AND ur.scope_id = announcements.scope_id
    AND p.action = 'delete_announcement'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);

-- Fees
CREATE POLICY "Fees are viewable by everyone" ON fees FOR SELECT USING (true);
CREATE POLICY "Officers can create fees" ON fees FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = fees.scope_type
    AND ur.scope_id = fees.scope_id
    AND p.action = 'create_fee'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);
CREATE POLICY "Officers can update fees" ON fees FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = fees.scope_type
    AND ur.scope_id = fees.scope_id
    AND p.action = 'edit_fee'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);
CREATE POLICY "Officers can delete fees" ON fees FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND ur.scope_type = fees.scope_type
    AND ur.scope_id = fees.scope_id
    AND p.action = 'delete_fee'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);

-- Payment Receivers
CREATE POLICY "Payment receivers are viewable by everyone" ON payment_receiver FOR SELECT USING (true);
CREATE POLICY "Officers can manage payment receivers" ON payment_receiver FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND p.action = 'manage_payment_receivers'
    AND ur.is_active = true
  )
  OR public.is_super_admin()
);

-- ==============================================================================
-- 9. FUNCTIONS & PROCEDURES
-- ==============================================================================

CREATE OR REPLACE FUNCTION assign_organization_officer(
    p_org_id UUID,
    p_user_id UUID,
    p_role_id UUID,
    p_term_id UUID,
    p_assigned_by UUID
) RETURNS VOID AS $$
DECLARE
    v_actual_assigned_by_id UUID;
    v_org_type TEXT;
    v_scope_id UUID;
    v_scope_type public.scope_type;
BEGIN
    -- Standardize ID: The app might send Auth UID or internal User ID
    SELECT id INTO v_actual_assigned_by_id 
    FROM public.users 
    WHERE id = p_assigned_by OR auth_id = p_assigned_by
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
    -- If they have a base membership (NULL term), upgrade it
    UPDATE organization_members 
    SET 
        role_id = p_role_id,
        academic_term_id = p_term_id,
        status = 'active',
        assigned_at = CURRENT_TIMESTAMP
    WHERE organization_id = p_org_id 
      AND user_id = p_user_id 
      AND academic_term_id IS NULL;

    IF NOT FOUND THEN
        INSERT INTO organization_members (organization_id, user_id, role_id, academic_term_id, status)
        VALUES (p_org_id, p_user_id, p_role_id, p_term_id, 'active')
        ON CONFLICT (organization_id, user_id, academic_term_id) 
        DO UPDATE SET 
            role_id = EXCLUDED.role_id,
            status = 'active',
            assigned_at = CURRENT_TIMESTAMP;
    END IF;

    -- 2. Sync to user_roles (System-wide recognition)
    IF v_scope_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
        VALUES (p_user_id, p_role_id, v_scope_type, v_scope_id)
        ON CONFLICT (user_id, role_id, scope_type, scope_id) 
        DO UPDATE SET is_active = true;
    END IF;

    -- 3. Log the action
    INSERT INTO governance_audit_logs (organization_id, action, performed_by_user_id, target_user_id, details)
    VALUES (
        p_org_id, 
        'assign_officer', 
        v_actual_assigned_by_id, 
        p_user_id, 
        jsonb_build_object(
            'role_id', p_role_id,
            'term_id', p_term_id,
            'scope_type', v_scope_type,
            'scope_id', v_scope_id
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Utility to sync existing officers to user_roles
CREATE OR REPLACE FUNCTION sync_all_officers_to_user_roles()
RETURNS VOID AS $$
DECLARE
    v_rec RECORD;
    v_scope_id UUID;
    v_scope_type public.scope_type;
BEGIN
    FOR v_rec IN 
        SELECT om.user_id, om.role_id, om.organization_id, o.type, o.campus_id, o.faculty_id, o.program_id
        FROM public.organization_members om
        JOIN public.organizations o ON om.organization_id = o.id
        WHERE om.role_id IS NOT NULL
    LOOP
        v_scope_id := CASE 
                         WHEN v_rec.type = 'campus-based' THEN v_rec.campus_id 
                         WHEN v_rec.type = 'faculty-based' THEN v_rec.faculty_id
                         WHEN v_rec.type = 'program-based' THEN v_rec.program_id
                       END;

        v_scope_type := CASE 
                          WHEN v_rec.type = 'campus-based' THEN 'Institutional'::public.scope_type
                          WHEN v_rec.type = 'faculty-based' THEN 'Faculty'::public.scope_type
                          WHEN v_rec.type = 'program-based' THEN 'Program'::public.scope_type
                        END;

        IF v_scope_id IS NOT NULL THEN
            INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
            VALUES (v_rec.user_id, v_rec.role_id, v_scope_type, v_scope_id)
            ON CONFLICT (user_id, role_id, scope_type, scope_id) 
            DO UPDATE SET is_active = true;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION create_organization_with_members(
    p_name TEXT,
    p_code TEXT,
    p_description TEXT,
    p_type TEXT,
    p_campus_id UUID DEFAULT NULL,
    p_faculty_id UUID DEFAULT NULL,
    p_program_ids UUID[] DEFAULT '{}',
    p_logo_url TEXT DEFAULT NULL,
    p_banner_url TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_org_id UUID;
    v_primary_program_id UUID;
BEGIN
    IF p_program_ids IS NOT NULL AND array_length(p_program_ids, 1) > 0 THEN
        v_primary_program_id := p_program_ids[1];
    ELSE
        v_primary_program_id := NULL;
    END IF;

    INSERT INTO organizations (name, code, description, type, campus_id, faculty_id, program_id, logo_url, banner_url)
    VALUES (p_name, p_code, p_description, p_type, p_campus_id, p_faculty_id, v_primary_program_id, p_logo_url, p_banner_url)
    RETURNING id INTO v_org_id;

    IF p_type = 'campus-based' AND p_campus_id IS NOT NULL THEN
        INSERT INTO organization_members (organization_id, user_id)
        SELECT v_org_id, id FROM public.users WHERE campus_id = p_campus_id
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'faculty-based' AND p_faculty_id IS NOT NULL THEN
        INSERT INTO organization_members (organization_id, user_id)
        SELECT v_org_id, id FROM public.users WHERE faculty_id = p_faculty_id
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'program-based' AND p_program_ids IS NOT NULL AND array_length(p_program_ids, 1) > 0 THEN
        INSERT INTO organization_members (organization_id, user_id)
        SELECT v_org_id, id FROM public.users WHERE program_id = ANY(p_program_ids)
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN v_org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TABLE (
role_name VARCHAR, 
hierarchy_level INT, 
scope_type VARCHAR,
permissions JSONB
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
RETURN QUERY
SELECT 
r.name, 
r.hierarchy_level, 
ur.scope_type::VARCHAR,
COALESCE(
    jsonb_agg(p.action) FILTER (WHERE p.action IS NOT NULL), 
    '[]'::jsonb
) AS permissions
FROM user_roles ur
JOIN roles r ON ur.role_id = r.id
JOIN users u ON ur.user_id = u.id
LEFT JOIN role_permissions rp ON r.id = rp.role_id
LEFT JOIN permissions p ON rp.permission_id = p.id
WHERE u.auth_id = auth.uid() 
AND ur.is_active = true
GROUP BY r.id, r.name, r.hierarchy_level, ur.scope_type;
END;
$$;

-- ==============================================================================
-- 10. AUTH TRIGGERS
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
    new_user_id UUID;
    target_role_id UUID;
    v_role TEXT;
    v_position TEXT;
    v_scope_type public.scope_type;
    v_scope_id UUID;
    v_faculty_id UUID;
    v_program_id UUID;
    v_campus_id UUID;
BEGIN
    v_role := new.raw_user_meta_data->>'role';
    v_position := new.raw_user_meta_data->>'position';
    v_campus_id := (NULLIF(new.raw_user_meta_data->>'campus_id', ''))::uuid;
    v_faculty_id := (NULLIF(new.raw_user_meta_data->>'faculty_id', ''))::uuid;
    v_program_id := (NULLIF(new.raw_user_meta_data->>'program_id', ''))::uuid;

    IF v_campus_id IS NULL AND v_faculty_id IS NOT NULL THEN
        SELECT campus_id INTO v_campus_id FROM public.faculties WHERE id = v_faculty_id;
    END IF;

    INSERT INTO public.users (
        auth_id, email, first_name, last_name, student_id_number, 
        campus_id, faculty_id, program_id, year,
        id_front_url, id_back_url, account_status
    )
    VALUES (
        new.id, new.email, 
        COALESCE(new.raw_user_meta_data->>'first_name', ''),
        COALESCE(new.raw_user_meta_data->>'last_name', ''), 
        COALESCE(NULLIF(new.raw_user_meta_data->>'school_id', ''), 'PENDING-' || substr(new.id::text, 1, 8)),
        v_campus_id, v_faculty_id, v_program_id,
        (NULLIF(new.raw_user_meta_data->>'year_level', ''))::int,
        new.raw_user_meta_data->>'id_front_url', new.raw_user_meta_data->>'id_back_url',
        COALESCE(new.raw_user_meta_data->>'status', 'active')
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
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
    ELSIF v_role = 'faculty' THEN
        IF v_position = 'dean' THEN
            SELECT id INTO target_role_id FROM public.roles WHERE name = 'Faculty Dean';
            v_scope_type := 'Faculty';
            v_scope_id := v_faculty_id;
        ELSIF v_position = 'program_head' THEN
            SELECT id INTO target_role_id FROM public.roles WHERE name = 'Program Head';
            v_scope_type := 'Program';
            v_scope_id := v_program_id;
        ELSIF v_position = 'instructor' THEN
            SELECT id INTO target_role_id FROM public.roles WHERE name = 'Instructor';
            v_scope_type := 'Faculty';
            v_scope_id := v_faculty_id;
        END IF;
    END IF;

    IF target_role_id IS NOT NULL AND v_scope_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
        VALUES (new_user_id, target_role_id, v_scope_type, v_scope_id)
        ON CONFLICT DO NOTHING;
    END IF;

    IF v_campus_id IS NOT NULL THEN
        INSERT INTO public.organization_members (organization_id, user_id, role_id)
        SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Students')
        FROM public.organizations 
        WHERE type = 'campus-based' AND campus_id = v_campus_id
        ON CONFLICT DO NOTHING;
    END IF;

    IF v_faculty_id IS NOT NULL THEN
        INSERT INTO public.organization_members (organization_id, user_id, role_id)
        SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Students')
        FROM public.organizations 
        WHERE type = 'faculty-based' AND faculty_id = v_faculty_id
        ON CONFLICT DO NOTHING;
    END IF;

    IF v_program_id IS NOT NULL THEN
        INSERT INTO public.organization_members (organization_id, user_id, role_id)
        SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Students')
        FROM public.organizations 
        WHERE type = 'program-based' AND program_id = v_program_id
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN new;
EXCEPTION WHEN OTHERS THEN
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==============================================================================
-- 11. DATA SEEDING
-- ==============================================================================

-- 1. INSERT CAMPUSES
INSERT INTO campuses (name, location) VALUES ('DORSU Main Campus', 'Mati City, Davao Oriental');

-- 2. INSERT FACULTIES
INSERT INTO faculties (campus_id, name, code) VALUES
((SELECT id FROM campuses WHERE name = 'DORSU Main Campus'), 'Faculty of Nursing and Allied Health Sciences', 'FNAHS'),
((SELECT id FROM campuses WHERE name = 'DORSU Main Campus'), 'Faculty of Agriculture and Life Sciences', 'FALS'),
((SELECT id FROM campuses WHERE name = 'DORSU Main Campus'), 'Faculty of Business and Management', 'FBM'),
((SELECT id FROM campuses WHERE name = 'DORSU Main Campus'), 'Faculty of Computing, Engineering and Technology', 'FaCET'),
((SELECT id FROM campuses WHERE name = 'DORSU Main Campus'), 'Faculty of Teacher Education', 'FTED'),
((SELECT id FROM campuses WHERE name = 'DORSU Main Campus'), 'Faculty of Humanities, Social Sciences, and Communication', 'FHuSoCom'),
((SELECT id FROM campuses WHERE name = 'DORSU Main Campus'), 'Faculty of Criminal Justice Education', 'FCJE');

-- 3. INSERT PROGRAMS
INSERT INTO programs (faculty_id, name, code) VALUES
((SELECT id FROM faculties WHERE code = 'FNAHS'), 'Bachelor of Science in Nursing', 'BSN'),
((SELECT id FROM faculties WHERE code = 'FALS'), 'Bachelor of Science in Agribusiness Management', 'BSAM'),
((SELECT id FROM faculties WHERE code = 'FALS'), 'Bachelor of Agricultural Technology', 'BAT'),
((SELECT id FROM faculties WHERE code = 'FALS'), 'Bachelor of Science in Biology', 'BSBio'),
((SELECT id FROM faculties WHERE code = 'FALS'), 'Bachelor of Science in Environmental Science', 'BSES'),
((SELECT id FROM faculties WHERE code = 'FBM'), 'Bachelor of Science in Business Administration', 'BSBA'),
((SELECT id FROM faculties WHERE code = 'FBM'), 'Bachelor of Science in Hospitality Management', 'BSHM'),
((SELECT id FROM faculties WHERE code = 'FaCET'), 'Bachelor of Science in Civil Engineering', 'BSCE'),
((SELECT id FROM faculties WHERE code = 'FaCET'), 'Bachelor of Industrial Technology Management', 'BITM'),
((SELECT id FROM faculties WHERE code = 'FaCET'), 'Bachelor of Science in Information Technology', 'BSIT'),
((SELECT id FROM faculties WHERE code = 'FaCET'), 'Bachelor of Science in Mathematics with Research Statistics', 'BSMath'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Elementary Education', 'BEEd'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Early Childhood Education', 'BECEd'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Secondary Education major in Biological Sciences', 'BSEd-Bio'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Secondary Education major in English', 'BSEd-Eng'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Secondary Education major in Filipino', 'BSEd-Fil'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Secondary Education major in Mathematics', 'BSEd-Math'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Secondary Education major in Science', 'BSEd-Sci'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Physical Education major in School Physical Education', 'BPEd'),
((SELECT id FROM faculties WHERE code = 'FTED'), 'Bachelor of Special Needs Education', 'BSNEd'),
((SELECT id FROM faculties WHERE code = 'FCJE'), 'Bachelor of Science in Criminology', 'BSCrim'),
((SELECT id FROM faculties WHERE code = 'FHuSoCom'), 'Bachelor of Development Communication', 'BDevCom'),
((SELECT id FROM faculties WHERE code = 'FHuSoCom'), 'Bachelor of Arts in Political Science', 'ABPolSci'),
((SELECT id FROM faculties WHERE code = 'FHuSoCom'), 'Bachelor of Science in Psychology', 'BSPsych');

-- 4. INSERT ROLES
INSERT INTO roles (name, hierarchy_level) VALUES
('Super Admin', 100), ('Faculty Dean', 80), ('Program Head', 70), ('Instructor', 65), ('Comselec Chair', 60), 
('Governor', 50), ('Vice Governor', 45), ('Secretary', 40), ('Assistant Secretary', 35),
('Treasurer', 30), ('Assistant Treasurer', 25), ('Auditor', 20), ('PIO', 20),
('Business Manager', 20), ('Representative', 15), ('Staff', 10), ('Students', 5);

-- 5. INSERT PERMISSIONS
INSERT INTO permissions (action) VALUES
('manage_academic_terms'), ('manage_faculties'), ('manage_programs'),
('assign_roles'), ('revoke_roles'), ('create_event'), ('edit_event'),
('delete_event'), ('scan_event_attendance'), ('override_attendance'),
('create_fee'), ('edit_fee'), ('delete_fee'), ('manage_payment_receivers'),
('verify_payment'), ('reject_payment'), ('request_clearance'),
('sign_faculty_clearance'), ('sign_program_clearance'), ('sign_comselec_clearance'), 
('reject_clearance'), ('view_clearance_dashboard'), ('create_sanction_rules'),
('edit_sanction_rules'), ('delete_sanction_rules'), ('receive_sanction_items'),
('manage_elections'), ('view_election_analytics'), ('view_program_analytics'),
('view_faculty_analytics'), ('create_announcement'), ('edit_announcement'), ('delete_announcement');

-- 6. MAP PERMISSIONS TO ROLES
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Super Admin' AND p.action IN ('manage_academic_terms', 'manage_faculties', 'manage_programs', 'assign_roles', 'revoke_roles', 'view_faculty_analytics', 'view_program_analytics', 'manage_elections');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Students' AND p.action IN ('request_clearance');

-- 7. MAP PERMISSIONS FOR OFFICERS (Governor, Treasurer, etc.)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN ('Governor', 'Vice Governor') 
AND p.action IN ('create_event', 'edit_event', 'delete_event', 'scan_event_attendance', 'override_attendance', 'create_fee', 'edit_fee', 'delete_fee', 'view_clearance_dashboard', 'reject_clearance', 'manage_payment_receivers', 'create_announcement', 'edit_announcement', 'delete_announcement');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN ('Treasurer', 'Assistant Treasurer') 
AND p.action IN ('create_fee', 'edit_fee', 'delete_fee', 'verify_payment', 'reject_payment', 'manage_payment_receivers', 'create_announcement', 'edit_announcement', 'delete_announcement');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN ('Secretary', 'Assistant Secretary') 
AND p.action IN ('create_event', 'edit_event', 'scan_event_attendance', 'create_announcement', 'edit_announcement', 'delete_announcement');

-- 8. SUPER ADMIN SEED
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO auth.users (
instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, is_super_admin
) VALUES (
'00000000-0000-0000-0000-000000000000', 'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c', 'authenticated', 'authenticated', 'vouch.app.admin@gmail.com', crypt('Admin-2026', gen_salt('bf')), current_timestamp, '{"provider":"email","providers":["email"]}', '{"full_name":"Vouch Admin"}', current_timestamp, current_timestamp, '', '', '', false
) ON CONFLICT (id) DO NOTHING;

INSERT INTO auth.identities (
id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
) VALUES (
'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c', 'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c', 'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c', format('{"sub":"%s","email":"%s"}','cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c','vouch.app.admin@gmail.com')::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.users (auth_id, student_id_number, first_name, last_name, email, account_status)
VALUES ('cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c', 'SA-2026-001', 'Vouch', 'Admin', 'vouch.app.admin@gmail.com', 'active')
ON CONFLICT (auth_id) DO UPDATE SET student_id_number = EXCLUDED.student_id_number, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, account_status = EXCLUDED.account_status;

INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id) 
SELECT u.id, r.id, 'Institutional', '00000000-0000-0000-0000-000000000000'
FROM public.users u CROSS JOIN public.roles r
WHERE u.email = 'vouch.app.admin@gmail.com' AND r.name = 'Super Admin'
AND NOT EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = u.id AND ur.role_id = r.id);

UPDATE auth.users SET email_change = '' WHERE email_change IS NULL;
