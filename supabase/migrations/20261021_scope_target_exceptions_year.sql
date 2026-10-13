-- Migration: scope-target exceptions + year narrowing.
--
-- Context: whole-unit picks (20261020) obligate live units, but creators
-- need "all of X except ..." for edge cases (transferees, mid-sem joiners),
-- plus year-level cuts ("all 4th-year BSIT"). Additive only:
--   1. event_target_exceptions / fee_target_exceptions (parent_id, user_id):
--      excluded members. Exclusion wins over unit membership, never over
--      legacy (no inclusions at all = everyone obligated, exclusions inert).
--   2. year_level INT NULL on event_scope_targets / fee_scope_targets:
--      when set, the unit pick covers only that year level.
--
-- Obligation rule: legacy (no user/scope rows) = all obligated; otherwise
-- obligated = (listed OR in a picked unit at a matching year) AND NOT
-- excluded. Safe to re-run.

-- 1. Year narrowing on scope picks --------------------------------------------
ALTER TABLE public.event_scope_targets
    ADD COLUMN IF NOT EXISTS year_level INT;
ALTER TABLE public.fee_scope_targets
    ADD COLUMN IF NOT EXISTS year_level INT;

-- 2. Exception tables -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS event_target_exceptions (
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (event_id, user_id)
);

CREATE TABLE IF NOT EXISTS fee_target_exceptions (
  fee_id UUID NOT NULL REFERENCES fees(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (fee_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_target_exceptions_event ON event_target_exceptions(event_id);
CREATE INDEX IF NOT EXISTS idx_fee_target_exceptions_fee ON fee_target_exceptions(fee_id);

ALTER TABLE event_target_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_target_exceptions ENABLE ROW LEVEL SECURITY;

-- Everyone can see who is excepted (same openness as targets).
DROP POLICY IF EXISTS "Event target exceptions are viewable by everyone" ON event_target_exceptions;
CREATE POLICY "Event target exceptions are viewable by everyone" ON event_target_exceptions FOR SELECT USING (true);
DROP POLICY IF EXISTS "Fee target exceptions are viewable by everyone" ON fee_target_exceptions;
CREATE POLICY "Fee target exceptions are viewable by everyone" ON fee_target_exceptions FOR SELECT USING (true);

-- Manage rights follow the PARENT row (same predicate as scope targets).
DROP POLICY IF EXISTS "Officers can manage event target exceptions" ON event_target_exceptions;
CREATE POLICY "Officers can manage event target exceptions" ON event_target_exceptions
  FOR ALL TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_target_exceptions.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
      AND (e.academic_term_id IS NULL OR e.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
    )
  )
  WITH CHECK (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_target_exceptions.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
      AND (e.academic_term_id IS NULL OR e.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true))
    )
  );
DROP POLICY IF EXISTS "Officers can manage fee target exceptions" ON fee_target_exceptions;
CREATE POLICY "Officers can manage fee target exceptions" ON fee_target_exceptions
  FOR ALL TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM fees f
      WHERE f.id = fee_target_exceptions.fee_id
      AND public.has_scope_permission('edit_fee', f.scope_type, f.scope_id)
      AND f.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true)
    )
  )
  WITH CHECK (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM fees f
      WHERE f.id = fee_target_exceptions.fee_id
      AND public.has_scope_permission('edit_fee', f.scope_type, f.scope_id)
      AND f.academic_term_id IN (SELECT id FROM academic_terms WHERE is_active = true)
    )
  );
