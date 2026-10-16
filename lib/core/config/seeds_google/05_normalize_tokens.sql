-- ==============================================================================
-- STEP 5 OF 7: 05_normalize_tokens.sql — GoTrue crash guard (google-only)
-- Source: seed_google_developers_fixed.sql Section 4
-- Run: paste WHOLE file as postgres, AFTER 04.
-- Writes: ONLY NULL token columns for google.*@dev.com to ''. NEVER whole table.
-- Expect: NOTICE 'Section 4 done: token normalize (google-only).'
-- Next: 06_verify.sql
-- ==============================================================================

SET search_path = public;
SET statement_timeout = 0;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

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
