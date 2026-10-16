-- ==============================================================================
-- STEP 4 OF 7: 04_public_users.sql — LINK public.users + PIN Google campus
-- Source: seed_google_developers_fixed.sql Section 3
-- Run: paste WHOLE file as postgres, AFTER 03.
-- Writes: ONLY public.users for google.*@dev.com. NO user_roles touched.
-- Safety: links auth_id by email, pins campus/faculty/program, sets active.
--   Never overwrites real student_id_number. Missing auth => pending row, re-run after Auth UI.
-- Expect: NOTICE 'public.users updated/created' + 'backfill: N rows linked'.
-- Next: 05_normalize_tokens.sql, then 06_verify.sql. If auth was missing, re-run THIS file after Auth UI.
-- ==============================================================================

SET search_path = public;
SET statement_timeout = 0;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

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
