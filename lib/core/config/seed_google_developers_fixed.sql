-- ==============================================================================
-- GOOGLE DEVELOPERS SEED — FIXED FOR SELF-HOST (supabase_selfhost_fixed.sql)
-- File: seed_google_developers_fixed.sql
-- Purpose: insert the 10 Google test accounts WITHOUT breaking self-hosted GoTrue.
--
-- WHAT THIS DOES:
--   1. Ensures Google campus / GF faculty / GP program exist (idempotent, no dupes).
--   2. Seeds auth.users + auth.identities with FIXED UUIDs (version-tolerant, guarded).
--   3. Ensures public.users rows exist and are pinned to Google campus/faculty/program.
--   4. Normalizes empty token columns for Google users only (GoTrue crash guard).
--
-- WHAT THIS DOES NOT DO (by request):
--   - Does NOT touch public.user_roles (you assign roles manually).
--   - Does NOT DELETE/DROP/TRUNCATE anything.
--   - Does NOT overwrite existing passwords (ON CONFLICT DO NOTHING).
--
-- FIXED UUIDs (same as seed_google_developers.sql):
--   dean    a1111111-1111-1111-1111-111111111111  google.dean@dev.com     GD-2026-001
--   head    a2222222-2222-2222-2222-222222222222  google.head@dev.com     GD-2026-002
--   adviser a5555555-5555-5555-5555-555555555555  google.adviser@dev.com  GD-2026-005
--   governor a3333333-3333-3333-3333-333333333333 google.governor@dev.com GD-2026-003
--   student a4444444-4444-4444-4444-444444444444  google.student@dev.com  GD-2026-004
--   st1     b1111111-1111-1111-1111-111111111111  google.student1@dev.com GD-2026-006
--   st2     b2222222-2222-2222-2222-222222222222  google.student2@dev.com GD-2026-007
--   st3     b3333333-3333-3333-3333-333333333333  google.student3@dev.com GD-2026-008
--   st4     b4444444-4444-4444-4444-444444444444  google.student4@dev.com GD-2026-009
--   st5     b5555555-5555-5555-5555-555555555555  google.student5@dev.com GD-2026-010
-- Password for all (if newly created): GoogleDev2026!
--
-- HOW TO RUN (new self-host DB with supabase_selfhost_fixed.sql already applied):
--   1. Run as postgres (Studio SQL editor, one block at a time).
--   2. Run Section 1, check NOTICE, then Section 2, then 3, then 4.
--   3. Run Section 5 verification SELECTs. All 10 must show linked + google campus.
--   4. Assign roles manually in app / via user_roles (no auto-assign in this file).
--   5. Test login with 1 student + 1 personnel before handing out credentials.
--   6. Safe to re-run anytime (idempotent). If auth insert is skipped with NOTICE,
--      create the user via Studio > Auth > Users with the same email, then re-run
--      Sections 3-5 only to backfill public.users.
-- ==============================================================================

SET search_path = public;
SET statement_timeout = 0;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ==============================================================================
-- 0. PREFLIGHT (read-only, never fails the script)
-- ==============================================================================
DO $$
BEGIN
  IF to_regclass('auth.users') IS NULL THEN
    RAISE WARNING 'PREFLIGHT FAILED: auth.users missing. Deploy full Supabase stack first. Sections 2+4 will be skipped automatically.';
  ELSE
    RAISE NOTICE 'Preflight: auth.users exists.';
  END IF;
  IF to_regclass('auth.identities') IS NULL THEN
    RAISE WARNING 'PREFLIGHT: auth.identities missing. Section 2 identities step will be skipped (ok on some GoTrue versions).';
  ELSE
    RAISE NOTICE 'Preflight: auth.identities exists.';
  END IF;
  IF to_regclass('public.users') IS NULL THEN
    RAISE WARNING 'PREFLIGHT FAILED: public.users missing. Apply supabase_selfhost_fixed.sql first.';
  ELSE
    RAISE NOTICE 'Preflight: public.users exists.';
  END IF;
  IF to_regclass('public.campuses') IS NULL OR to_regclass('public.faculties') IS NULL OR to_regclass('public.programs') IS NULL THEN
    RAISE WARNING 'PREFLIGHT FAILED: campuses/faculties/programs missing. Apply fixed schema first.';
  ELSE
    RAISE NOTICE 'Preflight: campuses/faculties/programs exist.';
  END IF;
END $$;

-- ==============================================================================
-- 1. GOOGLE CAMPUS / FACULTY / PROGRAM (idempotent, no duplicates)
-- campuses has NO unique on name, so we MUST guard with NOT EXISTS
-- (plain ON CONFLICT DO NOTHING would insert duplicates).
-- ==============================================================================
DO $$
DECLARE
  v_campus_id uuid;
  v_faculty_id uuid;
  v_program_id uuid;
BEGIN
  IF to_regclass('public.campuses') IS NULL
     OR to_regclass('public.faculties') IS NULL
     OR to_regclass('public.programs') IS NULL THEN
    RAISE WARNING 'Section 1 skipped: academic tables absent.';
    RETURN;
  END IF;

  -- Campus: insert only if missing
  IF NOT EXISTS (SELECT 1 FROM public.campuses WHERE name = 'Google') THEN
    BEGIN
      INSERT INTO public.campuses (name, location, description, status)
      VALUES (
        'Google',
        'Google Headquarters / Virtual',
        'System campus reserved for Google Developers and internal testing',
        'hidden'
      );
      RAISE NOTICE 'Section 1: Google campus created.';
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Section 1: Google campus insert skipped: %', SQLERRM;
    END;
  ELSE
    RAISE NOTICE 'Section 1: Google campus already exists, reusing.';
  END IF;

  SELECT id INTO v_campus_id FROM public.campuses WHERE name = 'Google' LIMIT 1;
  IF v_campus_id IS NULL THEN
    RAISE WARNING 'Section 1 aborted: Google campus id not found.';
    RETURN;
  END IF;

  -- Faculty: code GF is UNIQUE, ON CONFLICT is safe
  BEGIN
    INSERT INTO public.faculties (campus_id, name, code)
    VALUES (v_campus_id, 'Google Faculty', 'GF')
    ON CONFLICT (code) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Section 1: faculty GF insert skipped: %', SQLERRM;
  END;

  SELECT id INTO v_faculty_id FROM public.faculties WHERE code = 'GF' LIMIT 1;
  IF v_faculty_id IS NULL THEN
    RAISE WARNING 'Section 1 aborted: GF faculty id not found.';
    RETURN;
  END IF;

  -- Optional self-heal: if GF exists but points to wrong campus, NOTICE only (do not overwrite)
  IF EXISTS (SELECT 1 FROM public.faculties WHERE code = 'GF' AND campus_id IS DISTINCT FROM v_campus_id) THEN
    RAISE WARNING 'Section 1: faculty GF exists but campus_id differs from Google campus. Leaving as-is; verify manually.';
    -- Re-resolve to the actual GF row campus for consistency in later sections? No:
    -- force v_campus_id to stay as Google campus, v_faculty_id stays as GF row.
  END IF;

  -- Program: code GP is UNIQUE, ON CONFLICT is safe
  BEGIN
    INSERT INTO public.programs (faculty_id, name, code)
    VALUES (v_faculty_id, 'Google Program', 'GP')
    ON CONFLICT (code) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Section 1: program GP insert skipped: %', SQLERRM;
  END;

  SELECT id INTO v_program_id FROM public.programs WHERE code = 'GP' LIMIT 1;
  IF v_program_id IS NULL THEN
    RAISE WARNING 'Section 1 aborted: GP program id not found.';
    RETURN;
  END IF;

  RAISE NOTICE 'Section 1 done: campus=% faculty=% program=%', v_campus_id, v_faculty_id, v_program_id;
END $$;

-- ==============================================================================
-- 2. AUTH.USERS + AUTH.IDENTITIES (fixed UUIDs, version-tolerant, never fatal)
-- Rules:
--   - NO DELETE. Existing rows (by id OR email) are kept, password never overwritten.
--   - Only columns that actually exist in YOUR GoTrue version are inserted.
--   - Any version drift becomes NOTICE, never ERROR.
-- ==============================================================================
DO $$
DECLARE
  v_campus_id uuid;
  v_faculty_id uuid;
  v_program_id uuid;
  v_cols text[];
  v_id_cols text[];
  v_hash text;
  r record;
  v_meta jsonb;
  v_existing_id uuid;
  v_existing_email text;
  v_by_email_id uuid;
  v_by_id_email text;
  v_cols_arr text[];
  v_vals_arr text[];
  v_sql text;
BEGIN
  IF to_regclass('auth.users') IS NULL THEN
    RAISE WARNING 'Section 2 skipped: auth.users absent. Create users via Studio > Auth > Users, then re-run Sections 3-5.';
    RETURN;
  END IF;

  SELECT id INTO v_campus_id FROM public.campuses WHERE name = 'Google' LIMIT 1;
  SELECT id INTO v_faculty_id FROM public.faculties WHERE code = 'GF' LIMIT 1;
  SELECT id INTO v_program_id FROM public.programs WHERE code = 'GP' LIMIT 1;
  IF v_campus_id IS NULL OR v_faculty_id IS NULL OR v_program_id IS NULL THEN
    RAISE WARNING 'Section 2 aborted: Google campus/faculty/program not resolved. Run Section 1 first.';
    RETURN;
  END IF;

  SELECT COALESCE(array_agg(column_name), ARRAY[]::text[]) INTO v_cols
  FROM information_schema.columns WHERE table_schema = 'auth' AND table_name = 'users';

  IF to_regclass('auth.identities') IS NOT NULL THEN
    SELECT COALESCE(array_agg(column_name), ARRAY[]::text[]) INTO v_id_cols
    FROM information_schema.columns WHERE table_schema = 'auth' AND table_name = 'identities';
  ELSE
    v_id_cols := ARRAY[]::text[];
  END IF;

  -- One hash for all 10 (same password). crypt with bf matches GoTrue.
  BEGIN
    v_hash := crypt('GoogleDev2026!', gen_salt('bf'));
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Section 2 aborted: pgcrypto crypt() failed: %. Ensure CREATE EXTENSION pgcrypto as postgres.', SQLERRM;
    RETURN;
  END;

  FOR r IN
    SELECT * FROM (VALUES
      ('a1111111-1111-1111-1111-111111111111'::uuid, 'google.dean@dev.com'::text,     'Google'::text, 'Dean'::text,      'GD-2026-001'::text, NULL::int, false),
      ('a2222222-2222-2222-2222-222222222222'::uuid, 'google.head@dev.com'::text,     'Google'::text, 'Head'::text,      'GD-2026-002'::text, NULL::int, true),
      ('a5555555-5555-5555-5555-555555555555'::uuid, 'google.adviser@dev.com'::text,  'Google'::text, 'Adviser'::text,   'GD-2026-005'::text, NULL::int, true),
      ('a3333333-3333-3333-3333-333333333333'::uuid, 'google.governor@dev.com'::text, 'Google'::text, 'Governor'::text,  'GD-2026-003'::text, 3::int,    true),
      ('a4444444-4444-4444-4444-444444444444'::uuid, 'google.student@dev.com'::text,  'Google'::text, 'Student'::text,   'GD-2026-004'::text, 2::int,    true),
      ('b1111111-1111-1111-1111-111111111111'::uuid, 'google.student1@dev.com'::text, 'Google'::text, 'Student 1'::text, 'GD-2026-006'::text, 1::int,    true),
      ('b2222222-2222-2222-2222-222222222222'::uuid, 'google.student2@dev.com'::text, 'Google'::text, 'Student 2'::text, 'GD-2026-007'::text, 2::int,    true),
      ('b3333333-3333-3333-3333-333333333333'::uuid, 'google.student3@dev.com'::text, 'Google'::text, 'Student 3'::text, 'GD-2026-008'::text, 3::int,    true),
      ('b4444444-4444-4444-4444-444444444444'::uuid, 'google.student4@dev.com'::text, 'Google'::text, 'Student 4'::text, 'GD-2026-009'::text, 4::int,    true),
      ('b5555555-5555-5555-5555-555555555555'::uuid, 'google.student5@dev.com'::text, 'Google'::text, 'Student 5'::text, 'GD-2026-010'::text, 1::int,    true)
    ) AS t(id, email, first_name, last_name, school_id, year_level, has_program)
  LOOP
    -- Build raw_user_meta_data matching handle_new_user() expectations
    v_meta := jsonb_build_object(
      'first_name', r.first_name,
      'last_name', r.last_name,
      'school_id', r.school_id,
      'campus_id', v_campus_id::text,
      'faculty_id', v_faculty_id::text,
      'status', 'active'
    );
    IF r.has_program THEN
      v_meta := v_meta || jsonb_build_object('program_id', v_program_id::text);
    END IF;
    IF r.year_level IS NOT NULL THEN
      v_meta := v_meta || jsonb_build_object('year_level', r.year_level);
    END IF;

    -- Fixed-UUID policy: email wins. Keep existing row if taken, never overwrite.
    v_existing_id := NULL;
    v_existing_email := NULL;
    v_by_email_id := NULL;
    v_by_id_email := NULL;
    BEGIN
      SELECT id INTO v_by_email_id FROM auth.users WHERE email = r.email LIMIT 1;
      SELECT email INTO v_by_id_email FROM auth.users WHERE id = r.id LIMIT 1;
      IF v_by_email_id IS NOT NULL THEN
        v_existing_id := v_by_email_id;
        v_existing_email := r.email;
      ELSIF v_by_id_email IS NOT NULL THEN
        -- Fixed UUID taken by different email: do not touch, will be reported below
        v_existing_id := r.id;
        v_existing_email := v_by_id_email;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Section 2: auth lookup skipped for %: %', r.email, SQLERRM;
      CONTINUE;
    END;

    IF v_by_email_id IS NOT NULL AND v_by_email_id IS DISTINCT FROM r.id THEN
      RAISE NOTICE 'Section 2: % already exists with id % (wanted fixed %). Keeping existing, no overwrite.', r.email, v_by_email_id, r.id;
      -- Still ensure identities row exists for the EXISTING id below (no new auth row needed)
    ELSIF v_by_email_id IS NOT NULL AND v_by_email_id = r.id THEN
      RAISE NOTICE 'Section 2: % already seeded with fixed id %, skipping insert.', r.email, r.id;
    ELSIF v_by_email_id IS NULL AND v_by_id_email IS NOT NULL THEN
      RAISE WARNING 'Section 2: fixed id % already taken by different email %; skipping % to avoid collision. Pick a new UUID manually.', r.id, v_by_id_email, r.email;
      CONTINUE;
    ELSE
      -- Build dynamic INSERT with only existing columns.
      -- Use array_append(arr, elem) — NOT arr || elem — because || with an
      -- unknown literal resolves to array||array and fails with
      -- "malformed array literal" on empty arrays (PG18).
      v_cols_arr := ARRAY[]::text[];
      v_vals_arr := ARRAY[]::text[];
      IF 'instance_id' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'instance_id');
        v_vals_arr := array_append(v_vals_arr, (quote_literal('00000000-0000-0000-0000-000000000000') || '::uuid'));
      END IF;
      IF 'id' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'id');
        v_vals_arr := array_append(v_vals_arr, (quote_literal(r.id::text) || '::uuid'));
      END IF;
      IF 'aud' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'aud');
        v_vals_arr := array_append(v_vals_arr, quote_literal('authenticated'));
      END IF;
      IF 'role' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'role');
        v_vals_arr := array_append(v_vals_arr, quote_literal('authenticated'));
      END IF;
      IF 'email' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'email');
        v_vals_arr := array_append(v_vals_arr, quote_literal(r.email));
      END IF;
      IF 'encrypted_password' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'encrypted_password');
        v_vals_arr := array_append(v_vals_arr, quote_literal(v_hash));
      END IF;
      IF 'email_confirmed_at' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'email_confirmed_at');
        v_vals_arr := array_append(v_vals_arr, 'current_timestamp');
      END IF;
      IF 'raw_app_meta_data' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'raw_app_meta_data');
        v_vals_arr := array_append(v_vals_arr, (quote_literal('{"provider":"email","providers":["email"]}') || '::jsonb'));
      END IF;
      IF 'raw_user_meta_data' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'raw_user_meta_data');
        v_vals_arr := array_append(v_vals_arr, (quote_literal(v_meta::text) || '::jsonb'));
      END IF;
      IF 'created_at' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'created_at');
        v_vals_arr := array_append(v_vals_arr, 'current_timestamp');
      END IF;
      IF 'updated_at' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'updated_at');
        v_vals_arr := array_append(v_vals_arr, 'current_timestamp');
      END IF;
      IF 'confirmation_token' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'confirmation_token');
        v_vals_arr := array_append(v_vals_arr, quote_literal(''));
      END IF;
      IF 'recovery_token' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'recovery_token');
        v_vals_arr := array_append(v_vals_arr, quote_literal(''));
      END IF;
      IF 'email_change_token_new' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'email_change_token_new');
        v_vals_arr := array_append(v_vals_arr, quote_literal(''));
      END IF;
      IF 'email_change' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'email_change');
        v_vals_arr := array_append(v_vals_arr, quote_literal(''));
      END IF;
      IF 'email_change_token_current' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'email_change_token_current');
        v_vals_arr := array_append(v_vals_arr, quote_literal(''));
      END IF;
      IF 'phone_change' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'phone_change');
        v_vals_arr := array_append(v_vals_arr, quote_literal(''));
      END IF;
      IF 'phone_change_token' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'phone_change_token');
        v_vals_arr := array_append(v_vals_arr, quote_literal(''));
      END IF;
      IF 'reauthentication_token' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'reauthentication_token');
        v_vals_arr := array_append(v_vals_arr, quote_literal(''));
      END IF;
      IF 'is_super_admin' = ANY(v_cols) THEN
        v_cols_arr := array_append(v_cols_arr, 'is_super_admin');
        v_vals_arr := array_append(v_vals_arr, 'false');
      END IF;

      IF array_length(v_cols_arr, 1) IS NULL THEN
        RAISE WARNING 'Section 2: no writable auth.users columns detected, skipping %', r.email;
      ELSE
        v_sql := 'INSERT INTO auth.users (' || array_to_string(v_cols_arr, ', ')
               || ') VALUES (' || array_to_string(v_vals_arr, ', ')
               || ') ON CONFLICT (id) DO NOTHING';
        BEGIN
          EXECUTE v_sql;
          RAISE NOTICE 'Section 2: auth.users ensured for % (fixed id %)', r.email, r.id;
        EXCEPTION WHEN undefined_column OR undefined_table OR insufficient_privilege THEN
          RAISE WARNING 'Section 2: auth.users insert skipped for % (create via Studio > Auth > Users): %', r.email, SQLERRM;
        WHEN unique_violation THEN
          RAISE NOTICE 'Section 2: % already exists (unique), keeping existing.', r.email;
        WHEN OTHERS THEN
          RAISE WARNING 'Section 2: auth.users insert skipped for %: %', r.email, SQLERRM;
        END;
      END IF;
    END IF;

    -- Identities: ensure row for the EFFECTIVE auth id (existing id wins over fixed id)
    IF to_regclass('auth.identities') IS NULL THEN
      CONTINUE;
    END IF;
    DECLARE
      v_auth_id uuid;
      v_id_cols_arr text[];
      v_id_vals_arr text[];
      v_id_sql text;
      v_identity jsonb;
    BEGIN
      SELECT id INTO v_auth_id FROM auth.users WHERE email = r.email LIMIT 1;
      IF v_auth_id IS NULL THEN
        SELECT id INTO v_auth_id FROM auth.users WHERE id = r.id LIMIT 1;
      END IF;
      IF v_auth_id IS NULL THEN
        RAISE NOTICE 'Section 2: identities skipped for % (no auth.users row yet; create via Auth UI then re-run).', r.email;
        CONTINUE;
      END IF;
      IF EXISTS (SELECT 1 FROM auth.identities WHERE user_id = v_auth_id OR id = v_auth_id) THEN
        RAISE NOTICE 'Section 2: identities already exists for %, skipping.', r.email;
        CONTINUE;
      END IF;

      v_identity := jsonb_build_object('sub', v_auth_id::text, 'email', r.email);
      v_id_cols_arr := ARRAY[]::text[];
      v_id_vals_arr := ARRAY[]::text[];
      IF 'id' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'id');
        v_id_vals_arr := array_append(v_id_vals_arr, (quote_literal(v_auth_id::text) || '::uuid'));
      END IF;
      IF 'provider_id' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'provider_id');
        -- provider_id is TEXT in most GoTrue versions; store uuid text
        v_id_vals_arr := array_append(v_id_vals_arr, quote_literal(v_auth_id::text));
      END IF;
      IF 'user_id' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'user_id');
        v_id_vals_arr := array_append(v_id_vals_arr, (quote_literal(v_auth_id::text) || '::uuid'));
      END IF;
      IF 'identity_data' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'identity_data');
        v_id_vals_arr := array_append(v_id_vals_arr, (quote_literal(v_identity::text) || '::jsonb'));
      END IF;
      IF 'provider' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'provider');
        v_id_vals_arr := array_append(v_id_vals_arr, quote_literal('email'));
      END IF;
      IF 'email' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'email');
        v_id_vals_arr := array_append(v_id_vals_arr, quote_literal(r.email));
      END IF;
      IF 'last_sign_in_at' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'last_sign_in_at');
        v_id_vals_arr := array_append(v_id_vals_arr, 'current_timestamp');
      END IF;
      IF 'created_at' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'created_at');
        v_id_vals_arr := array_append(v_id_vals_arr, 'current_timestamp');
      END IF;
      IF 'updated_at' = ANY(v_id_cols) THEN
        v_id_cols_arr := array_append(v_id_cols_arr, 'updated_at');
        v_id_vals_arr := array_append(v_id_vals_arr, 'current_timestamp');
      END IF;

      IF array_length(v_id_cols_arr, 1) IS NULL THEN
        RAISE WARNING 'Section 2: no writable auth.identities columns, skipping %', r.email;
        CONTINUE;
      END IF;
      v_id_sql := 'INSERT INTO auth.identities (' || array_to_string(v_id_cols_arr, ', ')
               || ') VALUES (' || array_to_string(v_id_vals_arr, ', ')
               || ') ON CONFLICT (id) DO NOTHING';
      BEGIN
        EXECUTE v_id_sql;
        RAISE NOTICE 'Section 2: auth.identities ensured for %', r.email;
      EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Section 2: identities skipped for %: %', r.email, SQLERRM;
      END;
    END;

  END LOOP;

  RAISE NOTICE 'Section 2 done.';
END $$;

-- ==============================================================================
-- 3. PUBLIC.USERS — pin all 10 to Google campus (no roles touched)
--   - Links auth_id by email when auth row exists (fixed UUID preserved).
--   - If auth row missing, creates pending public.users WITHOUT auth_id so you
--     can still assign campus context; re-run this section after Auth UI creation
--     to backfill auth_id automatically.
--   - Never overwrites an existing real student_id_number with PENDING-*.
-- ==============================================================================
DO $$
DECLARE
  v_campus_id uuid;
  v_faculty_id uuid;
  v_program_id uuid;
  r record;
  v_auth_id uuid;
  v_pub_id uuid;
  v_pub_auth uuid;
  v_pub_sid text;
  v_prog uuid;
  v_backfilled int := 0;
BEGIN
  IF to_regclass('public.users') IS NULL THEN
    RAISE WARNING 'Section 3 skipped: public.users absent.';
    RETURN;
  END IF;

  SELECT id INTO v_campus_id FROM public.campuses WHERE name = 'Google' LIMIT 1;
  SELECT id INTO v_faculty_id FROM public.faculties WHERE code = 'GF' LIMIT 1;
  SELECT id INTO v_program_id FROM public.programs WHERE code = 'GP' LIMIT 1;
  IF v_campus_id IS NULL OR v_faculty_id IS NULL OR v_program_id IS NULL THEN
    RAISE WARNING 'Section 3 aborted: Google ids missing. Run Section 1 first.';
    RETURN;
  END IF;

  FOR r IN
    SELECT * FROM (VALUES
      ('google.dean@dev.com'::text,     'Google'::text, 'Dean'::text,      'GD-2026-001'::text, NULL::int, false),
      ('google.head@dev.com'::text,     'Google'::text, 'Head'::text,      'GD-2026-002'::text, NULL::int, true),
      ('google.adviser@dev.com'::text,  'Google'::text, 'Adviser'::text,   'GD-2026-005'::text, NULL::int, true),
      ('google.governor@dev.com'::text, 'Google'::text, 'Governor'::text,  'GD-2026-003'::text, 3::int,    true),
      ('google.student@dev.com'::text,  'Google'::text, 'Student'::text,   'GD-2026-004'::text, 2::int,    true),
      ('google.student1@dev.com'::text, 'Google'::text, 'Student 1'::text, 'GD-2026-006'::text, 1::int,    true),
      ('google.student2@dev.com'::text, 'Google'::text, 'Student 2'::text, 'GD-2026-007'::text, 2::int,    true),
      ('google.student3@dev.com'::text, 'Google'::text, 'Student 3'::text, 'GD-2026-008'::text, 3::int,    true),
      ('google.student4@dev.com'::text, 'Google'::text, 'Student 4'::text, 'GD-2026-009'::text, 4::int,    true),
      ('google.student5@dev.com'::text, 'Google'::text, 'Student 5'::text, 'GD-2026-010'::text, 1::int,    true)
    ) AS t(email, first_name, last_name, school_id, year_level, has_program)
  LOOP
    -- Dean has no program; everyone else gets GP
    IF r.has_program THEN v_prog := v_program_id; ELSE v_prog := NULL; END IF;

    -- Effective auth id (fixed UUID preserved when present)
    v_auth_id := NULL;
    IF to_regclass('auth.users') IS NOT NULL THEN
      BEGIN
        SELECT id INTO v_auth_id FROM auth.users WHERE email = r.email LIMIT 1;
      EXCEPTION WHEN OTHERS THEN
        v_auth_id := NULL;
      END;
    END IF;

    -- Existing public.users by email?
    v_pub_id := NULL; v_pub_auth := NULL; v_pub_sid := NULL;
    BEGIN
      SELECT id, auth_id, student_id_number INTO v_pub_id, v_pub_auth, v_pub_sid
      FROM public.users WHERE email = r.email LIMIT 1;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Section 3: lookup skipped for %: %', r.email, SQLERRM;
      CONTINUE;
    END;

    IF v_pub_id IS NOT NULL THEN
      BEGIN
        UPDATE public.users SET
          auth_id = COALESCE(v_pub_auth, v_auth_id, auth_id),
          first_name = r.first_name,
          last_name = r.last_name,
          -- Only fill student_id_number if currently pending/empty; never overwrite real IDs
          student_id_number = CASE
            WHEN student_id_number LIKE 'PENDING-%' OR student_id_number IS NULL OR student_id_number = '' THEN r.school_id
            ELSE student_id_number
          END,
          campus_id = v_campus_id,
          faculty_id = v_faculty_id,
          program_id = COALESCE(v_prog, program_id),
          year = COALESCE(r.year_level, year),
          account_status = 'active',
          updated_at = CURRENT_TIMESTAMP
        WHERE id = v_pub_id;
        RAISE NOTICE 'Section 3: public.users updated for % (google campus pinned).', r.email;
      EXCEPTION WHEN unique_violation THEN
        RAISE WARNING 'Section 3: % update hit unique (school_id taken by another row?). Linking by email only; check student_id_number manually.', r.email;
        BEGIN
          UPDATE public.users SET
            campus_id = v_campus_id,
            faculty_id = v_faculty_id,
            program_id = COALESCE(v_prog, program_id),
            account_status = 'active',
            updated_at = CURRENT_TIMESTAMP
          WHERE id = v_pub_id;
        EXCEPTION WHEN OTHERS THEN
          RAISE WARNING 'Section 3: minimal campus pin failed for %: %', r.email, SQLERRM;
        END;
      WHEN OTHERS THEN
        RAISE WARNING 'Section 3: update skipped for %: %', r.email, SQLERRM;
      END;
    ELSE
      -- No public row yet: check school_id collision before insert
      IF EXISTS (SELECT 1 FROM public.users WHERE student_id_number = r.school_id) THEN
        RAISE WARNING 'Section 3: school_id % already taken by different email; skipping insert for % (resolve manually).', r.school_id, r.email;
        CONTINUE;
      END IF;
      BEGIN
        IF v_auth_id IS NOT NULL THEN
          INSERT INTO public.users (auth_id, student_id_number, first_name, last_name, email, campus_id, faculty_id, program_id, year, account_status)
          VALUES (v_auth_id, r.school_id, r.first_name, r.last_name, r.email, v_campus_id, v_faculty_id, v_prog, r.year_level, 'active')
          ON CONFLICT (auth_id) DO UPDATE SET
            student_id_number = EXCLUDED.student_id_number,
            first_name = EXCLUDED.first_name,
            last_name = EXCLUDED.last_name,
            email = EXCLUDED.email,
            campus_id = EXCLUDED.campus_id,
            faculty_id = EXCLUDED.faculty_id,
            program_id = COALESCE(EXCLUDED.program_id, public.users.program_id),
            year = COALESCE(EXCLUDED.year, public.users.year),
            account_status = 'active';
          RAISE NOTICE 'Section 3: public.users created for % (auth linked).', r.email;
        ELSE
          -- Pending link: no auth row yet (e.g., version drift). Create without auth_id.
          INSERT INTO public.users (student_id_number, first_name, last_name, email, campus_id, faculty_id, program_id, year, account_status)
          VALUES (r.school_id, r.first_name, r.last_name, r.email, v_campus_id, v_faculty_id, v_prog, r.year_level, 'active')
          ON CONFLICT DO NOTHING;
          RAISE NOTICE 'Section 3: public.users created for % (PENDING auth link — create auth via UI then re-run).', r.email;
        END IF;
      EXCEPTION WHEN unique_violation THEN
        RAISE WARNING 'Section 3: insert skipped for % (unique). Re-run after resolving.', r.email;
      WHEN OTHERS THEN
        RAISE WARNING 'Section 3: insert skipped for %: %', r.email, SQLERRM;
      END;
    END IF;
  END LOOP;

  -- Backfill any pending auth_id now that auth rows may exist
  BEGIN
    IF to_regclass('auth.users') IS NOT NULL THEN
      UPDATE public.users u SET auth_id = a.id
      FROM auth.users a
      WHERE u.email = a.email
        AND u.auth_id IS DISTINCT FROM a.id
        AND u.email LIKE 'google.%@dev.com';
      GET DIAGNOSTICS v_backfilled = ROW_COUNT;
      RAISE NOTICE 'Section 3 backfill: % rows linked by email.', v_backfilled;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Section 3 backfill skipped: %', SQLERRM;
  END;

  RAISE NOTICE 'Section 3 done. Roles untouched (assign manually as requested).';
END $$;

-- ==============================================================================
-- 4. TOKEN NORMALIZE (Google users only, guarded — prevents GoTrue crashes)
-- Only touches columns that exist. Google-only WHERE clause, never whole table.
-- ==============================================================================
DO $$
DECLARE
  v_cols text[];
BEGIN
  IF to_regclass('auth.users') IS NULL THEN
    RAISE NOTICE 'Section 4 skipped: auth.users absent.';
    RETURN;
  END IF;
  SELECT COALESCE(array_agg(column_name), ARRAY[]::text[]) INTO v_cols
  FROM information_schema.columns WHERE table_schema = 'auth' AND table_name = 'users';

  BEGIN
    IF 'email_change' = ANY(v_cols) THEN
      EXECUTE 'UPDATE auth.users SET email_change = COALESCE(email_change, '''') WHERE email LIKE ''google.%@dev.com'' AND email_change IS NULL';
    END IF;
    IF 'email_change_token_new' = ANY(v_cols) THEN
      EXECUTE 'UPDATE auth.users SET email_change_token_new = COALESCE(email_change_token_new, '''') WHERE email LIKE ''google.%@dev.com'' AND email_change_token_new IS NULL';
    END IF;
    IF 'email_change_token_current' = ANY(v_cols) THEN
      EXECUTE 'UPDATE auth.users SET email_change_token_current = COALESCE(email_change_token_current, '''') WHERE email LIKE ''google.%@dev.com'' AND email_change_token_current IS NULL';
    END IF;
    IF 'phone_change' = ANY(v_cols) THEN
      EXECUTE 'UPDATE auth.users SET phone_change = COALESCE(phone_change, '''') WHERE email LIKE ''google.%@dev.com'' AND phone_change IS NULL';
    END IF;
    IF 'phone_change_token' = ANY(v_cols) THEN
      EXECUTE 'UPDATE auth.users SET phone_change_token = COALESCE(phone_change_token, '''') WHERE email LIKE ''google.%@dev.com'' AND phone_change_token IS NULL';
    END IF;
    IF 'confirmation_token' = ANY(v_cols) THEN
      EXECUTE 'UPDATE auth.users SET confirmation_token = COALESCE(confirmation_token, '''') WHERE email LIKE ''google.%@dev.com'' AND confirmation_token IS NULL';
    END IF;
    IF 'recovery_token' = ANY(v_cols) THEN
      EXECUTE 'UPDATE auth.users SET recovery_token = COALESCE(recovery_token, '''') WHERE email LIKE ''google.%@dev.com'' AND recovery_token IS NULL';
    END IF;
    IF 'reauthentication_token' = ANY(v_cols) THEN
      EXECUTE 'UPDATE auth.users SET reauthentication_token = COALESCE(reauthentication_token, '''') WHERE email LIKE ''google.%@dev.com'' AND reauthentication_token IS NULL';
    END IF;
    RAISE NOTICE 'Section 4 done: token normalize (google-only).';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Section 4 skipped: %', SQLERRM;
  END;
END $$;

-- ==============================================================================
-- 5. VERIFICATION (read-only — run these and confirm)
-- ==============================================================================
-- 5a. All 10 public.users exist, active, pinned to Google campus?
SELECT u.email, u.student_id_number, u.auth_id IS NOT NULL AS auth_linked,
       u.account_status, c.name AS campus, f.code AS faculty, p.code AS program, u.year
FROM public.users u
LEFT JOIN public.campuses c ON c.id = u.campus_id
LEFT JOIN public.faculties f ON f.id = u.faculty_id
LEFT JOIN public.programs p ON p.id = u.program_id
WHERE u.email LIKE 'google.%@dev.com'
ORDER BY u.email;

-- 5b. Auth rows present? (10 expected; if fewer, create missing via Auth UI then re-run Sec 3)
-- SELECT email, id, email_confirmed_at IS NOT NULL AS confirmed FROM auth.users WHERE email LIKE 'google.%@dev.com' ORDER BY email;

-- 5c. Campus sanity: Google campus + GF + GP ids
-- SELECT (SELECT id FROM public.campuses WHERE name='Google') AS campus_id,
--        (SELECT id FROM public.faculties WHERE code='GF') AS faculty_id,
--        (SELECT id FROM public.programs WHERE code='GP') AS program_id;

-- 5d. Roles untouched check (should return 0 unless you assigned manually):
-- SELECT u.email, r.name, ur.scope_type FROM public.user_roles ur
-- JOIN public.users u ON u.id = ur.user_id JOIN public.roles r ON r.id = ur.role_id
-- WHERE u.email LIKE 'google.%@dev.com' ORDER BY u.email;

DO $$
DECLARE
  v_pub int := 0; v_auth int := -1; v_bad_campus int := 0;
  v_google_campus uuid;
BEGIN
  IF to_regclass('public.users') IS NULL THEN
    RAISE WARNING 'CHECK skipped: public.users absent. Apply supabase_selfhost_fixed.sql first.';
    RETURN;
  END IF;
  BEGIN
    SELECT count(*) INTO v_pub FROM public.users WHERE email LIKE 'google.%@dev.com';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'CHECK skipped (public.users count failed): %', SQLERRM;
    RETURN;
  END;
  IF to_regclass('auth.users') IS NOT NULL THEN
    BEGIN
      EXECUTE 'SELECT count(*) FROM auth.users WHERE email LIKE ''google.%@dev.com''' INTO v_auth;
    EXCEPTION WHEN OTHERS THEN
      v_auth := -1;
    END;
  ELSE
    v_auth := -1;
  END IF;
  BEGIN
    SELECT id INTO v_google_campus FROM public.campuses WHERE name = 'Google' LIMIT 1;
    IF v_google_campus IS NULL THEN
      v_bad_campus := -1;
    ELSE
      SELECT count(*) INTO v_bad_campus
      FROM public.users u
      WHERE u.email LIKE 'google.%@dev.com'
        AND (u.campus_id IS DISTINCT FROM v_google_campus);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    v_bad_campus := -1;
  END;

  IF v_pub = 10 THEN
    RAISE NOTICE 'CHECK PASSED: 10/10 public.users present.';
  ELSE
    RAISE WARNING 'CHECK: public.users google count = % (expected 10).', v_pub;
  END IF;
  IF v_auth = 10 THEN
    RAISE NOTICE 'CHECK PASSED: 10/10 auth.users present.';
  ELSIF v_auth = -1 THEN
    RAISE WARNING 'CHECK: auth.users absent, cannot verify.';
  ELSE
    RAISE WARNING 'CHECK: auth.users google count = % (expected 10). Create missing via Studio > Auth > Users then re-run Sec 3.', v_auth;
  END IF;
  IF v_bad_campus = 0 THEN
    RAISE NOTICE 'CHECK PASSED: all Google users pinned to Google campus.';
  ELSIF v_bad_campus = -1 THEN
    RAISE WARNING 'CHECK: Google campus missing, cannot verify pinning.';
  ELSE
    RAISE WARNING 'CHECK FAILED: % google users NOT on Google campus.', v_bad_campus;
  END IF;
END $$;

-- ==============================================================================
-- APPENDIX (commented, do NOT auto-run)
-- ------------------------------------------------------------------------------
-- A. Assign roles manually (example — run only when YOU are ready):
--    Dean -> Personnel on Faculty scope, Head/Adviser -> Personnel on Program scope,
--    7 students -> Students on Program scope. Replace scope ids with YOUR GP/GF ids.
--
--    -- INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
--    -- SELECT u.id, r.id, 'Faculty'::public.scope_type, (SELECT id FROM public.faculties WHERE code='GF')
--    -- FROM public.users u CROSS JOIN public.roles r
--    -- WHERE u.email='google.dean@dev.com' AND r.name='Personnel'
--    -- AND NOT EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id=u.id AND ur.role_id=r.id);
--
-- B. Safe scoped cleanup (Google test data only, roles preserved elsewhere):
--    -- DELETE FROM public.user_roles WHERE user_id IN (SELECT id FROM public.users WHERE email LIKE 'google.%@dev.com');
--    -- DELETE FROM public.users WHERE email LIKE 'google.%@dev.com';
--    -- Delete auth via Studio > Auth > Users (never raw DELETE in prod).
-- ==============================================================================
