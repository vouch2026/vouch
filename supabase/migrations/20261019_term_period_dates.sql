-- Migration: real period dates on academic_terms.
--
-- Context: the School Year picker lists every term to every student.
-- To hide terms that ended before a student registered, terms need real
-- period bounds. Adds start_date / end_date (nullable) and backfills them
-- from the academic_year ('YYYY-YYYY') + semester ('1st' / '2nd' / 'Summer')
-- convention (Philippine academic calendar):
--   1st    -> Aug 1 (year 1) .. Dec 31 (year 1)
--   2nd    -> Jan 1 (year 2) .. May 31 (year 2)
--   Summer -> Jun 1 (year 2) .. Jul 31 (year 2)
--
-- Rows whose academic_year does not match the pattern keep NULL dates and
-- stay visible to everyone (grandfathered). Safe to re-run.

ALTER TABLE public.academic_terms
    ADD COLUMN IF NOT EXISTS start_date DATE,
    ADD COLUMN IF NOT EXISTS end_date DATE;

UPDATE public.academic_terms
SET start_date = make_date(parts.y1, 8, 1),
    end_date = make_date(parts.y1, 12, 31)
FROM (
    SELECT id,
           (string_to_array(academic_year, '-'))[1]::int AS y1
    FROM public.academic_terms
    WHERE semester = '1st'
      AND academic_year ~ '^[0-9]{4}-[0-9]{4}$'
      AND start_date IS NULL
) AS parts
WHERE academic_terms.id = parts.id;

UPDATE public.academic_terms
SET start_date = make_date(parts.y2, 1, 1),
    end_date = make_date(parts.y2, 5, 31)
FROM (
    SELECT id,
           (string_to_array(academic_year, '-'))[2]::int AS y2
    FROM public.academic_terms
    WHERE semester = '2nd'
      AND academic_year ~ '^[0-9]{4}-[0-9]{4}$'
      AND start_date IS NULL
) AS parts
WHERE academic_terms.id = parts.id;

UPDATE public.academic_terms
SET start_date = make_date(parts.y2, 6, 1),
    end_date = make_date(parts.y2, 7, 31)
FROM (
    SELECT id,
           (string_to_array(academic_year, '-'))[2]::int AS y2
    FROM public.academic_terms
    WHERE semester = 'Summer'
      AND academic_year ~ '^[0-9]{4}-[0-9]{4}$'
      AND start_date IS NULL
) AS parts
WHERE academic_terms.id = parts.id;
