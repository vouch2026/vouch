run all the content in the supabase_based.sql then 



DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;


--- Then run this ---

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
BEGIN
    -- 1. Extract and Validate Metadata
    v_role := new.raw_user_meta_data->>'role';
    v_position := new.raw_user_meta_data->>'position';
    
    -- Safe casting for UUIDs
    v_faculty_id := (NULLIF(new.raw_user_meta_data->>'faculty_id', ''))::uuid;
    v_program_id := (NULLIF(new.raw_user_meta_data->>'program_id', ''))::uuid;

    -- 2. Verify Foreign Keys (Crucial if DB was recently reset)
    IF v_faculty_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public.faculties WHERE id = v_faculty_id) THEN
        v_faculty_id := NULL;
    END IF;
    IF v_program_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public.programs WHERE id = v_program_id) THEN
        v_program_id := NULL;
    END IF;

    -- 3. Upsert into public.users (Handles existing records and stale FKs)
    INSERT INTO public.users (
        auth_id, 
        email, 
        first_name, 
        last_name, 
        student_id_number, 
        faculty_id, 
        program_id, 
        year,
        id_front_url,
        id_back_url,
        account_status
    )
    VALUES (
        new.id, 
        new.email, 
        COALESCE(new.raw_user_meta_data->>'first_name', ''),
        COALESCE(new.raw_user_meta_data->>'last_name', ''), 
        COALESCE(NULLIF(new.raw_user_meta_data->>'school_id', ''), 'PENDING-' || substr(new.id::text, 1, 8)),
        v_faculty_id,
        v_program_id,
        (NULLIF(new.raw_user_meta_data->>'year_level', ''))::int,
        new.raw_user_meta_data->>'id_front_url',
        new.raw_user_meta_data->>'id_back_url',
        COALESCE(new.raw_user_meta_data->>'status', 'active')
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        faculty_id = EXCLUDED.faculty_id,
        program_id = EXCLUDED.program_id,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO new_user_id;

    -- 4. Determine Role and Scope
    IF v_role = 'super_admin' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Super Admin';
        v_scope_type := 'Institutional';
        v_scope_id := '00000000-0000-0000-0000-000000000000';
    ELSIF v_role = 'student' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'Students';
        v_scope_type := 'Program';
        v_scope_id := v_program_id;
    ELSIF v_role = 'faculty' THEN
        IF v_position = 'dean' THEN
            SELECT id INTO target_role_id FROM public.roles WHERE name = 'Faculty Dean';
            v_scope_type := 'Faculty';
            v_scope_id := v_faculty_id;
        ELSIF v_position = 'program_head' THEN
            SELECT id INTO target_role_id FROM public.roles WHERE name = 'Program Head';
            v_scope_type := 'Program';
            v_scope_id := v_program_id;
        END IF;
    END IF;

    -- 5. Assign Role (Only if determined and scope is valid)
    IF target_role_id IS NOT NULL AND v_scope_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
        VALUES (new_user_id, target_role_id, v_scope_type, v_scope_id)
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN new;
EXCEPTION WHEN OTHERS THEN
    -- Gracefully handle errors to prevent 500 AuthRetryableFetchException
    -- This ensures the auth user is still created even if the profile insertion fails
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

