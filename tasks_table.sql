-- SQL script to create the tasks table in Supabase.
-- Run this in your Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
-- Users can only read, create, update, or delete their own tasks.

CREATE POLICY "Allow users to read their own tasks" 
ON public.tasks
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Allow users to insert their own tasks" 
ON public.tasks
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to update their own tasks" 
ON public.tasks
FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to delete their own tasks" 
ON public.tasks
FOR DELETE 
USING (auth.uid() = user_id);
