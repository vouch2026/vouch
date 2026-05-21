# Supabase Setup Guide

Follow these 3 simple steps to initialize or reset your database correctly.

### Step 1: Clear Existing Users (CRITICAL)
Before running the script, you must remove old data from the auth system:
1. Go to your **Supabase Dashboard**.
2. Navigate to **Authentication -> Users**.
3. **Delete** all existing test users.
   * *Why?* This prevents "user already exists" conflicts if a previous setup failed halfway.

### Step 2: Run the SQL Script
1. Open the **SQL Editor** in Supabase (the `>_` icon).
2. Click **New Query**.
3. Copy the **WHOLE CONTENT** from `lib/core/config/supabase_based.sql`.
4. Paste it into the editor and click **Run**.
5. Ensure you see a "Success" message.

### Step 3: Create Storage Buckets (CRITICAL)
For images to work, you must create these buckets in **Storage**:
1.  **ids**: Set to **Private**. (For user verification IDs)
2.  **org-pictures**: Set to **Public**. (For organization logos and banners)

### Step 4: Restart Your Flutter App (CRITICAL)
1. **Fully stop and restart** your Flutter application.
2. **Hot Reload is NOT enough.** Perform a **Hot Restart** or stop the debugger and run it again.
   * *Why?* The script recreates tables with new IDs. Your app must refresh its memory to use these new IDs, otherwise, it will crash with "Foreign Key" errors.

---

## Troubleshooting (500 Error)
If you get a "Database error saving new user" (500):
1. **Check Logs:** Go to **Logs -> Postgres Logs** in Supabase to see the exact error message.
2. **Missing IDs:** Ensure you have actually created the Faculty/Program records by running the script in Step 2.
3. **Stale Data:** Re-do Step 1 (Delete Users) and Step 3 (Restart App).
