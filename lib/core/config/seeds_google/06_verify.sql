-- ==============================================================================
-- STEP 6 OF 7: 06_verify.sql — VERIFICATION (read-only, must pass)
-- Source: seed_google_developers_fixed.sql Section 5
-- Run: paste WHOLE file as postgres. Writes NOTHING except NOTICEs.
-- Must see:
--   10 rows in 5a (all active, auth_linked=t, campus=Google, faculty=GF, program=GP except dean null)
--   NOTICE 'CHECK PASSED: 10/10 public.users present.'
--   NOTICE 'CHECK PASSED: 10/10 auth.users present.'
--   NOTICE 'CHECK PASSED: all Google users pinned to Google campus.'
-- If auth <10: create missing via Studio > Auth > Users, re-run 04 then 06.
-- If campus pin fails: check 02 UUIDs, re-run 04.
-- ==============================================================================

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
