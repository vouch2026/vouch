-- ==============================================================================
-- MIGRATION: Split scanned_by_user_id into time_in_scanned_by_user_id 
--            and time_out_scanned_by_user_id with 100% data preservation.
-- ==============================================================================

BEGIN;

-- 1. Add the two new columns safely
ALTER TABLE public.student_attendance 
ADD COLUMN IF NOT EXISTS time_in_scanned_by_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS time_out_scanned_by_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL;

-- 2. Drop legacy RLS policies FIRST so Postgres allows dropping the column
DROP POLICY IF EXISTS "Officers can scan attendance" ON public.student_attendance;
DROP POLICY IF EXISTS "Officers can scan attendance update" ON public.student_attendance;

-- 3. Migrate ALL existing officer IDs to new columns without data loss
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'student_attendance' 
      AND column_name = 'scanned_by_user_id'
  ) THEN
    -- Copy existing scanned_by_user_id to time_in_scanned_by_user_id for all non-null records
    UPDATE public.student_attendance 
    SET time_in_scanned_by_user_id = scanned_by_user_id 
    WHERE scanned_by_user_id IS NOT NULL 
      AND time_in_scanned_by_user_id IS NULL;

    -- Copy existing scanned_by_user_id to time_out_scanned_by_user_id for all non-null records
    UPDATE public.student_attendance 
    SET time_out_scanned_by_user_id = scanned_by_user_id 
    WHERE scanned_by_user_id IS NOT NULL 
      AND time_out_scanned_by_user_id IS NULL;

    -- Drop legacy scanned_by_user_id column safely (CASCADE removes any lingering policy dependency)
    ALTER TABLE public.student_attendance DROP COLUMN scanned_by_user_id CASCADE;
  END IF;
END $$;

-- 4. Create updated Row Level Security (RLS) Policies
CREATE POLICY "Officers can scan attendance" ON public.student_attendance FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.events e 
    WHERE e.id = event_id 
    AND public.has_scope_permission('scan_event_attendance', e.scope_type, e.scope_id)
  )
  AND (
    time_in_scanned_by_user_id = public.get_my_id() OR 
    time_out_scanned_by_user_id = public.get_my_id()
  )
);

CREATE POLICY "Officers can scan attendance update" ON public.student_attendance FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.events e 
    WHERE e.id = event_id 
    AND public.has_scope_permission('scan_event_attendance', e.scope_type, e.scope_id)
  )
)
WITH CHECK (
  (
    time_in_scanned_by_user_id = public.get_my_id() OR 
    time_out_scanned_by_user_id = public.get_my_id()
  )
);

COMMIT;
