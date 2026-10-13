-- Migration: non-destructive academic year rollover.
--
-- Problem: reset_academic_year_data() DELETEd all Adviser memberships and
-- WIPEd adviser_name + clearance periods + restriction flags on every org
-- each new school year. (Events/fees/announcements/attendance/payments were
-- never deleted — RESTRICT guards forbid it — but governance data was lost.)
--
-- New behavior (demote, never delete):
--   1. Officers AND advisers are demoted to Member/Voters (adviser rows are
--      kept — nobody vanishes from orgs).
--   2. Transient officer user_roles are still cleared (enforcement half of
--      demotion; stale scoped roles would otherwise keep granting officer
--      permissions. Dean/Head/Super-Admin/Students/Voters/Instructor/
--      Personnel rows are preserved).
--   3. Org settings (adviser_name, clearance periods, flags) are PRESERVED.
--   4. Clearance requests are Archived (rows kept for history viewing).
--   5. Pending sanctions are Completed (fresh slate; history kept).
--   6. Active memberships are retargeted to the NEW term id — previously only
--      same-year term switches did this, leaving stale term pointers after a
--      year change.
--   7. Events, fees, announcements, attendance, payments, targets: untouched.
--
-- Signature change: reset now takes the new term id, so the old zero-arg
-- version is dropped (only caller is the single_active_term trigger, updated
-- below). Safe: no client ever calls this function directly (super-admin
-- guarded SECURITY DEFINER).

DROP FUNCTION IF EXISTS public.reset_academic_year_data();

CREATE FUNCTION public.reset_academic_year_data(p_new_term_id UUID)
RETURNS VOID
SET search_path = public, pg_temp
AS $$
DECLARE
    v_member_role_id UUID;
    v_voter_role_id UUID;
BEGIN
    IF NOT public.is_super_admin() THEN
        RAISE EXCEPTION 'Access denied: only Super Admins can execute academic year reset.';
    END IF;

    -- 1. Retrieve IDs of default student roles
    SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Member';
    SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Voters';

    -- 2. Demote ALL organization members (incl. advisers/officers) to Member.
    --    No rows are deleted.
    UPDATE public.organization_members
    SET role_id = v_member_role_id
    WHERE role_id IS DISTINCT FROM v_member_role_id;

    -- 3. Demote comselec members to Voters (unchanged behavior).
    UPDATE public.comselec_members
    SET role_id = v_voter_role_id
    WHERE role_id IS DISTINCT FROM v_voter_role_id;

    -- 4. Point active memberships at the new term (fixes stale term pointers
    --    after year changes).
    UPDATE public.organization_members
    SET academic_term_id = p_new_term_id
    WHERE status = 'active';

    UPDATE public.comselec_members
    SET academic_term_id = p_new_term_id
    WHERE status = 'active';

    -- 5. Clear transient officer roles from user_roles (dean/head/admin and
    --    base roles preserved).
    DELETE FROM public.user_roles
    WHERE role_id NOT IN (
        SELECT id FROM public.roles
        WHERE name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Students', 'Voters')
    );

    -- 6. Org/comselec settings (adviser_name, clearance periods, flags) are
    --    intentionally PRESERVED across years — no wipes.

    -- 7. Archive clearance requests instead of deleting historical records.
    UPDATE public.activity_card_clearance_requests
    SET status = 'Archived'
    WHERE status <> 'Archived';

    -- 8. Mark pending sanction records as Completed for the new year.
    UPDATE public.student_sanction_records
    SET status = 'Completed'
    WHERE status IN ('Pending Item', 'In Progress');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pass the new term id through from the trigger.
CREATE OR REPLACE FUNCTION public.single_active_term()
RETURNS TRIGGER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_old_academic_year VARCHAR(20);
BEGIN
    -- Prevent trigger recursion
    IF pg_trigger_depth() > 1 THEN
        RETURN NEW;
    END IF;
    IF NEW.is_active = TRUE THEN
        -- Get the academic year of the currently active term (prior to its deactivation)
        SELECT academic_year INTO v_old_academic_year
        FROM public.academic_terms
        WHERE is_active = TRUE AND id <> NEW.id
        LIMIT 1;

        -- Deactivate all other terms
        UPDATE public.academic_terms SET is_active = FALSE WHERE id <> NEW.id;

        -- Perform reset only if academic year changes
        IF v_old_academic_year IS NOT NULL AND v_old_academic_year <> NEW.academic_year THEN
            PERFORM public.reset_academic_year_data(NEW.id);
        ELSIF v_old_academic_year IS NOT NULL AND v_old_academic_year = NEW.academic_year THEN
            -- If academic year is the same (e.g. changing from 1st sem to 2nd sem),
            -- carry over the academic_term_id of all active officers/advisers to the new active term.
            UPDATE public.organization_members
            SET academic_term_id = NEW.id
            WHERE status = 'active'
              AND role_id IS NOT NULL
              AND academic_term_id IN (
                  SELECT id FROM public.academic_terms
                  WHERE academic_year = NEW.academic_year AND id <> NEW.id
              );

            UPDATE public.comselec_members
            SET academic_term_id = NEW.id
            WHERE status = 'active'
              AND role_id IS NOT NULL
              AND academic_term_id IN (
                  SELECT id FROM public.academic_terms
                  WHERE academic_year = NEW.academic_year AND id <> NEW.id
              );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- The retarget above references NEW.id, which does not exist yet when the
-- trigger fires BEFORE INSERT (FK violation — a flaw the old code shared).
-- AFTER timing fixes it: the row exists in both INSERT and UPDATE paths.
-- The function returns NEW unmodified, so BEFORE->AFTER changes no semantics;
-- recursion is still guarded (deactivation UPDATEs carry is_active=false).
DROP TRIGGER IF EXISTS ensure_single_active_term ON academic_terms;
CREATE TRIGGER ensure_single_active_term
AFTER INSERT OR UPDATE ON academic_terms
FOR EACH ROW EXECUTE FUNCTION single_active_term();
