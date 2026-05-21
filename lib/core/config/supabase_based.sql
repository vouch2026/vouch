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
DROP TABLE IF EXISTS student_payments CASCADE;
DROP TABLE IF EXISTS payment_receiver CASCADE;
DROP TABLE IF EXISTS student_attendance CASCADE;
DROP TABLE IF EXISTS sanction_rules CASCADE;
DROP TABLE IF EXISTS event_ratings CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS fees CASCADE;
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
-- 2. CORE ORGANIZATION & USERS
-- ==========================================

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

-- Add faculty_id and program_id back to users as they reference faculties and programs
ALTER TABLE users ADD COLUMN faculty_id UUID REFERENCES faculties(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN program_id UUID REFERENCES programs(id) ON DELETE SET NULL;

CREATE TABLE organizations (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name VARCHAR(255) NOT NULL,
code VARCHAR(50) NOT NULL UNIQUE,
description TEXT,
logo_url VARCHAR(2048),
banner_url VARCHAR(2048),
status VARCHAR(20) DEFAULT 'active',
type VARCHAR(50) DEFAULT 'academic',
campus_id UUID REFERENCES campuses(id) ON DELETE SET NULL,
faculty_id UUID REFERENCES faculties(id) ON DELETE SET NULL,
program_id UUID REFERENCES programs(id) ON DELETE SET NULL,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- 3. ROLE-BASED ACCESS CONTROL (RBAC)
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

CREATE TABLE user_roles (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
scope_type scope_type NOT NULL,
scope_id UUID NOT NULL, 
assigned_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
is_active BOOLEAN DEFAULT true
);

-- ------------------------------------------------------------
-- Enable RLS for users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" 
ON users FOR SELECT 
USING (auth.uid() = auth_id);

CREATE POLICY "Users can update their own profile" 
ON users FOR UPDATE 
USING (auth.uid() = auth_id);

CREATE POLICY "Public profiles are viewable by everyone" 
ON users FOR SELECT 
USING (true);

CREATE POLICY "Super admins can update any profile" 
ON users FOR UPDATE 
TO authenticated 
USING (public.is_super_admin());

-- Enable RLS for roles and user_roles
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Roles are viewable by authenticated users"
ON roles FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "User roles are viewable by authenticated users"
ON user_roles FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Permissions are viewable by authenticated users"
ON permissions FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Role permissions are viewable by authenticated users"
ON role_permissions FOR SELECT USING (auth.role() = 'authenticated');

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
-- RLS for Academic Structure
-- ------------------------------------------------------------
ALTER TABLE campuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculties ENABLE ROW LEVEL SECURITY;
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_terms ENABLE ROW LEVEL SECURITY;

-- Select policies (Viewable by everyone)
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
-- ------------------------------------------------------------

-- ==========================================
-- 4. REQUIREMENTS (EVENTS, FEES & SANCTIONS)
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
-- 5. FULFILLMENT (ATTENDANCE, PAYMENTS & SANCTIONS)
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
-- 6. THE CLEARANCE WORKFLOW
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

-- ==========================================
-- 7. INITIAL DATA SEEDING
-- ==========================================

-- 1. INSERT CAMPUSES
INSERT INTO campuses (name, location) VALUES
('DORSU Main Campus', 'Mati City, Davao Oriental');

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
('Super Admin', 100),
('Faculty Dean', 80),
('Program Head', 70),
('Comselec Chair', 60), 
('Faculty Governor', 50),
('Program Governor', 40),
('Faculty Treasurer', 30),
('Faculty Secretary', 30),
('Program Treasurer', 20),
('Program Secretary', 20),
('Faculty Council Member', 15),
('Comselec Officer', 15), 
('Program Council Member', 10),
('Students', 5);

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
('view_faculty_analytics');

-- 6. MAP PERMISSIONS TO ROLES
-- Super Admin
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Super Admin' AND p.action IN (
'manage_academic_terms', 'manage_faculties', 'manage_programs',
'assign_roles', 'revoke_roles', 'view_faculty_analytics', 'view_program_analytics',
'manage_elections'
);

-- (Simplified mapping for other roles, similar to sample.sql)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'Students' AND p.action IN ('request_clearance');

-- 7. UTILITY RPC FOR ROLES
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
-- 8. SECURITY & AUTH TRIGGERS
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
    new_user_id UUID;
    student_role_id UUID;
BEGIN
    -- 1. Insert into public.users
    INSERT INTO public.users (
        auth_id, 
        email, 
        first_name, 
        last_name, 
        student_id_number, 
        faculty_id, 
        program_id, 
        year,
        id_front_url,
        id_back_url,
        account_status
    )
    VALUES (
        new.id, 
        new.email, 
        COALESCE(new.raw_user_meta_data->>'first_name', ''),
        COALESCE(new.raw_user_meta_data->>'last_name', ''), 
        COALESCE(new.raw_user_meta_data->>'school_id', 'PENDING-' || substr(new.id::text, 1, 8)),
        (new.raw_user_meta_data->>'faculty_id')::uuid,
        (new.raw_user_meta_data->>'program_id')::uuid,
        (new.raw_user_meta_data->>'year_level')::int,
        new.raw_user_meta_data->>'id_front_url',
        new.raw_user_meta_data->>'id_back_url',
        COALESCE(new.raw_user_meta_data->>'status', 'active')
    )
    RETURNING id INTO new_user_id;

    -- 2. Assign default 'Students' role
    SELECT id INTO student_role_id FROM public.roles WHERE name = 'Students';
    
    IF student_role_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
        VALUES (
            new_user_id, 
            student_role_id, 
            'Program', 
            (new.raw_user_meta_data->>'program_id')::uuid
        );
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==============================================================================
-- 9. SUPER ADMIN SEED
-- ==============================================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Insert into Supabase Auth (auth.users)
INSERT INTO auth.users (
instance_id, id, aud, role, email, encrypted_password, 
email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
created_at, updated_at, confirmation_token, recovery_token, 
email_change_token_new, is_super_admin
) VALUES (
'00000000-0000-0000-0000-000000000000',
'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c', 
'authenticated', 'authenticated', 'vouch.app.admin@gmail.com',
crypt('Admin-2026', gen_salt('bf')),
current_timestamp, '{"provider":"email","providers":["email"]}',
'{"full_name":"Vouch Admin"}', current_timestamp, current_timestamp,
'', '', '', false
) ON CONFLICT (id) DO NOTHING;

-- 2. Insert into Supabase Auth Identities
INSERT INTO auth.identities (
id, provider_id, user_id, identity_data, provider, 
last_sign_in_at, created_at, updated_at
) VALUES (
'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c',
'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c',
'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c',
format('{"sub":"%s","email":"%s"}','cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c','vouch.app.admin@gmail.com')::jsonb,
'email', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (id) DO NOTHING;

-- 3. Upsert into public.users
INSERT INTO public.users (
auth_id, student_id_number, first_name, last_name, email, account_status
) VALUES (
'cc097ff9-8f10-4a76-b5d8-ecb1b87ae75c', 
'SA-2026-001', 'Vouch', 'Admin', 'vouch.app.admin@gmail.com', 'active'
) ON CONFLICT (auth_id) DO UPDATE SET
student_id_number = EXCLUDED.student_id_number,
first_name = EXCLUDED.first_name,
last_name = EXCLUDED.last_name,
account_status = EXCLUDED.account_status;

-- 4. Assign the 'Super Admin' role
INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id) 
SELECT u.id, r.id, 'Institutional', '00000000-0000-0000-0000-000000000000'
FROM public.users u CROSS JOIN public.roles r
WHERE u.email = 'vouch.app.admin@gmail.com' AND r.name = 'Super Admin'
AND NOT EXISTS (
SELECT 1 FROM public.user_roles ur WHERE ur.user_id = u.id AND ur.role_id = r.id
);

UPDATE auth.users SET email_change = '' WHERE email_change IS NULL;







