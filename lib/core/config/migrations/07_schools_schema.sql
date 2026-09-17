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

-- 5. Update create_organization_with_members() RPC to support p_school_id
CREATE OR REPLACE FUNCTION create_organization_with_members(
    p_name TEXT,
    p_code TEXT,
    p_description TEXT,
    p_type TEXT,
    p_campus_id UUID DEFAULT NULL,
    p_faculty_id UUID DEFAULT NULL,
    p_program_ids UUID[] DEFAULT '{}',
    p_logo_url TEXT DEFAULT NULL,
    p_banner_url TEXT DEFAULT NULL,
    p_school_id UUID DEFAULT NULL
) RETURNS UUID 
SET search_path = public, pg_temp
AS $$
DECLARE
    v_org_id UUID;
    v_primary_program_id UUID;
    v_effective_school_id UUID;
BEGIN
    IF NOT public.is_super_admin() THEN
        RAISE EXCEPTION 'Access denied: only Super Admins can create organizations.';
    END IF;

    IF p_program_ids IS NOT NULL AND array_length(p_program_ids, 1) > 0 THEN
        v_primary_program_id := p_program_ids[1];
    ELSE
        v_primary_program_id := NULL;
    END IF;

    v_effective_school_id := p_school_id;
    IF v_effective_school_id IS NULL AND p_type = 'school-based' THEN
        SELECT id INTO v_effective_school_id FROM public.schools WHERE code = 'DORSU' LIMIT 1;
    END IF;

    INSERT INTO organizations (name, code, description, type, campus_id, faculty_id, program_id, logo_url, banner_url, school_id)
    VALUES (p_name, p_code, p_description, p_type, p_campus_id, p_faculty_id, v_primary_program_id, p_logo_url, p_banner_url, v_effective_school_id)
    RETURNING id INTO v_org_id;

    IF p_type = 'school-based' THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT v_org_id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
        FROM public.users u
        JOIN public.user_roles ur ON u.id = ur.user_id
        JOIN public.roles r ON ur.role_id = r.id
        WHERE (v_effective_school_id IS NULL OR u.school_id = v_effective_school_id OR u.school_id IS NULL)
          AND r.name = 'Students'
          AND ur.is_active = true
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'campus-based' AND p_campus_id IS NOT NULL THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT v_org_id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
        FROM public.users u
        JOIN public.user_roles ur ON u.id = ur.user_id
        JOIN public.roles r ON ur.role_id = r.id
        WHERE u.campus_id = p_campus_id
          AND r.name = 'Students'
          AND ur.is_active = true
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'faculty-based' AND p_faculty_id IS NOT NULL THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT v_org_id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
        FROM public.users u
        JOIN public.user_roles ur ON u.id = ur.user_id
        JOIN public.roles r ON ur.role_id = r.id
        WHERE u.faculty_id = p_faculty_id
          AND r.name = 'Students'
          AND ur.is_active = true
        ON CONFLICT DO NOTHING;
    ELSIF p_type = 'program-based' AND p_program_ids IS NOT NULL AND array_length(p_program_ids, 1) > 0 THEN
        INSERT INTO organization_members (organization_id, user_id, role_id)
        SELECT v_org_id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
        FROM public.users u
        JOIN public.user_roles ur ON u.id = ur.user_id
        JOIN public.roles r ON ur.role_id = r.id
        WHERE u.program_id = ANY(p_program_ids)
          AND r.name = 'Students'
          AND ur.is_active = true
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN v_org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


