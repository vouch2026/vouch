-- Migration: bulk scope-level obligation targets for events/fees.
--
-- Context: obligated members can be picked one-by-one (event_targets /
-- fee_targets user rows) AND now as whole scope units (Campus / Faculty /
-- Program). Scope picks are live rules: students who join the unit later
-- are automatically obligated. Both pick kinds combine.
--
-- Obligation rule (enforced client-side, same contract as 20261014):
--   no rows in EITHER table = legacy, all in scope obligated;
--   otherwise obligated = listed user OR member of a listed scope unit.
-- Scope values reuse the parent-row convention: 'Institutional' (campus),
-- 'Faculty', 'Program'. No 'School' rows: whole-school = leave empty.
--
-- Safe to re-run (IF NOT EXISTS / DROP POLICY IF EXISTS guards).

-- 1. Scope target tables ------------------------------------------------------
CREATE TABLE IF NOT EXISTS event_scope_targets (
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  scope_type VARCHAR NOT NULL CHECK (scope_type IN ('Institutional', 'Faculty', 'Program')),
  scope_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (event_id, scope_type, scope_id)
);

CREATE TABLE IF NOT EXISTS fee_scope_targets (
  fee_id UUID NOT NULL REFERENCES fees(id) ON DELETE CASCADE,
  scope_type VARCHAR NOT NULL CHECK (scope_type IN ('Institutional', 'Faculty', 'Program')),
  scope_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (fee_id, scope_type, scope_id)
);

CREATE INDEX IF NOT EXISTS idx_event_scope_targets_event ON event_scope_targets(event_id);
CREATE INDEX IF NOT EXISTS idx_fee_scope_targets_fee ON fee_scope_targets(fee_id);

ALTER TABLE event_scope_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_scope_targets ENABLE ROW LEVEL SECURITY;

-- Everyone can see which scopes are obligated (same openness as targets).
DROP POLICY IF EXISTS "Event scope targets are viewable by everyone" ON event_scope_targets;
CREATE POLICY "Event scope targets are viewable by everyone" ON event_scope_targets FOR SELECT USING (true);
DROP POLICY IF EXISTS "Fee scope targets are viewable by everyone" ON fee_scope_targets;
CREATE POLICY "Fee scope targets are viewable by everyone" ON fee_scope_targets FOR SELECT USING (true);

-- Manage rights follow the PARENT row (same predicate as 20261014 targets).
DROP POLICY IF EXISTS "Officers can manage event scope targets" ON event_scope_targets;
CREATE POLICY "Officers can manage event scope targets" ON event_scope_targets
  FOR ALL TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_scope_targets.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
      AND (e.academic_term_id IS NULL OR e.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
    )
  )
  WITH CHECK (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_scope_targets.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
      AND (e.academic_term_id IS NULL OR e.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
    )
  );
DROP POLICY IF EXISTS "Officers can manage fee scope targets" ON fee_scope_targets;
CREATE POLICY "Officers can manage fee scope targets" ON fee_scope_targets
  FOR ALL TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM fees f
      WHERE f.id = fee_scope_targets.fee_id
      AND public.has_scope_permission('edit_fee', f.scope_type, f.scope_id)
      AND f.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true)
    )
  )
  WITH CHECK (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM fees f
      WHERE f.id = fee_scope_targets.fee_id
      AND public.has_scope_permission('edit_fee', f.scope_type, f.scope_id)
      AND f.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true)
    )
  );
