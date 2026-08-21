DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Loop through all tables in the public schema
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        -- Execute drop with CASCADE to cleanly bypass foreign key constraints
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;



-- 1. Delete all references to files contained inside the buckets
TRUNCATE TABLE storage.objects CASCADE;

-- 2. Delete all the storage buckets
TRUNCATE TABLE storage.buckets CASCADE;
