-- ==============================================================================
-- GOOGLE DEVELOPERS SEED & FIX SCRIPT (10 TEST ACCOUNTS)
-- Seeds Google Campus, Faculty, Program, Personnel & 7 Student Accounts.
-- Safe to execute anytime in Supabase SQL Editor.
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. SEED CAMPUS, FACULTY, AND PROGRAM
INSERT INTO campuses (name, location, description, status) 
VALUES (
  'Google', 
  'Google Headquarters / Virtual', 
  'System campus reserved for Google Developers and internal testing',
  'hidden'
)
ON CONFLICT DO NOTHING;

INSERT INTO faculties (campus_id, name, code)
VALUES (
  (SELECT id FROM campuses WHERE name = 'Google' LIMIT 1),
  'Google Faculty',
  'GF'
)
ON CONFLICT DO NOTHING;

INSERT INTO programs (faculty_id, name, code)
VALUES (
  (SELECT id FROM faculties WHERE code = 'GF' AND campus_id = (SELECT id FROM campuses WHERE name = 'Google') LIMIT 1),
  'Google Program',
  'GP'
)
ON CONFLICT DO NOTHING;

-- 2. CLEANUP STUCK / CORRUPTED AUTH USERS
DELETE FROM auth.users 
WHERE email IN (
  'google.dean@dev.com',
  'google.head@dev.com',
  'google.adviser@dev.com',
  'google.governor@dev.com',
  'google.student@dev.com',
  'google.student1@dev.com',
  'google.student2@dev.com',
  'google.student3@dev.com',
  'google.student4@dev.com',
  'google.student5@dev.com'
);

-- 3. SEED ALL 10 GOOGLE DEVELOPER TEST ACCOUNTS
-- Password for all test accounts: GoogleDev2026!
DO $$
DECLARE
  v_campus_id UUID;
  v_faculty_id UUID;
  v_program_id UUID;
  
  -- Account UUIDs
  v_dean_id UUID := 'a1111111-1111-1111-1111-111111111111';
  v_head_id UUID := 'a2222222-2222-2222-2222-222222222222';
  v_adviser_id UUID := 'a5555555-5555-5555-5555-555555555555';
  v_governor_id UUID := 'a3333333-3333-3333-3333-333333333333';
  v_student_id UUID := 'a4444444-4444-4444-4444-444444444444';
  
  v_st1_id UUID := 'b1111111-1111-1111-1111-111111111111';
  v_st2_id UUID := 'b2222222-2222-2222-2222-222222222222';
  v_st3_id UUID := 'b3333333-3333-3333-3333-333333333333';
  v_st4_id UUID := 'b4444444-4444-4444-4444-444444444444';
  v_st5_id UUID := 'b5555555-5555-5555-5555-555555555555';

  v_password_hash TEXT;
BEGIN
  SELECT id INTO v_campus_id FROM campuses WHERE name = 'Google' LIMIT 1;
  SELECT id INTO v_faculty_id FROM faculties WHERE code = 'GF' AND campus_id = v_campus_id LIMIT 1;
  SELECT id INTO v_program_id FROM programs WHERE code = 'GP' AND faculty_id = v_faculty_id LIMIT 1;
  v_password_hash := crypt('GoogleDev2026!', gen_salt('bf'));

  -- Helper loop for inserting into auth.users and auth.identities
  -- 1. Faculty Dean (Personnel)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_dean_id, 'authenticated', 'authenticated', 'google.dean@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Dean","school_id":"GD-2026-001","campus_id":"%s","faculty_id":"%s","status":"active"}', v_campus_id, v_faculty_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_dean_id, v_dean_id, v_dean_id, format('{"sub":"%s","email":"google.dean@dev.com"}', v_dean_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 2. Program Head (Personnel)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_head_id, 'authenticated', 'authenticated', 'google.head@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Head","school_id":"GD-2026-002","campus_id":"%s","faculty_id":"%s","program_id":"%s","status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_head_id, v_head_id, v_head_id, format('{"sub":"%s","email":"google.head@dev.com"}', v_head_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 3. Google Adviser (Personnel)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_adviser_id, 'authenticated', 'authenticated', 'google.adviser@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Adviser","school_id":"GD-2026-005","campus_id":"%s","faculty_id":"%s","program_id":"%s","status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_adviser_id, v_adviser_id, v_adviser_id, format('{"sub":"%s","email":"google.adviser@dev.com"}', v_adviser_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 4. Google Governor (Students)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_governor_id, 'authenticated', 'authenticated', 'google.governor@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Governor","school_id":"GD-2026-003","campus_id":"%s","faculty_id":"%s","program_id":"%s","year_level":3,"status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_governor_id, v_governor_id, v_governor_id, format('{"sub":"%s","email":"google.governor@dev.com"}', v_governor_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 5. Google Main Student (Students)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_student_id, 'authenticated', 'authenticated', 'google.student@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Student","school_id":"GD-2026-004","campus_id":"%s","faculty_id":"%s","program_id":"%s","year_level":2,"status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_student_id, v_student_id, v_student_id, format('{"sub":"%s","email":"google.student@dev.com"}', v_student_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 6. Google Student 1 (Students)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_st1_id, 'authenticated', 'authenticated', 'google.student1@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Student 1","school_id":"GD-2026-006","campus_id":"%s","faculty_id":"%s","program_id":"%s","year_level":1,"status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_st1_id, v_st1_id, v_st1_id, format('{"sub":"%s","email":"google.student1@dev.com"}', v_st1_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 7. Google Student 2 (Students)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_st2_id, 'authenticated', 'authenticated', 'google.student2@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Student 2","school_id":"GD-2026-007","campus_id":"%s","faculty_id":"%s","program_id":"%s","year_level":2,"status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_st2_id, v_st2_id, v_st2_id, format('{"sub":"%s","email":"google.student2@dev.com"}', v_st2_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 8. Google Student 3 (Students)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_st3_id, 'authenticated', 'authenticated', 'google.student3@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Student 3","school_id":"GD-2026-008","campus_id":"%s","faculty_id":"%s","program_id":"%s","year_level":3,"status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_st3_id, v_st3_id, v_st3_id, format('{"sub":"%s","email":"google.student3@dev.com"}', v_st3_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 9. Google Student 4 (Students)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_st4_id, 'authenticated', 'authenticated', 'google.student4@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Student 4","school_id":"GD-2026-009","campus_id":"%s","faculty_id":"%s","program_id":"%s","year_level":4,"status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_st4_id, v_st4_id, v_st4_id, format('{"sub":"%s","email":"google.student4@dev.com"}', v_st4_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- 10. Google Student 5 (Students)
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, phone_change, phone_change_token, reauthentication_token, is_super_admin)
  VALUES ('00000000-0000-0000-0000-000000000000', v_st5_id, 'authenticated', 'authenticated', 'google.student5@dev.com', v_password_hash, current_timestamp, '{"provider":"email","providers":["email"]}', format('{"first_name":"Google","last_name":"Student 5","school_id":"GD-2026-010","campus_id":"%s","faculty_id":"%s","program_id":"%s","year_level":1,"status":"active"}', v_campus_id, v_faculty_id, v_program_id)::jsonb, current_timestamp, current_timestamp, '', '', '', '', '', '', '', '', false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (v_st5_id, v_st5_id, v_st5_id, format('{"sub":"%s","email":"google.student5@dev.com"}', v_st5_id)::jsonb, 'email', current_timestamp, current_timestamp, current_timestamp)
  ON CONFLICT (id) DO NOTHING;

  -- Clean up any prior roles for all 10 emails
  DELETE FROM public.user_roles WHERE user_id IN (
    SELECT id FROM public.users WHERE email LIKE 'google.%@dev.com'
  );

  -- Assign Roles:
  -- Dean -> Personnel
  INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
  SELECT u.id, r.id, 'Faculty'::public.scope_type, v_faculty_id
  FROM public.users u CROSS JOIN public.roles r
  WHERE u.email = 'google.dean@dev.com' AND r.name = 'Personnel'
  ON CONFLICT DO NOTHING;

  -- Head -> Personnel
  INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
  SELECT u.id, r.id, 'Program'::public.scope_type, v_program_id
  FROM public.users u CROSS JOIN public.roles r
  WHERE u.email = 'google.head@dev.com' AND r.name = 'Personnel'
  ON CONFLICT DO NOTHING;

  -- Adviser -> Personnel
  INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
  SELECT u.id, r.id, 'Program'::public.scope_type, v_program_id
  FROM public.users u CROSS JOIN public.roles r
  WHERE u.email = 'google.adviser@dev.com' AND r.name = 'Personnel'
  ON CONFLICT DO NOTHING;

  -- All Student accounts -> Students
  INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
  SELECT u.id, r.id, 'Program'::public.scope_type, v_program_id
  FROM public.users u CROSS JOIN public.roles r
  WHERE u.email IN (
    'google.governor@dev.com', 'google.student@dev.com', 'google.student1@dev.com', 
    'google.student2@dev.com', 'google.student3@dev.com', 'google.student4@dev.com', 'google.student5@dev.com'
  ) AND r.name = 'Students'
  ON CONFLICT DO NOTHING;

END $$;

-- 4. FIX ALL NULL TOKEN COLUMNS IN auth.users TO PREVENT SUPABASE GO-TRUE CRASHES
UPDATE auth.users SET 
  email_change = COALESCE(email_change, ''),
  email_change_token_new = COALESCE(email_change_token_new, ''),
  email_change_token_current = COALESCE(email_change_token_current, ''),
  phone_change = COALESCE(phone_change, ''),
  phone_change_token = COALESCE(phone_change_token, ''),
  confirmation_token = COALESCE(confirmation_token, ''),
  recovery_token = COALESCE(recovery_token, ''),
  reauthentication_token = COALESCE(reauthentication_token, '');
