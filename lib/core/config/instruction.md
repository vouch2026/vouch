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
        v_scope_id := '00000000-0000-0000-0000-000000000000';
    ELSIF v_role = 'comselec_commissioner' THEN
        SELECT id INTO target_role_id FROM public.roles WHERE name = 'COMSELEC Commissioner';
        v_scope_type := 'Institutional';
        v_scope_id := '00000000-0000-0000-0000-000000000000';
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







--- new -----

1. Log in to your Supabase Dashboard.
   2. Click on the SQL Editor icon in the left-hand navigation bar (it looks like a >_).
   3. Click "New query" to open a blank editor.
   4. Copy and paste the entire block of SQL code below into the editor:

     1 -- 1. Add the Instructor role to your database
     2 INSERT INTO roles (name, hierarchy_level) 
     3 SELECT 'Instructor', 65
     4 WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'Instructor');
     5
     6 -- 2. Update the trigger function to handle the instructor position
     7 CREATE OR REPLACE FUNCTION public.handle_new_user()
     8 RETURNS trigger AS $$
     9 DECLARE
    10     new_user_id UUID;
    11     target_role_id UUID;
    12     v_role TEXT;
    13     v_position TEXT;
    14     v_scope_type public.scope_type;
    15     v_scope_id UUID;
    16     v_faculty_id UUID;
    17     v_program_id UUID;
    18 BEGIN
    19     -- 1. Extract and Validate Metadata
    20     v_role := new.raw_user_meta_data->>'role';
    21     v_position := new.raw_user_meta_data->>'position';
    22     
    23     -- Safe casting for UUIDs
    24     v_faculty_id := (NULLIF(new.raw_user_meta_data->>'faculty_id', ''))::uuid;
    25     v_program_id := (NULLIF(new.raw_user_meta_data->>'program_id', ''))::uuid;
    26
    27     -- 2. Verify Foreign Keys
    28     IF v_faculty_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public.faculties WHERE id = v_faculty_id) THEN
    29         v_faculty_id := NULL;
    30     END IF;
    31     IF v_program_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public.programs WHERE id = v_program_id) THEN
    32         v_program_id := NULL;
    33     END IF;
    34
    35     -- 3. Upsert into public.users
    36     INSERT INTO public.users (
    37         auth_id, 
    38         email, 
    39         first_name, 
    40         last_name, 
    41         student_id_number, 
    42         faculty_id, 
    43         program_id, 
    44         year,
    45         account_status
    46     )
    47     VALUES (
    48         new.id, 
    49         new.email, 
    50         COALESCE(new.raw_user_meta_data->>'first_name', ''),
    51         COALESCE(new.raw_user_meta_data->>'last_name', ''), 
    52         COALESCE(NULLIF(new.raw_user_meta_data->>'school_id', ''), 'PENDING-' || substr(new.id::text, 1, 8)),
    53         v_faculty_id,
    54         v_program_id,
    55         (NULLIF(new.raw_user_meta_data->>'year_level', ''))::int,
    56         COALESCE(new.raw_user_meta_data->>'status', 'active')
    57     )
    62     ON CONFLICT (auth_id) DO UPDATE SET
    63         email = EXCLUDED.email,
    64         first_name = EXCLUDED.first_name,
    65         last_name = EXCLUDED.last_name,
    66         faculty_id = EXCLUDED.faculty_id,
    67         program_id = EXCLUDED.program_id,
    68         updated_at = CURRENT_TIMESTAMP
    69     RETURNING id INTO new_user_id;
    70
    71     -- 4. Determine Role and Scope
    72     IF v_role = 'super_admin' THEN
    73         SELECT id INTO target_role_id FROM public.roles WHERE name = 'Super Admin';
    74         v_scope_type := 'Institutional';
    75         v_scope_id := '00000000-0000-0000-0000-000000000000';
    76     ELSIF v_role = 'student' THEN
    77         SELECT id INTO target_role_id FROM public.roles WHERE name = 'Students';
    78         v_scope_type := 'Program';
    79         v_scope_id := v_program_id;
    80     ELSIF v_role = 'voter' OR v_role = 'voters' THEN
    81         SELECT id INTO target_role_id FROM public.roles WHERE name = 'Voters';
    82         v_scope_type := 'Program';
    83         v_scope_id := v_program_id;
    84     ELSIF v_role = 'personnel' THEN
    85         SELECT id INTO target_role_id FROM public.roles WHERE name = 'Personnel';
    86         v_scope_type := 'Faculty';
    87         v_scope_id := v_faculty_id;
    88     ELSIF v_role = 'comselec_chairman' OR v_role = 'comselec_chair' THEN
    89         SELECT id INTO target_role_id FROM public.roles WHERE name = 'Comselec Chair';
    90         v_scope_type := 'Institutional';
    91         v_scope_id := '00000000-0000-0000-0000-000000000000';
    92     ELSIF v_role = 'comselec_commissioner' THEN
    93         SELECT id INTO target_role_id FROM public.roles WHERE name = 'COMSELEC Commissioner';
    94         v_scope_type := 'Institutional';
    95         v_scope_id := '00000000-0000-0000-0000-000000000000';
    96     ELSIF v_role = 'faculty' THEN
    97         IF v_position = 'dean' THEN
    98             SELECT id INTO target_role_id FROM public.roles WHERE name = 'Faculty Dean';
    99             v_scope_type := 'Faculty';
   100             v_scope_id := v_faculty_id;
   101         ELSIF v_position = 'program_head' THEN
   102             SELECT id INTO target_role_id FROM public.roles WHERE name = 'Program Head';
   103             v_scope_type := 'Program';
   104             v_scope_id := v_program_id;
   105         ELSIF v_position = 'instructor' THEN
   106             -- NEW logic to handle the generic instructor position
   107             SELECT id INTO target_role_id FROM public.roles WHERE name = 'Instructor';
   108             v_scope_type := 'Faculty';
   109             v_scope_id := v_faculty_id;
   110         END IF;
   111     END IF;
    96
    97     -- 5. Assign Role (Only if determined and scope is valid)
    98     IF target_role_id IS NOT NULL AND v_scope_id IS NOT NULL THEN
    99         INSERT INTO public.user_roles (user_id, role_id, scope_type, scope_id)
   100         VALUES (new_user_id, target_role_id, v_scope_type, v_scope_id)
   101         ON CONFLICT DO NOTHING;
   102     END IF;
   103
   104     RETURN new;
   105 EXCEPTION WHEN OTHERS THEN
   106     RETURN new;
   107 END;
   108 $$ LANGUAGE plpgsql SECURITY DEFINER;

   5. Click the "Run" button.