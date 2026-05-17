-- Create a table for public profiles if it doesn't exist
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  full_name text,
  school_id text,
  faculty text,
  program text,
  year_level int,
  avatar_url text,
  id_front_url text,
  id_back_url text,
  role text default 'student' check (role in (
    'super_admin',
    'comselec_chairman',
    'comselec_commissioner',
    'adviser',
    'governor',
    'secretary',
    'treasurer',
    'pio',
    'staff',
    'student'
  )),
  status text default 'pending' check (status in (
    'pending',
    'approved',
    'rejected',
    'suspended',
    'archived'
  )),
  organization_ids text[] default '{}',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Set up Row Level Security (RLS)
alter table public.profiles
  enable row level security;

-- Drop existing policies if they exist before creating them
drop policy if exists "Public profiles are viewable by everyone." on public.profiles;
drop policy if exists "Users can insert their own profile." on public.profiles;
drop policy if exists "Users can update own profile." on public.profiles;

create policy "Public profiles are viewable by everyone." on public.profiles
  for select using (true);

create policy "Users can insert their own profile." on public.profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on public.profiles
  for update using (auth.uid() = id);

-- This function automatically creates a profile entry when a new user signs up via Supabase Auth.
-- It also assigns 'super_admin' role to the first user.
create or replace function public.handle_new_user()
returns trigger as $$
declare
  is_first_user boolean;
begin
  select count(*) = 0 into is_first_user from public.profiles;

  insert into public.profiles (id, full_name, school_id, faculty, program, year_level, id_front_url, id_back_url, role, status)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'school_id',
    new.raw_user_meta_data->>'faculty',
    new.raw_user_meta_data->>'program',
    (new.raw_user_meta_data->>'year_level')::int,
    new.raw_user_meta_data->>'id_front_url',
    new.raw_user_meta_data->>'id_back_url',
    case when is_first_user then 'super_admin' else 'student' end,
    case when is_first_user then 'approved' else 'pending' end
  );
  return new;
end;
$$ language plpgsql security definer;

-- Drop trigger if exists to avoid conflict when re-running the script
drop trigger if exists on_auth_user_created on auth.users;

-- Re-create the trigger
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
