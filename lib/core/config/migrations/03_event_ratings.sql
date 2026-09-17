-- Migration: 03_event_ratings.sql
-- Description: Custom evaluation questions (stars & emojis) and student rating responses

CREATE TABLE IF NOT EXISTS public.event_rating_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) NOT NULL CHECK (question_type IN ('star', 'emoji')),
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.event_rating_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    question_id UUID REFERENCES public.event_rating_questions(id) ON DELETE CASCADE,
    rating_value INT NOT NULL CHECK (rating_value BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, student_id, question_id)
);

CREATE INDEX IF NOT EXISTS idx_rating_questions_event ON public.event_rating_questions(event_id);
CREATE INDEX IF NOT EXISTS idx_rating_responses_event ON public.event_rating_responses(event_id);
CREATE INDEX IF NOT EXISTS idx_rating_responses_student ON public.event_rating_responses(student_id);
