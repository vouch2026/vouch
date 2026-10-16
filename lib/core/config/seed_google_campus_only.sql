-- ==============================================================================
-- GOOGLE CAMPUS ONLY — SAFE FOR STUDIO PASTE (self-hosted)
-- File: seed_google_campus_only.sql
-- Extracted from: seed_google_developers_fixed.sql Section 1
--
-- WHAT THIS DOES:
--   Ensures Google campus / GF faculty / GP program exist. Nothing else.
--
-- SAFETY:
--   - Only public.campuses / public.faculties / public.programs
--   - NEVER touches auth.users, auth.identities, public.users, user_roles
--   - No DELETE / DROP / TRUNCATE / UPDATE of existing rows
--   - Idempotent: safe to re-run (second run = "already exists, reusing", still 1 row)
--
-- HOW TO RUN (Supabase Studio SQL editor, self-hosted):
--   1. Run as postgres (bypasses RLS for INSERT).
--   2. Paste this whole file at once, Run.
--   3. Expect NOTICE: "Google campus created" (first run) or "already exists"
--      plus "Section 1 done: campus=% faculty=% program=%".
--   4. Copy the 3 UUIDs from NOTICE or from verification SELECTs below.
--      You need them for Auth > Users user_metadata in the next step.
-- ==============================================================================

SET search_path = public;
SET statement_timeout = 0;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ------------------------------------------------------------------------------
-- GOOGLE CAMPUS / FACULTY / PROGRAM (idempotent, no duplicates)
-- campuses has NO unique on name, so we MUST guard with NOT EXISTS
-- (plain ON CONFLICT DO NOTHING would insert duplicates).
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_campus_id uuid;
  v_faculty_id uuid;
  v_program_id uuid;
BEGIN
  IF to_regclass('public.campuses') IS NULL
     OR to_regclass('public.faculties') IS NULL
     OR to_regclass('public.programs') IS NULL THEN
    RAISE WARNING 'Section 1 skipped: academic tables absent. Apply supabase_selfhost_fixed.sql first.';
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

  -- If GF exists but points to wrong campus, NOTICE only (do not overwrite)
  IF EXISTS (SELECT 1 FROM public.faculties WHERE code = 'GF' AND campus_id IS DISTINCT FROM v_campus_id) THEN
    RAISE WARNING 'Section 1: faculty GF exists but campus_id differs from Google campus. Leaving as-is; verify manually.';
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
-- VERIFICATION (read-only — confirm 1 row each)
-- ------------------------------------------------------------------------------
SELECT id AS campus_id, name, status FROM public.campuses WHERE name = 'Google';
SELECT id AS faculty_id, campus_id, name, code FROM public.faculties WHERE code = 'GF';
SELECT id AS program_id, faculty_id, name, code FROM public.programs WHERE code = 'GP';
