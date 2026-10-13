-- Migration: backfill school-based organization memberships.
--
-- Context: handle_new_user() (20261016) auto-joins school-based orgs
-- (e.g. University Student Council) for NEW student signups. Students who
-- registered before that migration have no school-based memberships.
--
-- This one-time backfill inserts Member rows for every student whose
-- users.school_id matches a school-based organization's school_id, using
-- the same predicate style as create_organization_with_members()
-- (user_roles join, r.name = 'Students', ur.is_active = true).
--
-- Safe to re-run (ON CONFLICT DO NOTHING) and safe on pre-schools DBs
-- (missing school_id column -> guarded no-op).

DO $$
BEGIN
    INSERT INTO public.organization_members (organization_id, user_id, role_id)
    SELECT o.id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
    FROM public.organizations o
    JOIN public.users u ON u.school_id = o.school_id
    JOIN public.user_roles ur ON u.id = ur.user_id
    JOIN public.roles r ON ur.role_id = r.id
    WHERE o.type = 'school-based'
      AND r.name = 'Students'
      AND ur.is_active = true
    ON CONFLICT DO NOTHING;
EXCEPTION WHEN undefined_column THEN
    -- Pre-schools DB (no users.school_id / organizations.school_id): no-op.
    NULL;
END $$;
