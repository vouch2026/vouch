-- Migration: School level (School -> Campus -> Faculty -> Program)
-- DORSU model: one school (university) owns many campuses (Main, Baganga,
-- San Isidro, ...). University Student Council = school-wide org.
--
-- Safe to run on existing DBs: all new columns nullable first, backfilled,
-- then campuses.school_id set NOT NULL. Re-runnable guards via IF NOT EXISTS.

-- 1. Schools table -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL UNIQUE,
  short_name VARCHAR(50),
  logo_url VARCHAR(2048),
  banner_url VARCHAR(2048),
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Keep updated_at fresh (function already exists in base schema).
DROP TRIGGER IF EXISTS update_schools_updated_at ON schools;
CREATE TRIGGER update_schools_updated_at
  BEFORE UPDATE ON schools
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Schools are viewable by everyone" ON schools;
CREATE POLICY "Schools are viewable by everyone" ON schools FOR SELECT USING (true);
DROP POLICY IF EXISTS "Super admins can manage schools" ON schools;
CREATE POLICY "Super admins can manage schools" ON schools
  FOR ALL TO authenticated USING (public.is_super_admin());

-- 2. Link columns (nullable first for backfill) ------------------------------
ALTER TABLE campuses ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id) ON DELETE RESTRICT;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id) ON DELETE SET NULL;

-- 3. Seed DORSU + backfill ----------------------------------------------------
-- Single canonical school. Campuses without a school get attached to DORSU.
INSERT INTO schools (name, short_name)
VALUES ('Davao Oriental State University', 'DORSU')
ON CONFLICT (name) DO NOTHING;

UPDATE campuses
SET school_id = (SELECT id FROM schools WHERE name = 'Davao Oriental State University' LIMIT 1)
WHERE school_id IS NULL;

UPDATE users u
SET school_id = c.school_id
FROM campuses c
WHERE u.school_id IS NULL AND u.campus_id = c.id;

UPDATE organizations o
SET school_id = c.school_id
FROM campuses c
WHERE o.school_id IS NULL AND o.campus_id = c.id;

-- Enforce: every campus must belong to a school (after backfill).
ALTER TABLE campuses ALTER COLUMN school_id SET NOT NULL;

-- Helpful indexes (idempotent).
CREATE INDEX IF NOT EXISTS idx_campuses_school_id ON campuses(school_id);
CREATE INDEX IF NOT EXISTS idx_organizations_school_id ON organizations(school_id);
CREATE INDEX IF NOT EXISTS idx_users_school_id ON users(school_id);

-- 4. Seed University Student Council (school-wide org) ------------------------
-- Type 'school-based' = spans all campuses of a school (see scope_helpers).
INSERT INTO organizations (name, code, description, type, school_id, status)
SELECT
  'University Student Council',
  'USC',
  'University-wide student council spanning all DORSU campuses',
  'school-based',
  s.id,
  'active'
FROM schools s
WHERE s.name = 'Davao Oriental State University'
  AND NOT EXISTS (SELECT 1 FROM organizations WHERE code = 'USC');
