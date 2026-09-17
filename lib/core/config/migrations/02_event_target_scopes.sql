-- Migration: 02_event_target_scopes.sql
-- Description: Multi-level mandatory target scope mapping for events across 4 workspace tiers

CREATE TABLE IF NOT EXISTS public.event_target_scopes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    target_type scope_type NOT NULL, -- 'Institutional', 'Faculty', 'Program'
    target_id UUID NOT NULL,        -- campus_id, faculty_id, or program_id
    is_mandatory BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, target_type, target_id)
);

CREATE INDEX IF NOT EXISTS idx_event_target_scopes_event_id ON public.event_target_scopes(event_id);
CREATE INDEX IF NOT EXISTS idx_event_target_scopes_target ON public.event_target_scopes(target_type, target_id);
