-- SQL script to create the subject_schedules table in Supabase.
-- Run this in your Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS public.subject_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    subject_code TEXT NOT NULL,
    subject_name TEXT NOT NULL,
    teacher TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    days TEXT[] NOT NULL,
    room TEXT NOT NULL DEFAULT '',
    academic_term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.subject_schedules ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
-- Users can only read, create, update, or delete their own schedules.

CREATE POLICY "Allow users to read their own schedules"
ON public.subject_schedules
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Allow users to insert their own schedules" 
ON public.subject_schedules
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to update their own schedules" 
ON public.subject_schedules
FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to delete their own schedules" 
ON public.subject_schedules
FOR DELETE 
USING (auth.uid() = user_id);
