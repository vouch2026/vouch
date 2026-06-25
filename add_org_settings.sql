-- Migration to add recommended organization settings to the organizations table.
-- Run this in your Supabase SQL Editor.

ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS strict_attendance_mode BOOLEAN DEFAULT false;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS allow_member_self_registration BOOLEAN DEFAULT true;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS require_zero_balance_for_clearance BOOLEAN DEFAULT true;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS max_unexcused_absences INTEGER DEFAULT 3;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS is_clearance_active BOOLEAN DEFAULT false;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS requires_faculty_dean_signature BOOLEAN DEFAULT false;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS allow_member_card_printing BOOLEAN DEFAULT true;
