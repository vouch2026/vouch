-- Migration to add registration auto-activation options

-- 1. Create system settings table if not exists
CREATE TABLE IF NOT EXISTS public.system_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- Drop policies if they already exist to avoid errors
DROP POLICY IF EXISTS "System settings are viewable by authenticated users" ON public.system_settings;
DROP POLICY IF EXISTS "Only Super Admins can manage system settings" ON public.system_settings;

-- Create viewing policy (everyone authenticated can view system settings)
CREATE POLICY "System settings are viewable by authenticated users" 
ON public.system_settings FOR SELECT 
TO authenticated 
USING (true);

-- Create manage policy (Only Super Admins can manage system settings)
CREATE POLICY "Only Super Admins can manage system settings" 
ON public.system_settings 
FOR ALL 
TO authenticated 
USING (public.is_super_admin());

-- Initialize default auto-activation setting to false (manual approval)
INSERT INTO public.system_settings (key, value)
VALUES ('auto_activate_registrations', '{"enabled": false}'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- 2. Update user creation trigger function to query and apply the setting
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
    new_user_id UUID;
    target_role_id UUID;
    v_role TEXT;
    v_position TEXT;
    v_scope_type public.scope_type;
    v_scope_id UUID;
    v_faculty_id UUID;
    v_program_id UUID;
    v_campus_id UUID;
    v_auto_activate BOOLEAN := false;
BEGIN
    v_role := new.raw_user_meta_data->>'role';
    v_position := new.raw_user_meta_data->>'position';
    v_campus_id := (NULLIF(new.raw_user_meta_data->>'campus_id', ''))::uuid;
    v_faculty_id := (NULLIF(new.raw_user_meta_data->>'faculty_id', ''))::uuid;
    v_program_id := (NULLIF(new.raw_user_meta_data->>'program_id', ''))::uuid;

    -- Fetch the setting dynamically from system_settings table if it exists
    BEGIN
        SELECT COALESCE((value->>'enabled')::boolean, false) INTO v_auto_activate
        FROM public.system_settings
        WHERE key = 'auto_activate_registrations';
    EXCEPTION WHEN OTHERS THEN
        v_auto_activate := false;
    END;

    IF v_campus_id IS NULL AND v_faculty_id IS NOT NULL THEN
        SELECT campus_id INTO v_campus_id FROM public.faculties WHERE id = v_faculty_id;
    END IF;

    INSERT INTO public.users (
        auth_id, email, first_name, last_name, student_id_number, 
        campus_id, faculty_id, program_id, year, account_status
    )
    VALUES (
        new.id, new.email, 
        COALESCE(new.raw_user_meta_data->>'first_name', ''),
        COALESCE(new.raw_user_meta_data->>'last_name', ''), 
        COALESCE(NULLIF(new.raw_user_meta_data->>'school_id', ''), 'PENDING-' || substr(new.id::text, 1, 8)),
        v_campus_id, v_faculty_id, v_program_id,
        (NULLIF(new.raw_user_meta_data->>'year_level', ''))::int,
        CASE 
            WHEN v_auto_activate THEN 'active'
            ELSE COALESCE(new.raw_user_meta_data->>'status', 'pending')
        END
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        campus_id = EXCLUDED.campus_id,
        faculty_id = EXCLUDED.faculty_id,
        program_id = EXCLUDED.program_id,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO new_user_id;

    IF v_role = 'super_admin' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Super Admin';
        v_scope_type := 'Institutional';
        v_scope_id := '00000000-0000-0000-0000-000000000000';
    ELSIF v_role = 'student' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Students';
        v_scope_type := 'Program';
        v_scope_id := v_program_id;
    ELSIF v_role = 'voter' OR v_role = 'voters' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Voters';
        v_scope_type := 'Program';
        v_scope_id := v_program_id;
    ELSIF v_role = 'personnel' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Personnel';
        v_scope_type := 'Faculty';
        v_scope_id := v_faculty_id;
    ELSIF v_role = 'comselec_chairman' OR v_role = 'comselec_chair' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Comselec Chair';
        v_scope_type := 'Institutional';
        v_scope_id := COALESCE(v_campus_id, '00000000-0000-0000-0000-000000000000'::uuid);
    ELSIF v_role = 'comselec_commissioner' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'COMSELEC Commissioner';
        v_scope_type := 'Institutional';
        v_scope_id := COALESCE(v_campus_id, '00000000-0000-0000-0000-000000000000'::uuid);
    ELSIF v_role = 'faculty' THEN
        IF v_position = 'dean' THEN
            SELECT id INTO target_role_id FROM public.roles WHERE name = 'Faculty Dean';
            v_scope_type := 'Faculty';
            v_scope_id := v_faculty_id;
        ELSIF v_position = 'program_head' THEN
            SELECT id INTO target_role_id FROM public.roles WHERE name = 'Program Head';
            v_scope_type := 'Program';
            v_scope_id := v_program_id;
        ELSIF v_position = 'instructor' THEN
            SELECT id INTO target_role_id FROM public.roles WHERE name = 'Instructor';
            v_scope_type := 'Faculty';
            v_scope_id := v_faculty_id;
        END IF;
    END IF;

    IF target_role_id IS NOT NULL AND v_scope_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
        VALUES (new_user_id, target_role_id, v_scope_type, v_scope_id)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Only auto-assign students to their respective organizations as Members
    IF v_role = 'student' THEN
        IF v_campus_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Member')
            FROM public.organizations 
            WHERE type = 'campus-based' AND campus_id = v_campus_id
            ON CONFLICT DO NOTHING;
        END IF;

        IF v_faculty_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Member')
            FROM public.organizations 
            WHERE type = 'faculty-based' AND faculty_id = v_faculty_id
            ON CONFLICT DO NOTHING;
        END IF;

        IF v_program_id IS NOT NULL THEN
            INSERT INTO public.organization_members (organization_id, user_id, role_id)
            SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Member')
            FROM public.organizations 
            WHERE type = 'program-based' AND program_id = v_program_id
            ON CONFLICT DO NOTHING;
        END IF;

        -- Automatically assign student as Voter in COMSELEC
        IF v_campus_id IS NOT NULL THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id)
            SELECT id, new_user_id, (SELECT id FROM public.roles WHERE name = 'Voters')
            FROM public.comselecs 
            WHERE campus_id = v_campus_id
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;

    -- Auto-assign Comselec officers to their respective Comselec
    IF v_role IN ('comselec_chairman', 'comselec_chair', 'comselec_commissioner') THEN
        IF v_campus_id IS NOT NULL THEN
            INSERT INTO public.comselec_members (comselec_id, user_id, role_id)
            SELECT id, new_user_id, target_role_id
            FROM public.comselecs 
            WHERE campus_id = v_campus_id
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;

    RETURN new;
EXCEPTION WHEN OTHERS THEN
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
