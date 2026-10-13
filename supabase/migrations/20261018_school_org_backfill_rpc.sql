-- Migration: create_organization_with_members() gains school support.
--
-- Context: the RPC backfills Members for campus/faculty/program-based orgs
-- at creation time, but had no school-based branch — creating a school-wide
-- org (e.g. a second USC) pulled in zero students. This adds:
--   1. p_school_id UUID param (DEFAULT NULL: existing callers keep working).
--   2. school_id written onto the new organizations row (guarded no-op on
--      pre-schools DBs).
--   3. ELSIF p_type = 'school-based' branch backfilling every active student
--      whose users.school_id matches, mirroring the campus-based predicate.
--
-- Requires migration 20261012 for the new behavior; safe to apply without
-- it (old branches behave exactly as before).

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
BEGIN
    IF NOT public.is_super_admin() THEN
        RAISE EXCEPTION 'Access denied: only Super Admins can create organizations.';
    END IF;

    IF p_program_ids IS NOT NULL AND array_length(p_program_ids, 1) > 0 THEN
        v_primary_program_id := p_program_ids[1];
    ELSE
        v_primary_program_id := NULL;
    END IF;

    INSERT INTO organizations (name, code, description, type, campus_id, faculty_id, program_id, logo_url, banner_url)
    VALUES (p_name, p_code, p_description, p_type, p_campus_id, p_faculty_id, v_primary_program_id, p_logo_url, p_banner_url)
    RETURNING id INTO v_org_id;

    -- Attach the school when supplied (guarded no-op on pre-schools DBs).
    IF p_school_id IS NOT NULL THEN
        BEGIN
            UPDATE public.organizations SET school_id = p_school_id WHERE id = v_org_id;
        EXCEPTION WHEN undefined_column THEN
            NULL;
        END;
    END IF;

    IF p_type = 'campus-based' AND p_campus_id IS NOT NULL THEN
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
    ELSIF p_type = 'school-based' AND p_school_id IS NOT NULL THEN
        BEGIN
            INSERT INTO organization_members (organization_id, user_id, role_id)
            SELECT v_org_id, u.id, (SELECT id FROM public.roles WHERE name = 'Member')
            FROM public.users u
            JOIN public.user_roles ur ON u.id = ur.user_id
            JOIN public.roles r ON ur.role_id = r.id
            WHERE u.school_id = p_school_id
              AND r.name = 'Students'
              AND ur.is_active = true
            ON CONFLICT DO NOTHING;
        EXCEPTION WHEN undefined_column THEN
            -- Pre-schools DB (no users.school_id): members skipped, org kept.
            NULL;
        END;
    END IF;

    RETURN v_org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
