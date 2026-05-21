# Supabase Database Setup & Troubleshooting

This document outlines the correct procedure for initializing and updating the Vouch database schema in Supabase, specifically addressing common issues like the `500 AuthRetryableFetchException` during user signup.

## How to Run the SQL Script Correctly

When running the `supabase_based.sql` script, especially after making changes or tearing down the database, you must follow these steps in order to prevent foreign key errors and stale data issues.

### Step 1: Prepare the Supabase Environment

1.  Open your [Supabase Dashboard](https://app.supabase.com/).
2.  Navigate to the **SQL Editor** from the left sidebar.
3.  Click **New Query**.

### Step 2: Clear Existing Auth Users (CRITICAL)

If you are resetting the database or encountering the `Database error saving new user` error, you **must** delete existing users from the authentication system. The SQL script only drops tables in the `public` schema, it does *not* delete users from the hidden `auth.users` table.

1.  In the Supabase Dashboard, go to **Authentication** -> **Users**.
2.  Delete the test user(s) you were trying to sign up with.
    *   *Why?* If the email exists in `auth.users` but the profile wasn't created in `public.users` (due to a previous error), trying to sign up again will fail with a unique constraint error.

### Step 3: Run the Script

1.  Copy the **entire contents** of `lib/core/config/supabase_based.sql`.
2.  Paste it into the new query window in the SQL Editor.
3.  Click the **Run** button (or press `Cmd/Ctrl + Enter`).
4.  Ensure the "Success" message appears in the results panel. If there are errors, they will be listed here.

### Step 4: Refresh the Client App (CRITICAL)

The teardown script (`DROP TABLE ... CASCADE`) deletes the old records for Faculties and Programs and then immediately recreates them. Because the primary keys use `gen_random_uuid()`, the **new records have completely different IDs**.

If your Flutter app was running while you ran the script, it is holding **stale IDs** in its memory.

1.  **Fully Stop and Restart** your Flutter application (a simple Hot Reload is not enough; perform a **Hot Restart** or stop the debugger and run it again).
2.  *Why?* When the user fills out the registration form, the app sends the selected `faculty_id` and `program_id` to Supabase. If these IDs belong to the *old*, deleted database tables, the `handle_new_user` trigger will reject the insert because of a Foreign Key violation, resulting in the 500 error.

---

## Troubleshooting the "Database error saving new user" (500 Error)

If you have followed the steps above and still receive the error:

### 1. Isolate the Trigger
To determine if the PostgreSQL trigger (`handle_new_user`) is the cause of the failure, temporarily disable it:

1.  Run this in the SQL Editor:
    ```sql
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    ```
2.  Attempt to sign up in the app again.
    *   **If it succeeds:** The issue is definitively in the `handle_new_user` function logic (likely a data mismatch).
    *   **If it still fails:** The issue is outside the trigger—check your Supabase Auth configuration (e.g., SMTP settings, missing email templates, or an internal Supabase issue).
3.  **Remember to re-enable the trigger** by re-running the trigger creation part of the `supabase_based.sql` script once you finish testing.

### 2. Check the Server Logs
Supabase provides detailed logs that explain exactly *why* a trigger failed.
1.  Go to **Logs** -> **Postgres Logs** in the Supabase Dashboard.
2.  Look for errors around the time you attempted to sign up. You will likely see an error like `insert or update on table "users" violates foreign key constraint` or `invalid input syntax for type uuid`.

### 3. Verify RLS Policies
Ensure that the Row Level Security policies aren't preventing the trigger from executing properly. Because the trigger is defined with `SECURITY DEFINER`, it bypasses RLS, but it's good practice to verify the policies are correctly applied.