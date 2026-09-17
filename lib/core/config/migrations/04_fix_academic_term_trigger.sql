-- Migration: 04_fix_academic_term_trigger.sql
-- Description: Non-destructive active term switching trigger to preserve historical roles, events, and clearances

CREATE OR REPLACE FUNCTION public.single_active_term()
RETURNS TRIGGER 
SET search_path = public, pg_temp
AS $$
BEGIN
    -- Prevent trigger recursion
    IF pg_trigger_depth() > 1 THEN
        RETURN NEW;
    END IF;

    IF NEW.is_active = TRUE THEN
        -- Deactivate all other terms without deleting or overwriting historical data
        UPDATE public.academic_terms 
        SET is_active = FALSE 
        WHERE id <> NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop legacy automatic reset function to prevent accidental data destruction
DROP FUNCTION IF EXISTS public.reset_academic_year_data() CASCADE;
