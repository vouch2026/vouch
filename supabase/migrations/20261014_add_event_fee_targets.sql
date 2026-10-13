-- Migration: scoped obligation targets for events/fees
-- Visibility = parent scope (everyone in scope sees it).
-- Obligation = row in event_targets / fee_targets (only selected members owe
-- it and it counts toward activity-card clearance).
-- Legacy rows (no target rows) keep old behavior: all in scope obligated.

-- 1. Target tables ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS event_targets (
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (event_id, user_id)
);

CREATE TABLE IF NOT EXISTS fee_targets (
  fee_id UUID NOT NULL REFERENCES fees(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (fee_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_targets_user ON event_targets(user_id);
CREATE INDEX IF NOT EXISTS idx_fee_targets_user ON fee_targets(user_id);

ALTER TABLE event_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_targets ENABLE ROW LEVEL SECURITY;

-- Everyone can see who is obligated (same openness as events/fees).
DROP POLICY IF EXISTS "Event targets are viewable by everyone" ON event_targets;
CREATE POLICY "Event targets are viewable by everyone" ON event_targets FOR SELECT USING (true);
DROP POLICY IF EXISTS "Fee targets are viewable by everyone" ON fee_targets;
CREATE POLICY "Fee targets are viewable by everyone" ON fee_targets FOR SELECT USING (true);

-- Manage rights follow the PARENT row: anyone who can edit the event/fee
-- (officers of the owning scope incl. school-based orgs, deans/program heads
-- via user_roles, super admins) can manage its targets. Requires migration
-- 20261013 (has_scope_permission school branch) for 'School'-scoped parents.
DROP POLICY IF EXISTS "Officers can manage event targets" ON event_targets;
CREATE POLICY "Officers can manage event targets" ON event_targets
  FOR ALL TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_targets.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
      AND (e.academic_term_id IS NULL OR e.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
    )
  )
  WITH CHECK (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_targets.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
      AND (e.academic_term_id IS NULL OR e.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
    )
  );
DROP POLICY IF EXISTS "Officers can manage fee targets" ON fee_targets;
CREATE POLICY "Officers can manage fee targets" ON fee_targets
  FOR ALL TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM fees f
      WHERE f.id = fee_targets.fee_id
      AND public.has_scope_permission('edit_fee', f.scope_type, f.scope_id)
      AND f.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true)
    )
  )
  WITH CHECK (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM fees f
      WHERE f.id = fee_targets.fee_id
      AND public.has_scope_permission('edit_fee', f.scope_type, f.scope_id)
      AND f.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true)
    )
  );

-- 2. Past-term write hardening ------------------------------------------------
-- Past AY|SEM is view-only. Enforce server-side with RESTRICTIVE policies
-- (permissive officer policies alone would still allow past-term writes, so
-- these must be RESTRICTIVE to actually deny). Service role
-- (migrations/backfills) bypasses RLS as usual.
DO $$
BEGIN
  -- events (academic_term_id nullable)
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='events' AND policyname='Active term insert guard (events)') THEN
    CREATE POLICY "Active term insert guard (events)" ON events
      AS RESTRICTIVE FOR INSERT TO authenticated
      WITH CHECK (academic_term_id IS NULL OR academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='events' AND policyname='Active term update guard (events)') THEN
    CREATE POLICY "Active term update guard (events)" ON events
      AS RESTRICTIVE FOR UPDATE TO authenticated
      USING (academic_term_id IS NULL OR academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
      WITH CHECK (academic_term_id IS NULL OR academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='events' AND policyname='Active term delete guard (events)') THEN
    CREATE POLICY "Active term delete guard (events)" ON events
      AS RESTRICTIVE FOR DELETE TO authenticated
      USING (academic_term_id IS NULL OR academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;

  -- fees (academic_term_id NOT NULL)
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='fees' AND policyname='Active term insert guard (fees)') THEN
    CREATE POLICY "Active term insert guard (fees)" ON fees
      AS RESTRICTIVE FOR INSERT TO authenticated
      WITH CHECK (academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='fees' AND policyname='Active term update guard (fees)') THEN
    CREATE POLICY "Active term update guard (fees)" ON fees
      AS RESTRICTIVE FOR UPDATE TO authenticated
      USING (academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
      WITH CHECK (academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='fees' AND policyname='Active term delete guard (fees)') THEN
    CREATE POLICY "Active term delete guard (fees)" ON fees
      AS RESTRICTIVE FOR DELETE TO authenticated
      USING (academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;

  -- announcements (academic_term_id nullable in legacy rows)
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='announcements' AND policyname='Active term insert guard (announcements)') THEN
    CREATE POLICY "Active term insert guard (announcements)" ON announcements
      AS RESTRICTIVE FOR INSERT TO authenticated
      WITH CHECK (academic_term_id IS NULL OR academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='announcements' AND policyname='Active term update guard (announcements)') THEN
    CREATE POLICY "Active term update guard (announcements)" ON announcements
      AS RESTRICTIVE FOR UPDATE TO authenticated
      USING (academic_term_id IS NULL OR academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
      WITH CHECK (academic_term_id IS NULL OR academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='announcements' AND policyname='Active term delete guard (announcements)') THEN
    CREATE POLICY "Active term delete guard (announcements)" ON announcements
      AS RESTRICTIVE FOR DELETE TO authenticated
      USING (academic_term_id IS NULL OR academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true));
  END IF;
END $$;
