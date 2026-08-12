-- ==============================================================================
-- STANDALONE NOTIFICATION AUTOMATION TRIGGERS (UPDATED SCOPE CASING)
-- Run this in your Supabase SQL Editor to automate notification delivery
-- when events, announcements, fees are created, or when sanctions start.
-- ==============================================================================

-- 1. TRIGGER FUNCTION: New Announcements Notification
CREATE OR REPLACE FUNCTION public.on_announcement_created()
RETURNS TRIGGER AS $$
DECLARE
    scope_code_val VARCHAR(255);
BEGIN
    -- Resolve organization code of organization the creator belongs to, matching the target scope type
    SELECT o.code INTO scope_code_val 
    FROM public.organizations o
    JOIN public.organization_members om ON o.id = om.organization_id
    WHERE om.user_id = NEW.created_by_user_id AND om.status = 'active'
    ORDER BY 
      CASE 
        WHEN NEW.scope_type::text = 'Institutional' AND o.type = 'campus-based' THEN 1
        WHEN NEW.scope_type::text = 'Faculty' AND o.type = 'faculty-based' THEN 1
        WHEN NEW.scope_type::text = 'Program' AND o.type = 'program-based' THEN 1
        ELSE 2
      END
    LIMIT 1;

    INSERT INTO public.notifications (
        sender_id,
        title,
        content,
        notification_type,
        target_campus_id,
        target_faculty_id,
        target_program_id,
        category,
        action_route,
        metadata
    ) VALUES (
        NEW.created_by_user_id,
        'New Announcement: ' || NEW.title,
        substring(NEW.content from 1 for 150),
        CASE 
            WHEN NEW.scope_type::text = 'Institutional' THEN 'campus'::text
            WHEN NEW.scope_type::text = 'Faculty' THEN 'faculty'::text
            WHEN NEW.scope_type::text = 'Program' THEN 'program'::text
            ELSE 'global'::text
        END,
        CASE WHEN NEW.scope_type::text = 'Institutional' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'Faculty' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'Program' THEN NEW.scope_id ELSE NULL END,
        'announcement',
        '/announcements',
        jsonb_build_object('scope_code', COALESCE(scope_code_val, 'GLOBAL'))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create Trigger on announcements
DROP TRIGGER IF EXISTS trigger_announcement_notification ON public.announcements;
CREATE TRIGGER trigger_announcement_notification
AFTER INSERT ON public.announcements
FOR EACH ROW EXECUTE FUNCTION public.on_announcement_created();


-- 2. TRIGGER FUNCTION: New Events Notification
CREATE OR REPLACE FUNCTION public.on_event_created()
RETURNS TRIGGER AS $$
DECLARE
    scope_code_val VARCHAR(255);
BEGIN
    IF NEW.created_by_organization_id IS NOT NULL THEN
        SELECT code INTO scope_code_val FROM public.organizations WHERE id = NEW.created_by_organization_id;
    END IF;

    IF scope_code_val IS NULL THEN
        SELECT o.code INTO scope_code_val 
        FROM public.organizations o
        JOIN public.organization_members om ON o.id = om.organization_id
        WHERE om.user_id = NEW.created_by_user_id AND om.status = 'active'
        ORDER BY 
          CASE 
            WHEN NEW.scope_type::text = 'Institutional' AND o.type = 'campus-based' THEN 1
            WHEN NEW.scope_type::text = 'Faculty' AND o.type = 'faculty-based' THEN 1
            WHEN NEW.scope_type::text = 'Program' AND o.type = 'program-based' THEN 1
            ELSE 2
          END
        LIMIT 1;
    END IF;

    INSERT INTO public.notifications (
        sender_id,
        title,
        content,
        notification_type,
        target_campus_id,
        target_faculty_id,
        target_program_id,
        category,
        action_route,
        metadata
    ) VALUES (
        NEW.created_by_user_id,
        'Upcoming Event: ' || NEW.name,
        'Date: ' || NEW.event_date || ' | Location: ' || NEW.location || '. ' || COALESCE(NEW.short_description, ''),
        CASE 
            WHEN NEW.scope_type::text = 'Institutional' THEN 'campus'::text
            WHEN NEW.scope_type::text = 'Faculty' THEN 'faculty'::text
            WHEN NEW.scope_type::text = 'Program' THEN 'program'::text
            ELSE 'global'::text
        END,
        CASE WHEN NEW.scope_type::text = 'Institutional' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'Faculty' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'Program' THEN NEW.scope_id ELSE NULL END,
        'event',
        '/events',
        jsonb_build_object('scope_code', COALESCE(scope_code_val, 'GLOBAL'))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create Trigger on events
DROP TRIGGER IF EXISTS trigger_event_notification ON public.events;
CREATE TRIGGER trigger_event_notification
AFTER INSERT ON public.events
FOR EACH ROW EXECUTE FUNCTION public.on_event_created();


-- 3. TRIGGER FUNCTION: New Fees Notification
CREATE OR REPLACE FUNCTION public.on_fee_created()
RETURNS TRIGGER AS $$
DECLARE
    scope_code_val VARCHAR(255);
BEGIN
    SELECT o.code INTO scope_code_val 
    FROM public.organizations o
    JOIN public.organization_members om ON o.id = om.organization_id
    WHERE om.user_id = NEW.created_by_user_id AND om.status = 'active'
    ORDER BY 
      CASE 
        WHEN NEW.scope_type::text = 'Institutional' AND o.type = 'campus-based' THEN 1
        WHEN NEW.scope_type::text = 'Faculty' AND o.type = 'faculty-based' THEN 1
        WHEN NEW.scope_type::text = 'Program' AND o.type = 'program-based' THEN 1
        ELSE 2
      END
    LIMIT 1;

    INSERT INTO public.notifications (
        title,
        content,
        notification_type,
        target_campus_id,
        target_faculty_id,
        target_program_id,
        category,
        action_route,
        metadata
    ) VALUES (
        'New Fee Posted: ' || NEW.name,
        'Amount: ₱' || NEW.amount || '. Please check your fee center to process payments.',
        CASE 
            WHEN NEW.scope_type::text = 'Institutional' THEN 'campus'::text
            WHEN NEW.scope_type::text = 'Faculty' THEN 'faculty'::text
            WHEN NEW.scope_type::text = 'Program' THEN 'program'::text
            ELSE 'global'::text
        END,
        CASE WHEN NEW.scope_type::text = 'Institutional' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'Faculty' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'Program' THEN NEW.scope_id ELSE NULL END,
        'finance',
        '/fees',
        jsonb_build_object('scope_code', COALESCE(scope_code_val, 'GLOBAL'))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create Trigger on fees
DROP TRIGGER IF EXISTS trigger_fee_notification ON public.fees;
CREATE TRIGGER trigger_fee_notification
AFTER INSERT ON public.fees
FOR EACH ROW EXECUTE FUNCTION public.on_fee_created();


-- 4. TRIGGER FUNCTION: Sanction Activated Notification
CREATE OR REPLACE FUNCTION public.on_sanction_activated()
RETURNS TRIGGER AS $$
BEGIN
    -- Detect transition to 'active' status
    IF (TG_OP = 'INSERT' AND NEW.status = 'active') OR (TG_OP = 'UPDATE' AND NEW.status = 'active' AND (OLD.status IS NULL OR OLD.status != 'active')) THEN
        INSERT INTO public.notifications (
            title,
            content,
            notification_type,
            target_user_id,
            category,
            action_route
        ) VALUES (
            'Sanction Period Started',
            'You have an active sanction penalty. Please check your activity status details.',
            'personal',
            NEW.student_id,
            'sanction',
            '/'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create Trigger on student sanction records
DROP TRIGGER IF EXISTS trigger_sanction_active_notification ON public.student_sanction_records;
CREATE TRIGGER trigger_sanction_active_notification
AFTER INSERT OR UPDATE ON public.student_sanction_records
FOR EACH ROW EXECUTE FUNCTION public.on_sanction_activated();
