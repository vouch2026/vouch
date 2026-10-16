-- ==============================================================================
-- STEP 3 OF 7: 03_auth_users.sql — AUTH.USERS + IDENTITIES (10 fixed UUIDs)
-- Source: seed_google_developers_fixed.sql Section 2
-- Run: paste WHOLE file as postgres, AFTER 02 succeeds.
-- Writes: ONLY auth.users + auth.identities for google.*@dev.com.
-- Safety:
--   - NO DELETE. Existing rows kept, password NEVER overwritten.
--   - Version-tolerant: only existing GoTrue columns inserted.
--   - Email wins over fixed UUID. Collisions become NOTICE/WARNING, never ERROR.
-- Accounts (password if newly created: GoogleDev2026!):
--   dean a1111111-... google.dean@dev.com | head a2222222-... | adviser a5555555-...
--   governor a3333333-... | student a4444444-... | st1 b1111111-... st2 b2222222-...
--   st3 b3333333-... st4 b4444444-... st5 b5555555-...
-- Expect per email: NOTICE 'ensured' / 'already seeded' / 'already exists ... Keeping existing'.
-- Fallback: if WARNING 'create via Studio > Auth > Users', create that user in
--   Auth UI (see seed_google_manual_users.md) then re-run 04 + 06 only.
-- Stop if: WARNING 'fixed id taken by different email'. Resolve UUID manually.
-- Next: 04_public_users.sql
-- ==============================================================================

SET search_path = public;
SET statement_timeout = 0;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

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
