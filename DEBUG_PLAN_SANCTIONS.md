# Sanction Module Debugging & Fix Plan

## Problem Description
Officers can correctly see and manage sanction records in their workspace, but members (students) are unable to see their own assigned sanctions in the "My Sanctions" page. This suggests the data exists in the database but is either being filtered out by the frontend provider or blocked by backend security (RLS).

## Potential Root Causes
1. **Scope Filtering:** The `mySanctionsProvider` filters sanctions by the `scope_id` of the *currently selected organization*. If a student has sanctions from a different scope (e.g., Institutional/Campus level) while they are in a Program-based workspace, they won't see them.
2. **User ID Mismatch:** `userProfile.id` (internal `users.id`) might not be correctly passed or might mismatch what's stored in `student_sanction_records.student_id`.
3. **RLS (Row Level Security):** The Supabase policy `Students can view their own sanctions` might be failing if `public.get_my_id()` returns a different ID than what is stored in the record.
4. **Provider Initialization:** `mySanctionsProvider` might be returning an empty list prematurely if `userProfileProvider` or `workspaceProvider` haven't fully initialized.

## Proposed Plan

### Phase 1: Diagnosis & Instrumentation
1. **Add Debug Logging:**
    * Add `debugPrint` in `mySanctionsProvider` to log `userProfile.id`, `scopeId`, and `term.id`.
    * Add logging in `SanctionRepository.getMySanctions` to see the actual row count returned from Supabase.
2. **Database Verification (via SQL or Script):**
    * Run a query to check the content of `student_sanction_records` for a test student.
    * Verify that `student_id` in the record matches the `id` in the `users` table for that student's `auth_id`.
3. **Policy Verification:**
    * Temporarily disable RLS or add a bypass to check if the data appears for the student.

### Phase 2: Implementation (The Fix)
1. **Broaden Member Query (Fixing Scope Issue):**
    * Modify `mySanctionsProvider` to fetch sanctions for ALL scopes the user belongs to, OR at least include the Institutional (Campus) scope by default.
    * Alternative: Update `getMySanctions` in `SanctionRepository` to accept an optional `scopeId` and fetch all for the user if null.
2. **Improve Provider Robustness:**
    * Update `mySanctionsProvider` to properly await `userProfileProvider.future` to ensure it doesn't return `[]` while loading.
3. **Fix Repository Query:**
    * Ensure `getMySanctions` includes the same join fields as `getWorkspaceSanctions` (like student names) to maintain model consistency.
    * Verify and fix the "retry" logic in `getMySanctions` to ensure it correctly resolves `auth_id` to `users.id` if needed.

### Phase 3: UI Enhancement
1. **Clearer "No Sanctions" State:**
    * If the user has sanctions in other workspaces but not the current one, show a hint or a button to "View all sanctions".

### Phase 4: Validation
1. **Manual Verification:** Log in as a student and verify sanctions appear across different workspaces.
2. **Automated Tests:** 
    * Add unit tests for `SanctionRepository.getMySanctions`.
    * Add widget tests for `MySanctionsPage` with mocked empty and non-empty states.
