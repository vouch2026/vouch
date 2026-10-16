-- ==============================================================================
-- STEP 7 OF 7 (OPTIONAL, OFF BY DEFAULT): 07_cleanup_google_only.sql
-- Source: seed_google_developers_fixed.sql Appendix B
-- ALL STATEMENTS BELOW ARE COMMENTED OUT. Pasting this file does NOTHING.
-- Uncomment ONLY the block you need, ONLY for google.*@dev.com test data.
-- NEVER raw DELETE auth.users in prod — prefer Studio > Auth > Users delete.
-- Order if you must reset: user_roles -> public.users -> auth via UI -> re-run 03+04.
-- ==============================================================================

-- Safe scoped cleanup (Google test data ONLY):
-- DELETE FROM public.user_roles WHERE user_id IN (SELECT id FROM public.users WHERE email LIKE 'google.%@dev.com');
-- DELETE FROM public.users WHERE email LIKE 'google.%@dev.com';
-- Delete auth via Studio > Auth > Users (never raw DELETE in prod).

-- Roles check (read-only, safe to uncomment anytime):
-- SELECT u.email, r.name, ur.scope_type FROM public.user_roles ur
-- JOIN public.users u ON u.id = ur.user_id JOIN public.roles r ON r.id = ur.role_id
-- WHERE u.email LIKE 'google.%@dev.com' ORDER BY u.email;
