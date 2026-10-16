-- ==============================================================================
-- STEP 1 OF 7: 01_preflight.sql — PREFLIGHT (read-only, always safe first)
-- Source: seed_google_developers_fixed.sql Section 0
-- Run: paste WHOLE file in Supabase Studio SQL editor as postgres, Run once.
-- Writes: NOTHING. Only RAISE NOTICE/WARNING.
-- Expect: NOTICE Preflight: auth.users exists / auth.identities exists /
--         public.users exists / campuses/faculties/programs exist.
-- Stop if: WARNING PREFLIGHT FAILED. Fix schema/stack first, do NOT continue.
-- Next: 02_campus.sql
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
