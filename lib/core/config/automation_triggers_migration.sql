-- ==============================================================================
-- STANDALONE NOTIFICATION AUTOMATION TRIGGERS
-- Run this in your Supabase SQL Editor to automate notification delivery
-- when events, announcements, fees are created, or when sanctions start.
-- ==============================================================================

-- 1. TRIGGER FUNCTION: New Announcements Notification
CREATE OR REPLACE FUNCTION public.on_announcement_created()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.notifications (
        sender_id,
        title,
        content,
        notification_type,
        target_campus_id,
        target_faculty_id,
        target_program_id,
        category,
        action_route
    ) VALUES (
        NEW.created_by_user_id,
        'New Announcement: ' || NEW.title,
        substring(NEW.content from 1 for 150),
        CASE 
            WHEN NEW.scope_type::text = 'campus' THEN 'campus'::text
            WHEN NEW.scope_type::text = 'faculty' THEN 'faculty'::text
            WHEN NEW.scope_type::text = 'program' THEN 'program'::text
            ELSE 'global'::text
        END,
        CASE WHEN NEW.scope_type::text = 'campus' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'faculty' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'program' THEN NEW.scope_id ELSE NULL END,
        'announcement',
        '/announcements'
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
BEGIN
    INSERT INTO public.notifications (
        sender_id,
        title,
        content,
        notification_type,
        target_campus_id,
        target_faculty_id,
        target_program_id,
        category,
        action_route
    ) VALUES (
        NEW.created_by_user_id,
        'Upcoming Event: ' || NEW.name,
        'Date: ' || NEW.event_date || ' | Location: ' || NEW.location || '. ' || COALESCE(NEW.short_description, ''),
        CASE 
            WHEN NEW.scope_type::text = 'campus' THEN 'campus'::text
            WHEN NEW.scope_type::text = 'faculty' THEN 'faculty'::text
            WHEN NEW.scope_type::text = 'program' THEN 'program'::text
            ELSE 'global'::text
        END,
        CASE WHEN NEW.scope_type::text = 'campus' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'faculty' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'program' THEN NEW.scope_id ELSE NULL END,
        'event',
        '/events'
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
BEGIN
    INSERT INTO public.notifications (
        title,
        content,
        notification_type,
        target_campus_id,
        target_faculty_id,
        target_program_id,
        category,
        action_route
    ) VALUES (
        'New Fee Posted: ' || NEW.name,
        'Amount: ₱' || NEW.amount || '. Please check your fee center to process payments.',
        CASE 
            WHEN NEW.scope_type::text = 'campus' THEN 'campus'::text
            WHEN NEW.scope_type::text = 'faculty' THEN 'faculty'::text
            WHEN NEW.scope_type::text = 'program' THEN 'program'::text
            ELSE 'global'::text
        END,
        CASE WHEN NEW.scope_type::text = 'campus' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'faculty' THEN NEW.scope_id ELSE NULL END,
        CASE WHEN NEW.scope_type::text = 'program' THEN NEW.scope_id ELSE NULL END,
        'finance',
        '/fees'
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
