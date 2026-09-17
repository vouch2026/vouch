-- Migration: 05_multi_term_membership_schema.sql
-- Description: Multi-term organization membership constraints and user registration term tracking

-- 1. Add registered_term_id to users
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS registered_term_id UUID REFERENCES public.academic_terms(id) ON DELETE SET NULL;

-- 2. Update organization_members unique key to include academic_term_id
ALTER TABLE public.organization_members DROP CONSTRAINT IF EXISTS organization_members_organization_id_user_id_key;
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'organization_members_org_user_term_key'
    ) THEN
        ALTER TABLE public.organization_members 
        ADD CONSTRAINT organization_members_org_user_term_key UNIQUE (organization_id, user_id, academic_term_id);
    END IF;
END $$;

-- 3. Update comselec_members unique key to include academic_term_id
ALTER TABLE public.comselec_members DROP CONSTRAINT IF EXISTS comselec_members_comselec_id_user_id_key;
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'comselec_members_com_user_term_key'
    ) THEN
        ALTER TABLE public.comselec_members 
        ADD CONSTRAINT comselec_members_com_user_term_key UNIQUE (comselec_id, user_id, academic_term_id);
    END IF;
END $$;
