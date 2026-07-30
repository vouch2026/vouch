-- ==========================================
-- VOUCH CORE SCHEMA (v2 Final - Fully Optimized)
-- ==========================================
-- ==========================================
-- VOUCH TEARDOWN SCRIPT
-- ==========================================

-- 1. Drop all tables (CASCADE handles foreign key dependencies)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Wrap in DO block to avoid error if tables don't exist yet
DO $$ 
BEGIN
    IF to_regclass('public.organizations') IS NOT NULL THEN
        DROP TRIGGER IF EXISTS on_organization_created ON public.organizations;
    END IF;
    IF to_regclass('public.comselecs') IS NOT NULL THEN
        DROP TRIGGER IF EXISTS on_comselec_created ON public.comselecs;
    END IF;
    IF to_regclass('public.faculties') IS NOT NULL THEN
        DROP TRIGGER IF EXISTS on_faculty_dean_changed ON public.faculties;
        DROP TRIGGER IF EXISTS on_faculty_deleted ON public.faculties;
    END IF;
    IF to_regclass('public.programs') IS NOT NULL THEN
        DROP TRIGGER IF EXISTS on_program_head_changed ON public.programs;
        DROP TRIGGER IF EXISTS on_program_deleted ON public.programs;
    END IF;
END $$;

DROP FUNCTION IF EXISTS public.handle_new_organization() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_comselec() CASCADE;
DROP FUNCTION IF EXISTS public.handle_faculty_dean_change() CASCADE;
DROP FUNCTION IF EXISTS public.handle_program_head_change() CASCADE;
DROP FUNCTION IF EXISTS public.handle_faculty_deletion() CASCADE;
DROP FUNCTION IF EXISTS public.handle_program_deletion() CASCADE;
DROP FUNCTION IF EXISTS public.get_my_workspaces() CASCADE;
DROP FUNCTION IF EXISTS public.get_workspace_role_and_permissions(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.get_workspace_by_id(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.reset_academic_year_data() CASCADE;


-- Drop legacy profiles table if it exists
DROP TABLE IF EXISTS public.profiles CASCADE;

DROP TABLE IF EXISTS public.tasks CASCADE;
DROP TABLE IF EXISTS public.subject_schedules CASCADE;
DROP TABLE IF EXISTS excuse_requests CASCADE;
DROP TABLE IF EXISTS governance_audit_logs CASCADE;
DROP TABLE IF EXISTS public.account_deletion_requests CASCADE;

DROP TABLE IF EXISTS activity_card_clearance_signatures CASCADE;
DROP TABLE IF EXISTS activity_card_clearance_requests CASCADE;
DROP TABLE IF EXISTS student_sanction_records CASCADE;
DROP TABLE IF EXISTS announcements CASCADE;
DROP TABLE IF EXISTS student_payments CASCADE;
DROP TABLE IF EXISTS payment_receiver CASCADE;
DROP TABLE IF EXISTS student_attendance CASCADE;
DROP TABLE IF EXISTS sanction_rules CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS fees CASCADE;
DROP TABLE IF EXISTS comselec_members CASCADE;
DROP TABLE IF EXISTS organization_members CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS permissions CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS public.comselec_settings CASCADE;
DROP TABLE IF EXISTS public.organization_settings CASCADE;
DROP TABLE IF EXISTS comselecs CASCADE;
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

-- Robustly drop all versions of the comselec creation function
DO $$ 
DECLARE
    _sql text;
BEGIN
    SELECT 'DROP FUNCTION ' || string_agg(oid::regprocedure::text, '; DROP FUNCTION ')
    FROM pg_proc 
    WHERE proname = 'create_comselec_with_members' 
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
banner_url VARCHAR(2048),
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
logo_url VARCHAR(2048),
banner_url VARCHAR(2048),
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
logo_url VARCHAR(2048),
banner_url VARCHAR(2048),
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_programs_updated_at BEFORE UPDATE ON programs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Circular Reference handling
ALTER TABLE users ADD COLUMN campus_id UUID REFERENCES campuses(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN faculty_id UUID REFERENCES faculties(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN program_id UUID REFERENCES programs(id) ON DELETE SET NULL;
ALTER TABLE campuses ADD COLUMN osa_head_id UUID REFERENCES users(id) ON DELETE SET NULL;

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
adviser_name VARCHAR(255),
status VARCHAR(20) DEFAULT 'active',
type VARCHAR(50) DEFAULT 'campus-based',
campus_id UUID REFERENCES campuses(id) ON DELETE SET NULL,
faculty_id UUID REFERENCES faculties(id) ON DELETE SET NULL,
program_id UUID REFERENCES programs(id) ON DELETE SET NULL,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.organization_settings (
organization_id UUID PRIMARY KEY REFERENCES public.organizations(id) ON DELETE CASCADE,
requires_adviser_signature BOOLEAN NOT NULL DEFAULT FALSE,
requires_dean_signature BOOLEAN NOT NULL DEFAULT FALSE,
requires_program_head_signature BOOLEAN NOT NULL DEFAULT FALSE,
allow_member_to_print BOOLEAN NOT NULL DEFAULT FALSE,
restrict_clearance_request BOOLEAN NOT NULL DEFAULT FALSE,
clearance_period_start TIMESTAMPTZ,
clearance_period_end TIMESTAMPTZ,
created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_organization_settings_updated_at BEFORE UPDATE ON public.organization_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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
auto_sign_clearance BOOLEAN DEFAULT false,
UNIQUE(organization_id, user_id)
);

-- ==========================================
-- 4b. COMSELEC ENTITIES
-- ==========================================

CREATE TABLE comselecs (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name VARCHAR(255) NOT NULL,
code VARCHAR(50) NOT NULL UNIQUE,
description TEXT,
logo_url VARCHAR(2048),
banner_url VARCHAR(2048),
campus_id UUID REFERENCES campuses(id) ON DELETE SET NULL,
status VARCHAR(20) DEFAULT 'active',
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_comselecs_updated_at BEFORE UPDATE ON comselecs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.comselec_settings (
comselec_id UUID PRIMARY KEY REFERENCES public.comselecs(id) ON DELETE CASCADE,
requires_chairman_signature BOOLEAN NOT NULL DEFAULT FALSE,
requires_commissioner_signature BOOLEAN NOT NULL DEFAULT FALSE,
allow_member_to_print BOOLEAN NOT NULL DEFAULT FALSE,
clearance_period_start TIMESTAMPTZ,
clearance_period_end TIMESTAMPTZ,
created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_comselec_settings_updated_at BEFORE UPDATE ON public.comselec_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE comselec_members (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
comselec_id UUID NOT NULL REFERENCES comselecs(id) ON DELETE CASCADE,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
role_id UUID REFERENCES roles(id) ON DELETE SET NULL,
academic_term_id UUID REFERENCES academic_terms(id) ON DELETE SET NULL,
status VARCHAR(20) DEFAULT 'active', -- active, expired, pending, removed, archived
assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
expired_at TIMESTAMP WITH TIME ZONE,
joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
auto_sign_clearance BOOLEAN DEFAULT false,
UNIQUE(comselec_id, user_id)
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
comselec_id UUID REFERENCES comselecs(id) ON DELETE CASCADE,
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
created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
created_by_organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL
);

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE announcements (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
title VARCHAR(255) NOT NULL,
content TEXT NOT NULL,
type VARCHAR(50) DEFAULT 'General',
link_urls TEXT[],
image_url VARCHAR(2048),
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL,
academic_term_id UUID NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL
);

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE sanction_rules (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL,
academic_term_id UUID NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT,
min_absence NUMERIC(3,1) NOT NULL DEFAULT 0,
max_absence NUMERIC(3,1),
sanction_type VARCHAR(50) NOT NULL DEFAULT 'Donation',
required_value DECIMAL(10,2),
item_description VARCHAR(255) NOT NULL, 
created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
CONSTRAINT unique_scope_term_min_absence UNIQUE(scope_id, academic_term_id, min_absence)
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
total_absences NUMERIC(3,1) NOT NULL,
required_item VARCHAR(255) NOT NULL, 
status sanction_status DEFAULT 'Pending Item',
received_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL, 
received_at TIMESTAMP WITH TIME ZONE,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
UNIQUE(student_id, scope_id, academic_term_id)
);

CREATE TRIGGER update_sanctions_updated_at BEFORE UPDATE ON student_sanction_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE INDEX idx_student_sanctions_student_id ON student_sanction_records(student_id);

-- ==========================================
-- 7. THE CLEARANCE WORKFLOW
-- ==========================================

CREATE TABLE activity_card_clearance_requests (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
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
ALTER TABLE activity_card_clearance_requests ADD CONSTRAINT unique_student_clearance_per_term UNIQUE (student_id, organization_id, academic_term_id);

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
ALTER TABLE public.organization_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE comselecs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comselec_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE comselec_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_sanction_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_card_clearance_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_card_clearance_signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_receiver ENABLE ROW LEVEL SECURITY;
ALTER TABLE governance_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sanction_rules ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- HELPER FUNCTIONS FOR RBAC
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

CREATE OR REPLACE FUNCTION public.get_my_id()
RETURNS UUID AS $$
    SELECT id FROM public.users WHERE auth_id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.has_scope_permission(p_action TEXT, p_scope_type public.scope_type, p_scope_id UUID) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT id INTO v_user_id FROM public.users WHERE auth_id = auth.uid();
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
CREATE POLICY "Officers can update their own organization details" ON public.organizations
  FOR UPDATE TO authenticated
  USING (
    public.is_super_admin() OR
    EXISTS (
      SELECT 1 FROM public.organization_members om
      WHERE om.user_id = public.get_my_id()
      AND om.organization_id = organizations.id
      AND om.role_id IS NOT NULL
      AND om.status = 'active'
    )
  );
CREATE POLICY "Super admins can manage academic terms" ON academic_terms FOR ALL TO authenticated USING (public.is_super_admin());

-- Organization Settings
CREATE POLICY "Organization settings are viewable by everyone" ON public.organization_settings FOR SELECT USING (true);
CREATE POLICY "Officers can manage organization settings" ON public.organization_settings
  FOR ALL TO authenticated
  USING (
    public.is_super_admin() OR
    EXISTS (
      SELECT 1 FROM public.organization_members om
      WHERE om.user_id = public.get_my_id()
      AND om.organization_id = organization_settings.organization_id
      AND om.role_id IS NOT NULL
      AND om.status = 'active'
    )
  );

-- Organization Members
CREATE POLICY "Members can view their own memberships" ON organization_members FOR SELECT 
USING (user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid()));
CREATE POLICY "Organization members are viewable by everyone" ON organization_members FOR SELECT USING (true);
CREATE POLICY "Super admins can manage organization memberships" ON organization_members FOR ALL TO authenticated USING (public.is_super_admin());

-- Comselecs
CREATE POLICY "Comselecs are viewable by everyone" ON comselecs FOR SELECT USING (true);
CREATE POLICY "Super admins can manage comselecs" ON comselecs FOR ALL TO authenticated USING (public.is_super_admin());
CREATE POLICY "Officers can update their own comselec details" ON public.comselecs
  FOR UPDATE TO authenticated
  USING (
    public.is_super_admin() OR
    EXISTS (
      SELECT 1 FROM public.comselec_members cm
      WHERE cm.user_id = public.get_my_id()
      AND cm.comselec_id = comselecs.id
      AND cm.role_id IS NOT NULL
      AND cm.status = 'active'
    )
  );

-- Comselec Settings
CREATE POLICY "Comselec settings are viewable by everyone" ON public.comselec_settings FOR SELECT USING (true);
CREATE POLICY "Officers can manage comselec settings" ON public.comselec_settings
  FOR ALL TO authenticated
  USING (
    public.is_super_admin() OR
    EXISTS (
      SELECT 1 FROM public.comselec_members cm
      WHERE cm.user_id = public.get_my_id()
      AND cm.comselec_id = comselec_settings.comselec_id
      AND cm.role_id IS NOT NULL
      AND cm.status = 'active'
    )
  );

-- Comselec Members
CREATE POLICY "Members can view their own comselec memberships" ON comselec_members FOR SELECT 
USING (user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid()));
CREATE POLICY "Comselec members are viewable by everyone" ON comselec_members FOR SELECT USING (true);
CREATE POLICY "Super admins can manage comselec memberships" ON comselec_members FOR ALL TO authenticated USING (public.is_super_admin());

-- Events
CREATE POLICY "Events are viewable by everyone" ON events FOR SELECT USING (true);
CREATE POLICY "Officers can create events" ON events FOR INSERT TO authenticated
WITH CHECK (public.has_scope_permission('create_event', events.scope_type, events.scope_id));
CREATE POLICY "Officers can update events" ON events FOR UPDATE TO authenticated
USING (public.has_scope_permission('edit_event', events.scope_type, events.scope_id));
CREATE POLICY "Officers can delete events" ON events FOR DELETE TO authenticated
USING (public.has_scope_permission('delete_event', events.scope_type, events.scope_id));

-- Announcements
CREATE POLICY "Announcements are viewable by everyone" ON announcements FOR SELECT USING (true);
CREATE POLICY "Officers can create announcements" ON announcements FOR INSERT TO authenticated
WITH CHECK (public.has_scope_permission('create_announcement', announcements.scope_type, announcements.scope_id));
CREATE POLICY "Officers can update announcements" ON announcements FOR UPDATE TO authenticated
USING (public.has_scope_permission('edit_announcement', announcements.scope_type, announcements.scope_id));
CREATE POLICY "Officers can delete announcements" ON announcements FOR DELETE TO authenticated
USING (public.has_scope_permission('delete_announcement', announcements.scope_type, announcements.scope_id));

-- Fees
CREATE POLICY "Fees are viewable by everyone" ON fees FOR SELECT USING (true);
CREATE POLICY "Officers can create fees" ON fees FOR INSERT TO authenticated
WITH CHECK (public.has_scope_permission('create_fee', fees.scope_type, fees.scope_id));
CREATE POLICY "Officers can update fees" ON fees FOR UPDATE TO authenticated
USING (public.has_scope_permission('edit_fee', fees.scope_type, fees.scope_id));
CREATE POLICY "Officers can delete fees" ON fees FOR DELETE TO authenticated
USING (public.has_scope_permission('delete_fee', fees.scope_type, fees.scope_id));

-- Payment Receivers
CREATE POLICY "Payment receivers are viewable by everyone" ON payment_receiver FOR SELECT USING (true);
CREATE POLICY "Officers can manage payment receivers" ON payment_receiver FOR ALL TO authenticated
USING (public.has_scope_permission('manage_payment_receivers', payment_receiver.scope_type, payment_receiver.scope_id));

-- Attendance
CREATE POLICY "Students can view their own attendance" ON student_attendance FOR SELECT 
USING (student_id = public.get_my_id());
CREATE POLICY "Officers can view attendance in their scope" ON student_attendance FOR SELECT 
USING (EXISTS (SELECT 1 FROM events e WHERE e.id = event_id AND public.has_scope_permission('view_events', e.scope_type, e.scope_id)));
CREATE POLICY "Deans and Program Heads can view all attendance" ON student_attendance FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.programs pr
    WHERE pr.program_head_id = public.get_my_id()
  )
  OR
  EXISTS (
    SELECT 1 FROM public.faculties f
    WHERE f.dean_id = public.get_my_id()
  )
);
CREATE POLICY "Officers can scan attendance" ON student_attendance FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM events e 
    WHERE e.id = event_id 
    AND public.has_scope_permission('scan_event_attendance', e.scope_type, e.scope_id)
  )
  AND scanned_by_user_id = public.get_my_id()
);
CREATE POLICY "Officers can scan attendance update" ON student_attendance FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM events e 
    WHERE e.id = event_id 
    AND public.has_scope_permission('scan_event_attendance', e.scope_type, e.scope_id)
  )
)
WITH CHECK (
  scanned_by_user_id = public.get_my_id()
);
CREATE POLICY "Officers can override attendance" ON student_attendance FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM events e WHERE e.id = event_id AND public.has_scope_permission('override_attendance', e.scope_type, e.scope_id)));

-- Payments
CREATE POLICY "Students can view their own payments" ON student_payments FOR SELECT 
USING (student_id = public.get_my_id());
CREATE POLICY "Officers can view payments in their scope" ON student_payments FOR SELECT 
USING (EXISTS (SELECT 1 FROM fees f WHERE f.id = fee_id AND public.has_scope_permission('view_fees', f.scope_type, f.scope_id)));
CREATE POLICY "Deans and Program Heads can view all payments" ON student_payments FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.programs pr
    WHERE pr.program_head_id = public.get_my_id()
  )
  OR
  EXISTS (
    SELECT 1 FROM public.faculties f
    WHERE f.dean_id = public.get_my_id()
  )
);
CREATE POLICY "Students can submit payments" ON student_payments FOR INSERT TO authenticated
WITH CHECK (student_id = public.get_my_id());
CREATE POLICY "Officers can verify payments" ON student_payments FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM fees f WHERE f.id = fee_id AND public.has_scope_permission('verify_payment', f.scope_type, f.scope_id)));

-- Sanction Records
CREATE POLICY "Students can view their own sanctions" ON student_sanction_records FOR SELECT 
USING (student_id = public.get_my_id());
CREATE POLICY "Officers can view sanctions in their scope" ON student_sanction_records FOR SELECT 
USING (public.has_scope_permission('view_activity_cards', scope_type, scope_id));
CREATE POLICY "Deans and Program Heads can view all sanctions" ON student_sanction_records FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.programs pr
    WHERE pr.program_head_id = public.get_my_id()
  )
  OR
  EXISTS (
    SELECT 1 FROM public.faculties f
    WHERE f.dean_id = public.get_my_id()
  )
);
CREATE POLICY "Officers can manage sanctions" ON student_sanction_records FOR ALL TO authenticated
USING (public.has_scope_permission('receive_sanction_items', scope_type, scope_id));

-- Clearance Requests
CREATE POLICY "Students can view their own clearance requests" ON activity_card_clearance_requests FOR SELECT 
USING (student_id = public.get_my_id());
CREATE POLICY "Officers can view clearance requests for their organization" ON activity_card_clearance_requests FOR SELECT 
USING (EXISTS (SELECT 1 FROM organization_members om WHERE om.user_id = public.get_my_id() AND om.organization_id = activity_card_clearance_requests.organization_id AND om.role_id IS NOT NULL));
CREATE POLICY "Officers can view all clearance requests" ON activity_card_clearance_requests FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.organization_members om WHERE om.user_id = public.get_my_id() AND om.role_id IS NOT NULL) OR EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = public.get_my_id() AND ur.is_active = true));
CREATE POLICY "Students can request clearance" ON activity_card_clearance_requests FOR INSERT TO authenticated
WITH CHECK (student_id = public.get_my_id());
CREATE POLICY "Officers can update clearance status" ON activity_card_clearance_requests FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM organization_members om WHERE om.user_id = public.get_my_id() AND om.organization_id = activity_card_clearance_requests.organization_id AND om.role_id IS NOT NULL));
CREATE POLICY "Students can update their own rejected clearance requests" ON activity_card_clearance_requests FOR UPDATE TO authenticated
USING (student_id = public.get_my_id() AND status = 'Rejected')
WITH CHECK (student_id = public.get_my_id() AND status = 'Pending');

-- Clearance Signatures
CREATE POLICY "Users can view signatures for their own requests" ON activity_card_clearance_signatures FOR SELECT 
USING (EXISTS (SELECT 1 FROM activity_card_clearance_requests r WHERE r.id = clearance_request_id AND (r.student_id = public.get_my_id() OR EXISTS (SELECT 1 FROM organization_members om WHERE om.user_id = public.get_my_id() AND om.organization_id = r.organization_id AND om.role_id IS NOT NULL))));
CREATE POLICY "Officers can view all clearance signatures" ON activity_card_clearance_signatures FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.organization_members om WHERE om.user_id = public.get_my_id() AND om.role_id IS NOT NULL) OR EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = public.get_my_id() AND ur.is_active = true));
CREATE POLICY "Students can insert signatures for their own requests" ON activity_card_clearance_signatures FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM activity_card_clearance_requests r WHERE r.id = clearance_request_id AND r.student_id = public.get_my_id()));
CREATE POLICY "Officers can sign slots" ON activity_card_clearance_signatures FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM organization_members om WHERE om.user_id = public.get_my_id() AND om.role_id = required_role_id AND om.organization_id = (SELECT organization_id FROM activity_card_clearance_requests WHERE id = clearance_request_id)));
CREATE POLICY "Deans and Program Heads can sign slots" ON activity_card_clearance_signatures FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = public.get_my_id() AND ur.role_id = required_role_id AND ur.scope_id = required_scope_id AND ur.is_active = true));
CREATE POLICY "Students can update their own rejected signatures" ON activity_card_clearance_signatures FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.activity_card_clearance_requests r WHERE r.id = clearance_request_id AND r.student_id = public.get_my_id() AND (r.status = 'Rejected' OR r.status = 'Pending')))
WITH CHECK (status = 'Pending' AND signed_by_user_id IS NULL AND signed_at IS NULL AND remarks IS NULL);

-- Sanction Rules
CREATE POLICY "Sanction rules are viewable by everyone" ON sanction_rules FOR SELECT USING (true);
CREATE POLICY "Officers can manage sanction rules" ON sanction_rules FOR ALL TO authenticated
USING (public.has_scope_permission('create_sanction_rules', scope_type, scope_id));

-- Audit Logs
CREATE POLICY "Audit logs are viewable by officers" ON governance_audit_logs FOR SELECT TO authenticated
USING (
    public.is_super_admin() OR 
    EXISTS (SELECT 1 FROM organization_members om WHERE om.user_id = public.get_my_id() AND om.organization_id = governance_audit_logs.organization_id AND om.role_id IS NOT NULL) OR
    EXISTS (SELECT 1 FROM comselec_members cm WHERE cm.user_id = public.get_my_id() AND cm.comselec_id = governance_audit_logs.comselec_id AND cm.role_id IS NOT NULL)
);

-- ------------------------------------------------------------
-- SYSTEM & EXTERNAL SERVICE GRANTS (e.g. Supabase Storage)
-- ------------------------------------------------------------
-- Grant schema usage permissions
GRANT USAGE ON SCHEMA public, auth TO anon, authenticated, supabase_storage_admin;

-- Grant SELECT on all public tables to authenticated, anonymous, and storage manager roles
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated, anon, supabase_storage_admin;

-- Grant SELECT on auth.users in case storage policies/triggers reference it directly
GRANT SELECT ON auth.users TO authenticated, anon, supabase_storage_admin;

-- Ensure all future tables automatically grant SELECT to authenticated, anon, and supabase_storage_admin
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO authenticated, anon, supabase_storage_admin;

-- ------------------------------------------------------------
-- SUPABASE STORAGE BUCKETS & POLICIES (e.g. Org Pictures)
-- ------------------------------------------------------------
-- Create the org-pictures bucket if it does not already exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('org-pictures', 'org-pictures', true)
ON CONFLICT (id) DO NOTHING;

-- Policy: Allow anyone (public) to view/read organization pictures
DROP POLICY IF EXISTS "Allow public select on org pictures" ON storage.objects;
CREATE POLICY "Allow public select on org pictures" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'org-pictures');

-- Policy: Allow officers and super admins to upload new pictures (INSERT)
DROP POLICY IF EXISTS "Allow officers and super admins to upload org pictures" ON storage.objects;
CREATE POLICY "Allow officers and super admins to upload org pictures" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'org-pictures' AND
    (
      public.is_super_admin() OR
      EXISTS (
        SELECT 1 FROM public.organizations o
        JOIN public.organization_members om ON om.organization_id = o.id
        WHERE LOWER(o.code) = LOWER(split_part(split_part(storage.objects.name, '/', 2), '_', 2))
          AND om.user_id = public.get_my_id()
          AND om.role_id IS NOT NULL
          AND om.status = 'active'
      ) OR
      EXISTS (
        SELECT 1 FROM public.comselecs c
        JOIN public.comselec_members cm ON cm.comselec_id = c.id
        WHERE LOWER(c.code) = LOWER(split_part(split_part(storage.objects.name, '/', 2), '_', 2))
          AND cm.user_id = public.get_my_id()
          AND cm.role_id IS NOT NULL
          AND cm.status = 'active'
      )
    )
  );

-- Policy: Allow officers and super admins to overwrite/update pictures (UPDATE)
DROP POLICY IF EXISTS "Allow officers and super admins to update org pictures" ON storage.objects;
CREATE POLICY "Allow officers and super admins to update org pictures" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'org-pictures' AND
    (
      public.is_super_admin() OR
      EXISTS (
        SELECT 1 FROM public.organizations o
        JOIN public.organization_members om ON om.organization_id = o.id
        WHERE LOWER(o.code) = LOWER(split_part(split_part(storage.objects.name, '/', 2), '_', 2))
          AND om.user_id = public.get_my_id()
          AND om.role_id IS NOT NULL
          AND om.status = 'active'
      ) OR
      EXISTS (
        SELECT 1 FROM public.comselecs c
        JOIN public.comselec_members cm ON cm.comselec_id = c.id
        WHERE LOWER(c.code) = LOWER(split_part(split_part(storage.objects.name, '/', 2), '_', 2))
          AND cm.user_id = public.get_my_id()
          AND cm.role_id IS NOT NULL
          AND cm.status = 'active'
      )
    )
  );

-- Policy: Allow officers and super admins to delete pictures (DELETE)
DROP POLICY IF EXISTS "Allow officers and super admins to delete org pictures" ON storage.objects;
CREATE POLICY "Allow officers and super admins to delete org pictures" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'org-pictures' AND
    (
      public.is_super_admin() OR
      EXISTS (
        SELECT 1 FROM public.organizations o
        JOIN public.organization_members om ON om.organization_id = o.id
        WHERE LOWER(o.code) = LOWER(split_part(split_part(storage.objects.name, '/', 2), '_', 2))
          AND om.user_id = public.get_my_id()
          AND om.role_id IS NOT NULL
          AND om.status = 'active'
      ) OR
      EXISTS (
        SELECT 1 FROM public.comselecs c
        JOIN public.comselec_members cm ON cm.comselec_id = c.id
        WHERE LOWER(c.code) = LOWER(split_part(split_part(storage.objects.name, '/', 2), '_', 2))
          AND cm.user_id = public.get_my_id()
          AND cm.role_id IS NOT NULL
          AND cm.status = 'active'
      )
    )
  );

-- ==============================================================================
-- 9. FUNCTIONS & PROCEDURES
-- ==============================================================================

CREATE OR REPLACE FUNCTION assign_organization_officer(
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

    -- 1. Insert or Update membership (Organization Context)
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
            'scope_type', v_scope_type,
            'scope_id', v_scope_id,
            'expired_at', p_expired_at
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION assign_comselec_officer(
    p_comselec_id UUID,
    p_user_id UUID,
    p_role_id UUID,
    p_term_id UUID,
    p_assigned_by UUID
) RETURNS VOID AS $$
DECLARE
    v_actual_assigned_by_id UUID;
    v_actual_user_id UUID;
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

    -- 1. Insert or Update membership (Comselec Context)
    INSERT INTO comselec_members (comselec_id, user_id, role_id, academic_term_id, status)
    VALUES (p_comselec_id, v_actual_user_id, p_role_id, p_term_id, 'active')
    ON CONFLICT (comselec_id, user_id) 
    DO UPDATE SET 
        role_id = EXCLUDED.role_id,
        academic_term_id = EXCLUDED.academic_term_id,
        status = 'active',
        assigned_at = CURRENT_TIMESTAMP;

    -- 2. Log the action
    INSERT INTO governance_audit_logs (comselec_id, action, performed_by_user_id, target_user_id, details)
    VALUES (
        p_comselec_id, 
        'assign_comselec_officer', 
        v_actual_assigned_by_id, 
        v_actual_user_id, 
        jsonb_build_object(
            'role_id', p_role_id,
            'term_id', p_term_id
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

        -- Syncing to user_roles is disabled to keep organization roles independent from system roles
        /*
        IF v_scope_id IS NOT NULL THEN
            INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
            VALUES (v_rec.user_id, v_rec.role_id, v_scope_type, v_scope_id)
            ON CONFLICT (user_id, role_id, scope_type, scope_id) 
            DO UPDATE SET is_active = true;
        END IF;
        */
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
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT v_org_id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
        FROM public.users u
        JOIN public.user_roles ur ON u.id = ur.user_id
        JOIN public.roles r ON ur.role_id = r.id
        WHERE u.campus_id = p_campus_id
          AND r.name = 'Students'
          AND ur.is_active = true
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'faculty-based' AND p_faculty_id IS NOT NULL THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT v_org_id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
        FROM public.users u
        JOIN public.user_roles ur ON u.id = ur.user_id
        JOIN public.roles r ON ur.role_id = r.id
        WHERE u.faculty_id = p_faculty_id
          AND r.name = 'Students'
          AND ur.is_active = true
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'program-based' AND p_program_ids IS NOT NULL AND array_length(p_program_ids, 1) > 0 THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT v_org_id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
        FROM public.users u
        JOIN public.user_roles ur ON u.id = ur.user_id
        JOIN public.roles r ON ur.role_id = r.id
        WHERE u.program_id = ANY(p_program_ids)
          AND r.name = 'Students'
          AND ur.is_active = true
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN v_org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION create_comselec_with_members(
    p_name TEXT,
    p_code TEXT,
    p_description TEXT,
    p_campus_id UUID DEFAULT NULL,
    p_logo_url TEXT DEFAULT NULL,
    p_banner_url TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_comselec_id UUID;
BEGIN
    INSERT INTO comselecs (name, code, description, campus_id, logo_url, banner_url)
    VALUES (p_name, p_code, p_description, p_campus_id, p_logo_url, p_banner_url)
    RETURNING id INTO v_comselec_id;

    -- Automatically assign comselec chair and commissioners from user_roles
    INSERT INTO comselec_members (comselec_id, user_id, role_id)
    SELECT v_comselec_id, ur.user_id, ur.role_id
    FROM public.user_roles ur
    JOIN public.roles r ON ur.role_id = r.id
    WHERE r.name IN ('Comselec Chair', 'COMSELEC Commissioner')
      AND ur.scope_id = p_campus_id
      AND ur.is_active = true
    ON CONFLICT DO NOTHING;

    -- Also automatically assign all students on this campus as Voters
    INSERT INTO comselec_members (comselec_id, user_id, role_id)
    SELECT v_comselec_id, u.id, (SELECT id FROM public.roles WHERE name = 'Voters')
    FROM public.users u
    WHERE u.campus_id = p_campus_id
      AND EXISTS (
          SELECT 1 FROM public.user_roles ur 
          JOIN public.roles r ON ur.role_id = r.id 
          WHERE ur.user_id = u.id 
            AND r.name = 'Students' 
            AND ur.is_active = true
      )
    ON CONFLICT DO NOTHING;

    RETURN v_comselec_id;
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
        campus_id, faculty_id, program_id, year, account_status
    )
    VALUES (
        new.id, new.email, 
        COALESCE(new.raw_user_meta_data->>'first_name', ''),
        COALESCE(new.raw_user_meta_data->>'last_name', ''), 
        COALESCE(NULLIF(new.raw_user_meta_data->>'school_id', ''), 'PENDING-' || substr(new.id::text, 1, 8)),
        v_campus_id, v_faculty_id, v_program_id,
        (NULLIF(new.raw_user_meta_data->>'year_level', ''))::int,
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
    ELSIF v_role = 'voter' OR v_role = 'voters' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Voters';
        v_scope_type := 'Program';
        v_scope_id := v_program_id;
    ELSIF v_role = 'personnel' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Personnel';
        v_scope_type := 'Faculty';
        v_scope_id := v_faculty_id;
    ELSIF v_role = 'comselec_chairman' OR v_role = 'comselec_chair' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Comselec Chair';
        v_scope_type := 'Institutional';
        v_scope_id := COALESCE(v_campus_id, '00000000-0000-0000-0000-000000000000'::uuid);
    ELSIF v_role = 'comselec_commissioner' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'COMSELEC Commissioner';
        v_scope_type := 'Institutional';
        v_scope_id := COALESCE(v_campus_id, '00000000-0000-0000-0000-000000000000'::uuid);
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

    -- Only auto-assign students to their respective organizations as Members
    IF v_role = 'student' THEN
        IF v_campus_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Member')
            FROM public.organizations 
            WHERE type = 'campus-based' AND campus_id = v_campus_id
            ON CONFLICT DO NOTHING;
        END IF;

        IF v_faculty_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Member')
            FROM public.organizations 
            WHERE type = 'faculty-based' AND faculty_id = v_faculty_id
            ON CONFLICT DO NOTHING;
        END IF;

        IF v_program_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Member')
            FROM public.organizations 
            WHERE type = 'program-based' AND program_id = v_program_id
            ON CONFLICT DO NOTHING;
        END IF;

        -- Automatically assign student as Voter in COMSELEC
        IF v_campus_id IS NOT NULL THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id)
            SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Voters')
            FROM public.comselecs 
            WHERE campus_id = v_campus_id
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;

    -- Auto-assign Comselec officers to their respective Comselec
    IF v_role IN ('comselec_chairman', 'comselec_chair', 'comselec_commissioner') THEN
        IF v_campus_id IS NOT NULL THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id)
            SELECT id, new_user_id, target_role_id
            FROM public.comselecs 
            WHERE campus_id = v_campus_id
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;

    RETURN new;
EXCEPTION WHEN OTHERS THEN
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_organization()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.organization_settings (organization_id)
    VALUES (NEW.id)
    ON CONFLICT (organization_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_organization_created
AFTER INSERT ON public.organizations
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_organization();

CREATE OR REPLACE FUNCTION public.handle_new_comselec()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.comselec_settings (comselec_id)
    VALUES (NEW.id)
    ON CONFLICT (comselec_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_comselec_created
AFTER INSERT ON public.comselecs
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_comselec();

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
('Super Admin', 100), ('Faculty Dean', 80), ('Program Head', 70), ('Instructor', 65), ('Adviser', 65), ('Comselec Chair', 60), 
('COMSELEC Commissioner', 58), ('Governor', 50), ('Vice Governor', 45), ('President', 50), ('Vice President', 45), 
('Secretary', 40), ('Assistant Secretary', 35), ('Treasurer', 30), ('Assistant Treasurer', 25), ('Auditor', 20), 
('PIO', 20), ('Business Manager', 20), ('Senator', 15), ('Representative', 15), ('Personnel', 10), ('Staff', 10), ('Member', 5), 
('Students', 5), ('Voters', 5)
ON CONFLICT (name) DO UPDATE SET hierarchy_level = EXCLUDED.hierarchy_level;

-- 5. INSERT PERMISSIONS
INSERT INTO permissions (action) VALUES
('manage_academic_terms'), ('manage_faculties'), ('manage_programs'),
('assign_roles'), ('revoke_roles'), ('create_event'), ('edit_event'),
('delete_event'), ('view_events'), ('scan_event_attendance'), ('override_attendance'),
('create_fee'), ('edit_fee'), ('delete_fee'), ('view_fees'), ('manage_payment_receivers'),
('verify_payment'), ('reject_payment'), ('manage_collections'), ('request_clearance'),
('sign_faculty_clearance'), ('sign_program_clearance'), ('sign_comselec_clearance'), 
('reject_clearance'), ('view_clearance_dashboard'), ('create_sanction_rules'),
('edit_sanction_rules'), ('delete_sanction_rules'), ('receive_sanction_items'),
('view_sanctions'),
('manage_elections'),
 ('view_election_analytics'), ('view_program_analytics'),
('view_faculty_analytics'), ('view_analytics'), ('manage_activity_cards'), ('view_activity_cards'),
('create_announcement'), ('edit_announcement'), ('delete_announcement'), ('view_announcements'),
('view_members'), ('view_officers'), ('manage_organization'), ('view_documents')
ON CONFLICT (action) DO NOTHING;

-- 6. MAP PERMISSIONS TO ROLES
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Super Admin' AND p.action IN ('manage_academic_terms', 'manage_faculties', 'manage_programs', 'assign_roles', 'revoke_roles', 'view_faculty_analytics', 'view_program_analytics', 'manage_elections', 'view_analytics', 'manage_organization', 'view_documents', 'view_activity_cards')
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN ('Students', 'Member', 'Voters') AND p.action IN ('request_clearance', 'view_events', 'view_announcements', 'view_fees', 'view_activity_cards', 'view_sanctions')
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- 7. MAP PERMISSIONS FOR OFFICERS (Governor, Treasurer, etc.)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN ('Governor', 'Vice Governor', 'President', 'Vice President') 
AND p.action IN (
    'create_event', 'edit_event', 'delete_event', 'view_events', 'scan_event_attendance', 'override_attendance', 
    'create_fee', 'edit_fee', 'delete_fee', 'view_fees', 'verify_payment', 'reject_payment', 'view_clearance_dashboard', 'reject_clearance', 
    'manage_payment_receivers', 'manage_collections', 'create_announcement', 'edit_announcement', 'delete_announcement', 
    'view_announcements', 'view_members', 'view_officers', 'manage_activity_cards', 'view_activity_cards', 'view_analytics', 'assign_roles', 'revoke_roles', 'manage_organization', 'view_documents',
    'create_sanction_rules', 'edit_sanction_rules', 'delete_sanction_rules', 'receive_sanction_items', 'view_sanctions'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN ('Treasurer', 'Assistant Treasurer') 
AND p.action IN (
    'create_fee', 'edit_fee', 'delete_fee', 'view_fees', 'verify_payment', 'reject_payment', 
    'manage_payment_receivers', 'manage_collections', 'create_announcement', 'edit_announcement', 
    'delete_announcement', 'view_events', 'view_announcements', 'manage_activity_cards', 'view_activity_cards', 'view_analytics', 'manage_organization'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN ('Secretary', 'Assistant Secretary') 
AND p.action IN (
    'create_event', 'edit_event', 'view_events', 'scan_event_attendance', 'create_announcement', 
    'edit_announcement', 'delete_announcement', 'view_announcements', 'view_members', 'manage_activity_cards', 'view_activity_cards', 'view_documents', 'view_analytics', 'manage_organization',
    'create_sanction_rules', 'edit_sanction_rules', 'delete_sanction_rules', 'receive_sanction_items', 'view_sanctions', 'view_fees'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- 8. MAP PERMISSIONS FOR COMSELEC AND PERSONNEL
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN ('Comselec Chair', 'COMSELEC Commissioner') 
AND p.action IN (
    'manage_elections', 'view_election_analytics', 'sign_comselec_clearance',
    'view_events', 'view_announcements', 'view_members', 'view_officers', 'view_documents'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Personnel' AND p.action IN ('view_events', 'view_announcements', 'view_documents')
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Adviser' AND p.action IN (
    'view_events', 'view_announcements', 'view_members', 'view_officers', 'view_documents', 'view_activity_cards', 'view_fees', 'view_sanctions'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- MAP PERMISSIONS FOR SENATOR
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Senator' AND p.action IN (
    'view_events', 'view_announcements', 'view_fees', 'view_activity_cards', 'view_sanctions', 'view_documents', 'view_analytics', 'request_clearance'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- MAP PERMISSIONS FOR AUDITOR
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Auditor' AND p.action IN (
    'view_events', 'view_fees'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- MAP PERMISSIONS FOR BUSINESS MANAGER
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Business Manager' AND p.action IN (
    'view_events', 'create_event', 'edit_event', 'view_announcements', 'create_announcement', 'edit_announcement', 'view_members', 'view_officers', 'view_fees', 'view_documents', 'view_analytics'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- MAP PERMISSIONS FOR REPRESENTATIVE
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Representative' AND p.action IN (
    'view_events', 'scan_event_attendance', 'view_announcements', 'view_fees', 'view_activity_cards', 'view_sanctions', 'request_clearance'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- MAP SCAN ATTENDANCE TO ALL OFFICER ROLES
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name IN (
  'Governor', 'Vice Governor', 'President', 'Vice President', 
  'Secretary', 'Assistant Secretary', 'Representative', 
  'Treasurer', 'Assistant Treasurer', 'Auditor', 'PIO', 
  'Business Manager', 'Senator', 'Adviser', 'Comselec Chair', 
  'COMSELEC Commissioner', 'Faculty Dean', 'Program Head', 'Super Admin'
) 
AND p.action = 'scan_event_attendance'
ON CONFLICT (role_id, permission_id) DO NOTHING;

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

-- Automatically sync any existing auth users to public.users to prevent profile loss when resetting schemas
INSERT INTO public.users (auth_id, student_id_number, first_name, last_name, email, account_status)
SELECT 
  id as auth_id,
  COALESCE(raw_user_meta_data->>'school_id', 'PENDING-' || substr(id::text, 1, 8)) as student_id_number,
  COALESCE(raw_user_meta_data->>'first_name', 'User') as first_name,
  COALESCE(raw_user_meta_data->>'last_name', '') as last_name,
  email,
  'active' as account_status
FROM auth.users
ON CONFLICT (auth_id) DO NOTHING;

-- ==========================================
-- 9. EXCUSE REQUESTS
-- ==========================================

CREATE TABLE IF NOT EXISTS excuse_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  reason VARCHAR(500) NOT NULL,
  supporting_document_url VARCHAR(2048) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'Pending',
  rejection_reason VARCHAR(255),
  scope_type scope_type NOT NULL,
  scope_id UUID NOT NULL,
  academic_term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE RESTRICT,
  submission_count INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  reviewed_by_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(student_id, event_id)
);

CREATE TRIGGER update_excuse_requests_updated_at BEFORE UPDATE ON excuse_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE excuse_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view their own excuses" ON excuse_requests
  FOR SELECT TO authenticated USING (student_id = public.get_my_id());

CREATE POLICY "Students can submit excuses" ON excuse_requests
  FOR INSERT TO authenticated WITH CHECK (student_id = public.get_my_id());

CREATE POLICY "Students can resubmit their excuses" ON excuse_requests
  FOR UPDATE TO authenticated
  USING (student_id = public.get_my_id() AND status = 'Rejected' AND submission_count < 2)
  WITH CHECK (student_id = public.get_my_id() AND status = 'Pending' AND submission_count = 2);

CREATE POLICY "Students can delete their own excuses" ON excuse_requests
  FOR DELETE TO authenticated USING (student_id = public.get_my_id() AND status = 'Pending');

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

-- ==========================================
-- 10. TASKS & SCHEDULES
-- ==========================================

-- Tasks Table
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS) for tasks
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS on tasks
CREATE POLICY "Allow users to read their own tasks" 
ON public.tasks
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Allow users to insert their own tasks" 
ON public.tasks
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to update their own tasks" 
ON public.tasks
FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to delete their own tasks" 
ON public.tasks
FOR DELETE 
USING (auth.uid() = user_id);

-- Subject Schedules Table
CREATE TABLE IF NOT EXISTS public.subject_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    subject_code TEXT NOT NULL,
    subject_name TEXT NOT NULL,
    teacher TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    days TEXT[] NOT NULL,
    room TEXT NOT NULL DEFAULT '',
    academic_term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS) for subject_schedules
ALTER TABLE public.subject_schedules ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS on subject_schedules
CREATE POLICY "Allow users to read their own schedules"
ON public.subject_schedules
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Allow users to insert their own schedules" 
ON public.subject_schedules
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to update their own schedules" 
ON public.subject_schedules
FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to delete their own schedules" 
ON public.subject_schedules
FOR DELETE 
USING (auth.uid() = user_id);

-- ==============================================================================
-- WORKSPACE EXPANSION ADDITIONS (FACULTY & PROGRAM WORKSPACES)
-- ==============================================================================

-- 1. Seed permissions for Faculty Dean & Program Head
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r, public.permissions p
WHERE r.name = 'Faculty Dean' 
AND p.action IN (
    'sign_faculty_clearance', 'reject_clearance', 'view_clearance_dashboard',
    'view_events', 'view_announcements', 'view_members', 'view_officers', 'view_documents', 'view_program_analytics',
    'create_sanction_rules', 'edit_sanction_rules', 'delete_sanction_rules', 'receive_sanction_items', 'view_sanctions'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r, public.permissions p
WHERE r.name = 'Program Head' 
AND p.action IN (
    'sign_program_clearance', 'reject_clearance', 'view_clearance_dashboard',
    'view_events', 'view_announcements', 'view_members', 'view_officers', 'view_program_analytics',
    'create_sanction_rules', 'edit_sanction_rules', 'delete_sanction_rules', 'receive_sanction_items', 'view_sanctions'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- 2. Automatic Role Synchronization Trigger Functions and Triggers
CREATE OR REPLACE FUNCTION public.handle_faculty_dean_change()
RETURNS TRIGGER AS $$
DECLARE
    role_id_var UUID;
BEGIN
    SELECT id INTO role_id_var FROM public.roles WHERE name = 'Faculty Dean';

    -- Remove role from old dean
    IF (TG_OP = 'UPDATE' AND OLD.dean_id IS DISTINCT FROM NEW.dean_id AND OLD.dean_id IS NOT NULL) THEN
        DELETE FROM public.user_roles 
        WHERE user_id = OLD.dean_id 
          AND role_id = role_id_var 
          AND scope_type = 'Faculty' 
          AND scope_id = OLD.id;
    END IF;

    -- Add role to new dean
    IF (NEW.dean_id IS NOT NULL AND (TG_OP = 'INSERT' OR OLD.dean_id IS DISTINCT FROM NEW.dean_id)) THEN
        INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
        VALUES (NEW.dean_id, role_id_var, 'Faculty', NEW.id)
        ON CONFLICT (user_id, role_id, scope_type, scope_id) DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_faculty_dean_changed
AFTER INSERT OR UPDATE OF dean_id ON public.faculties
FOR EACH ROW EXECUTE FUNCTION public.handle_faculty_dean_change();


CREATE OR REPLACE FUNCTION public.handle_program_head_change()
RETURNS TRIGGER AS $$
DECLARE
    role_id_var UUID;
BEGIN
    SELECT id INTO role_id_var FROM public.roles WHERE name = 'Program Head';

    -- Remove role from old program head
    IF (TG_OP = 'UPDATE' AND OLD.program_head_id IS DISTINCT FROM NEW.program_head_id AND OLD.program_head_id IS NOT NULL) THEN
        DELETE FROM public.user_roles 
        WHERE user_id = OLD.program_head_id 
          AND role_id = role_id_var 
          AND scope_type = 'Program' 
          AND scope_id = OLD.id;
    END IF;

    -- Add role to new program head
    IF (NEW.program_head_id IS NOT NULL AND (TG_OP = 'INSERT' OR OLD.program_head_id IS DISTINCT FROM NEW.program_head_id)) THEN
        INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
        VALUES (NEW.program_head_id, role_id_var, 'Program', NEW.id)
        ON CONFLICT (user_id, role_id, scope_type, scope_id) DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_program_head_changed
AFTER INSERT OR UPDATE OF program_head_id ON public.programs
FOR EACH ROW EXECUTE FUNCTION public.handle_program_head_change();


CREATE OR REPLACE FUNCTION public.handle_faculty_deletion()
RETURNS TRIGGER AS $$
DECLARE
    role_id_var UUID;
BEGIN
    SELECT id INTO role_id_var FROM public.roles WHERE name = 'Faculty Dean';
    DELETE FROM public.user_roles 
    WHERE role_id = role_id_var 
      AND scope_type = 'Faculty' 
      AND scope_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_faculty_deleted
AFTER DELETE ON public.faculties
FOR EACH ROW EXECUTE FUNCTION public.handle_faculty_deletion();


CREATE OR REPLACE FUNCTION public.handle_program_deletion()
RETURNS TRIGGER AS $$
DECLARE
    role_id_var UUID;
BEGIN
    SELECT id INTO role_id_var FROM public.roles WHERE name = 'Program Head';
    DELETE FROM public.user_roles 
    WHERE role_id = role_id_var 
      AND scope_type = 'Program' 
      AND scope_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_program_deleted
AFTER DELETE ON public.programs
FOR EACH ROW EXECUTE FUNCTION public.handle_program_deletion();


-- 3. Workspace and Role Retrieval Functions
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
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT public.get_my_id() INTO v_user_id;
    IF v_user_id IS NULL THEN
        RETURN;
    END IF;

    -- 1. Student Organizations where the user is an active member/officer
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

    -- 2. Faculty workspaces where the user is Dean
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

    -- 3. Program workspaces where the user is Program Head
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

    -- 4. COMSELEC workspaces where the user is an active member
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
    WHERE cm.user_id = v_user_id 
      AND cm.status = 'active'
      AND (cm.expired_at IS NULL OR cm.expired_at > CURRENT_TIMESTAMP);
END;
$$;


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
    v_member_role_id UUID;
    v_voter_role_id UUID;
BEGIN
    SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Member' LIMIT 1;
    SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Voters' LIMIT 1;

    -- Lazy cleanup of expired organization roles
    UPDATE public.organization_members
    SET role_id = v_member_role_id,
        expired_at = NULL,
        status = 'active'
    WHERE expired_at IS NOT NULL AND expired_at <= CURRENT_TIMESTAMP;

    -- Lazy cleanup of expired comselec roles
    UPDATE public.comselec_members
    SET role_id = v_voter_role_id,
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
            f.banner_url,
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
            p.banner_url,
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


-- ==============================================================================
-- 12. AUTOMATIC ACADEMIC YEAR RESET FUNCTIONALITY
-- ==============================================================================

-- Resets all roles, activity cards, events, and fees for a new academic year
CREATE OR REPLACE FUNCTION public.reset_academic_year_data()
RETURNS VOID AS $$
DECLARE
    v_member_role_id UUID;
    v_voter_role_id UUID;
BEGIN
    -- 1. Retrieve IDs of default student roles
    SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Member';
    SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Voters';

    -- 2. Delete adviser memberships (so they do not become standard student members)
    DELETE FROM public.organization_members
    WHERE role_id = (SELECT id FROM public.roles WHERE name = 'Adviser' LIMIT 1);

    -- 3. Reset student organization members to standard 'Member' role
    UPDATE public.organization_members
    SET role_id = v_member_role_id
    WHERE role_id IS DISTINCT FROM v_member_role_id;

    -- 3. Reset comselec members to standard 'Voters' role
    UPDATE public.comselec_members
    SET role_id = v_voter_role_id
    WHERE role_id IS DISTINCT FROM v_voter_role_id;

    -- 4. Delete transient officer roles from user_roles
    DELETE FROM public.user_roles
    WHERE role_id NOT IN (
        SELECT id FROM public.roles 
        WHERE name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Students', 'Voters')
    );

    -- 5. Clear adviser assignments on organizations
    UPDATE public.organizations
    SET adviser_name = NULL
    WHERE id IS NOT NULL;

    -- 6. Reset clearance periods in organization & comselec settings
    UPDATE public.organization_settings
    SET clearance_period_start = NULL,
        clearance_period_end = NULL,
        restrict_clearance_request = FALSE
    WHERE organization_id IS NOT NULL;

    UPDATE public.comselec_settings
    SET clearance_period_start = NULL,
        clearance_period_end = NULL
    WHERE comselec_id IS NOT NULL;

    -- 7. Delete clearance requests and signatures (Cascade deletes signature records)
    DELETE FROM public.activity_card_clearance_requests
    WHERE id IS NOT NULL;

    -- 8. Delete events, attendance, excuses (Cascade deletes attendance/excuses)
    DELETE FROM public.events
    WHERE id IS NOT NULL;

    -- 9. Delete fees & payments (Cascade deletes payments)
    DELETE FROM public.fees
    WHERE id IS NOT NULL;

    -- 10. Delete student sanctions and rules
    DELETE FROM public.student_sanction_records
    WHERE id IS NOT NULL;
    DELETE FROM public.sanction_rules
    WHERE id IS NOT NULL;

    -- 11. Delete announcements
    DELETE FROM public.announcements
    WHERE id IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Redefine single_active_term to trigger the academic year reset
CREATE OR REPLACE FUNCTION public.single_active_term()
RETURNS TRIGGER AS $$
DECLARE
    v_old_academic_year VARCHAR(20);
BEGIN
    IF NEW.is_active = TRUE THEN
        -- Get the academic year of the currently active term (prior to its deactivation)
        SELECT academic_year INTO v_old_academic_year
        FROM public.academic_terms
        WHERE is_active = TRUE AND id <> NEW.id
        LIMIT 1;

        -- Deactivate all other terms
        UPDATE public.academic_terms SET is_active = FALSE WHERE id <> NEW.id;

        -- Perform reset only if academic year changes
        IF v_old_academic_year IS NOT NULL AND v_old_academic_year <> NEW.academic_year THEN
            PERFORM public.reset_academic_year_data();
        ELSIF v_old_academic_year IS NOT NULL AND v_old_academic_year = NEW.academic_year THEN
            -- If academic year is the same (e.g. changing from 1st sem to 2nd sem),
            -- carry over the academic_term_id of all active officers/advisers to the new active term.
            UPDATE public.organization_members
            SET academic_term_id = NEW.id
            WHERE status = 'active'
              AND role_id IS NOT NULL
              AND academic_term_id IN (
                  SELECT id FROM public.academic_terms 
                  WHERE academic_year = NEW.academic_year AND id <> NEW.id
              );

            UPDATE public.comselec_members
            SET academic_term_id = NEW.id
            WHERE status = 'active'
              AND role_id IS NOT NULL
              AND academic_term_id IN (
                  SELECT id FROM public.academic_terms 
                  WHERE academic_year = NEW.academic_year AND id <> NEW.id
              );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 13. DELETE USER ENTIRELY (DATABASE & AUTHENTICATION)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.delete_user_entirely(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
    v_auth_id UUID;
BEGIN
    -- Check if caller is super admin
    IF NOT public.is_super_admin() THEN
        RAISE EXCEPTION 'Access denied. Only Super Admins can delete users.';
    END IF;

    -- Get the auth_id of the target user
    SELECT auth_id INTO v_auth_id FROM public.users WHERE id = p_user_id;

    -- Delete target user's profile from public.users
    -- This will cascade delete any references in tables with ON DELETE CASCADE
    DELETE FROM public.users WHERE id = p_user_id;

    -- Delete target user from auth.users (requires security definer context)
    IF v_auth_id IS NOT NULL THEN
        DELETE FROM auth.users WHERE id = v_auth_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ==============================================================================
-- 14. DEMOTE ORGANIZATION OFFICER (SECURITY DEFINER)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.demote_organization_officer(
    p_org_id UUID,
    p_user_id UUID,
    p_role_name TEXT,
    p_workspace_type TEXT DEFAULT 'organization'
) RETURNS VOID AS $$
DECLARE
    v_actual_user_id UUID;
    v_member_role_id UUID;
    v_voter_role_id UUID;
BEGIN
    SELECT id INTO v_actual_user_id 
    FROM public.users 
    WHERE id = p_user_id OR auth_id = p_user_id
    LIMIT 1;

    SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Member' LIMIT 1;
    SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Voters' LIMIT 1;

    IF p_workspace_type = 'comselec' THEN
        IF LOWER(p_role_name) = 'adviser' THEN
            DELETE FROM public.comselec_members
            WHERE comselec_id = p_org_id AND user_id = v_actual_user_id;
        ELSE
            UPDATE public.comselec_members
            SET role_id = v_voter_role_id,
                expired_at = NULL,
                status = 'active'
            WHERE comselec_id = p_org_id AND user_id = v_actual_user_id;
        END IF;
    ELSE
        IF LOWER(p_role_name) = 'adviser' THEN
            DELETE FROM public.organization_members
            WHERE organization_id = p_org_id AND user_id = v_actual_user_id;

            UPDATE public.organizations
            SET adviser_name = NULL
            WHERE id = p_org_id;
        ELSE
            UPDATE public.organization_members
            SET role_id = v_member_role_id,
                expired_at = NULL,
                status = 'active'
            WHERE organization_id = p_org_id AND user_id = v_actual_user_id;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ==============================================================================
-- 15. ACCOUNT DELETION REQUESTS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.account_deletion_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    student_id_number VARCHAR(50) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    acknowledged_clearance BOOLEAN NOT NULL DEFAULT FALSE,
    acknowledged_data_loss BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE TRIGGER update_account_deletion_requests_updated_at 
BEFORE UPDATE ON public.account_deletion_requests 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE public.account_deletion_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can create their own deletion request" 
ON public.account_deletion_requests 
FOR INSERT TO authenticated 
WITH CHECK (user_id = public.get_my_id());

CREATE POLICY "Users can view their own deletion requests" 
ON public.account_deletion_requests 
FOR SELECT TO authenticated 
USING (user_id = public.get_my_id());

CREATE POLICY "Super admins can manage all deletion requests" 
ON public.account_deletion_requests 
FOR ALL TO authenticated 
USING (public.is_super_admin());


-- ==============================================================================
-- 16. PERFORMANCE OPTIMIZATION INDEXES
-- ==============================================================================

-- Excuse Requests Indexes
CREATE INDEX IF NOT EXISTS idx_excuse_requests_student_id ON public.excuse_requests(student_id);
CREATE INDEX IF NOT EXISTS idx_excuse_requests_event_id ON public.excuse_requests(event_id);
CREATE INDEX IF NOT EXISTS idx_excuse_requests_status ON public.excuse_requests(status);
CREATE INDEX IF NOT EXISTS idx_excuse_requests_scope ON public.excuse_requests(scope_type, scope_id);

-- Events & Announcements (Scope Lookups)
CREATE INDEX IF NOT EXISTS idx_events_scope ON public.events(scope_type, scope_id);
CREATE INDEX IF NOT EXISTS idx_events_term ON public.events(academic_term_id);
CREATE INDEX IF NOT EXISTS idx_announcements_scope ON public.announcements(scope_type, scope_id);
CREATE INDEX IF NOT EXISTS idx_announcements_term ON public.announcements(academic_term_id);

-- Fees & Payments (Treasurer Dashboard Lookups)
CREATE INDEX IF NOT EXISTS idx_fees_scope ON public.fees(scope_type, scope_id);
CREATE INDEX IF NOT EXISTS idx_student_payments_status ON public.student_payments(status);

-- Attendance (Composite Index for Fast QR Scanning Checks)
CREATE INDEX IF NOT EXISTS idx_student_attendance_event_student ON public.student_attendance(event_id, student_id);

-- Sanctions (Admin Lookups)
CREATE INDEX IF NOT EXISTS idx_student_sanction_status ON public.student_sanction_records(status);
CREATE INDEX IF NOT EXISTS idx_student_sanction_scope ON public.student_sanction_records(scope_type, scope_id);

-- Memberships (Reverse Lookups by User ID)
CREATE INDEX IF NOT EXISTS idx_org_members_user_id ON public.organization_members(user_id);
CREATE INDEX IF NOT EXISTS idx_comselec_members_user_id ON public.comselec_members(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON public.user_roles(user_id);

-- Clearance Requests (Filter by Org & Status for Officers)
CREATE INDEX IF NOT EXISTS idx_clearance_requests_org_id ON public.activity_card_clearance_requests(organization_id);
CREATE INDEX IF NOT EXISTS idx_clearance_requests_status ON public.activity_card_clearance_requests(status);
