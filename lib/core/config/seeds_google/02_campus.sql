-- ==============================================================================
-- STEP 2 OF 7: 02_campus.sql — GOOGLE CAMPUS / GF / GP (idempotent)
-- Source: seed_google_developers_fixed.sql Section 1
-- Run: paste WHOLE file as postgres. Safe to re-run (you already ran campus-only).
-- Writes: ONLY public.campuses/faculties/programs. NEVER touches auth/users/roles.
-- Safety: campus guarded by NOT EXISTS (no dupes). GF/GP use ON CONFLICT(code).
-- Expect: NOTICE 'already exists, reusing' (your case) + 'Section 1 done: campus=% faculty=% program=%'.
-- Copy the 3 UUIDs from NOTICE for manual fallback.
-- Stop if: WARNING 'campus_id differs' or 'aborted'. Verify manually, do NOT continue.
-- Next: 03_auth_users.sql
-- ==============================================================================

SET search_path = public;
SET statement_timeout = 0;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

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

-- ------------------------------------------------------------------------------
-- VERIFICATION (read-only, must show 1 row each)
-- ------------------------------------------------------------------------------
SELECT id AS campus_id, name, status FROM public.campuses WHERE name = 'Google';
SELECT id AS faculty_id, campus_id, name, code FROM public.faculties WHERE code = 'GF';
SELECT id AS program_id, faculty_id, name, code FROM public.programs WHERE code = 'GP';
