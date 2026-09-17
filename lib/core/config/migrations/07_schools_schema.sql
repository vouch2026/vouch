-- Migration: 07_schools_schema.sql
-- Description: Create schools table, add RLS select policies, and link school_id foreign keys

CREATE TABLE IF NOT EXISTS public.schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    logo_url VARCHAR(2048),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS and add public read access policy
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to schools" ON public.schools;
CREATE POLICY "Allow public read access to schools" 
ON public.schools FOR SELECT 
USING (true);

DROP POLICY IF EXISTS "Super admins can manage schools" ON public.schools;
CREATE POLICY "Super admins can manage schools" 
ON public.schools FOR ALL 
TO authenticated 
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

-- Seed default university/school
INSERT INTO public.schools (name, code, description)
VALUES ('Davao Oriental State University', 'DORSU', 'Main University System')
ON CONFLICT (code) DO NOTHING;

-- Add school_id foreign key references
ALTER TABLE public.campuses ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES public.schools(id) ON DELETE SET NULL;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES public.schools(id) ON DELETE SET NULL;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES public.schools(id) ON DELETE SET NULL;

-- Link existing campuses, users, and organizations to default school
UPDATE public.campuses 
SET school_id = (SELECT id FROM public.schools WHERE code = 'DORSU' LIMIT 1)
WHERE school_id IS NULL;

UPDATE public.users 
SET school_id = (SELECT id FROM public.schools WHERE code = 'DORSU' LIMIT 1)
WHERE school_id IS NULL;

UPDATE public.organizations 
SET school_id = (SELECT id FROM public.schools WHERE code = 'DORSU' LIMIT 1)
WHERE school_id IS NULL;

