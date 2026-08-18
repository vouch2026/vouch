-- ==============================================================================
-- STANDALONE NOTIFICATION MODULE SETUP MIGRATION
-- Run this in your Supabase SQL Editor to add the Notification tables,
-- indexes, and RLS policies without affecting any existing tables or data.
-- ==============================================================================

-- 1. Create Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL CHECK (
        notification_type IN ('personal', 'program', 'faculty', 'campus', 'global')
    ),
    
    -- Target Identifiers (Conditional depending on type)
    target_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    target_program_id UUID REFERENCES public.programs(id) ON DELETE CASCADE,
    target_faculty_id UUID REFERENCES public.faculties(id) ON DELETE CASCADE,
    target_campus_id UUID REFERENCES public.campuses(id) ON DELETE CASCADE,
    
    -- Metadata & Routing
    category VARCHAR(50) DEFAULT 'general' CHECK (
        category IN ('announcement', 'event', 'sanction', 'election', 'finance', 'general')
    ),
    action_route VARCHAR(255), -- GoRouter path for deep linking e.g. '/events/123'
    metadata JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Trigger for auto-updating updated_at column
CREATE OR REPLACE TRIGGER update_notifications_updated_at 
BEFORE UPDATE ON public.notifications 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- 2. Create Read Receipts Table
CREATE TABLE IF NOT EXISTS public.user_notification_reads (
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (user_id, notification_id)
);


-- 2.1 Create FCM Tokens Table
CREATE TABLE IF NOT EXISTS public.user_fcm_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL UNIQUE,
    device_type VARCHAR(50), -- 'android', 'ios', 'web'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);


-- 3. Create Performance & Lookups Indexes
CREATE INDEX IF NOT EXISTS idx_notifications_targets ON public.notifications (
    target_user_id, 
    target_program_id, 
    target_faculty_id, 
    target_campus_id
);
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON public.user_fcm_tokens(user_id);


-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notification_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;


-- 5. Define Security Policies

-- Read policy for notifications based on dynamic target matching
CREATE POLICY "Users can view relevant notifications" ON public.notifications
    FOR SELECT TO authenticated
    USING (
        notification_type = 'global'
        OR target_user_id = public.get_my_id()
        OR target_program_id = (SELECT program_id FROM public.users WHERE id = public.get_my_id())
        OR target_faculty_id = (SELECT faculty_id FROM public.users WHERE id = public.get_my_id())
        OR target_campus_id = (SELECT campus_id FROM public.users WHERE id = public.get_my_id())
    );

-- Insert policy for notifications (Admins and Governors/PIOs)
CREATE POLICY "Authorized roles can send notifications" ON public.notifications
    FOR INSERT TO authenticated
    WITH CHECK (
        public.is_super_admin()
        OR EXISTS (
            SELECT 1 FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE ur.user_id = public.get_my_id() 
            AND r.name IN ('governor', 'pio', 'secretary')
        )
    );

-- Read/Write policies for read receipts
CREATE POLICY "Users can view their own read receipts" ON public.user_notification_reads
    FOR SELECT TO authenticated
    USING (user_id = public.get_my_id());

CREATE POLICY "Users can mark their own notifications as read" ON public.user_notification_reads
    FOR INSERT TO authenticated
    WITH CHECK (user_id = public.get_my_id());

-- RLS policies for user_fcm_tokens
CREATE POLICY "Users can view FCM tokens" ON public.user_fcm_tokens
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Users can insert their own FCM tokens" ON public.user_fcm_tokens
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update FCM tokens to their own" ON public.user_fcm_tokens
    FOR UPDATE TO authenticated
    USING (true)
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own FCM tokens" ON public.user_fcm_tokens
    FOR DELETE TO authenticated
    USING (user_id = auth.uid());
