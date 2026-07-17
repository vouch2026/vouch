-- Create account deletion requests table
CREATE TABLE IF NOT EXISTS public.account_deletion_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    student_id_number VARCHAR(50) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    acknowledged_clearance BOOLEAN NOT NULL DEFAULT FALSE,
    acknowledged_data_loss BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to update updated_at automatically
CREATE OR REPLACE TRIGGER update_account_deletion_requests_updated_at 
BEFORE UPDATE ON public.account_deletion_requests 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE public.account_deletion_requests ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- RLS Policies
-- ------------------------------------------------------------

-- Allow users to insert their own requests
CREATE POLICY "Users can create their own deletion request" 
ON public.account_deletion_requests 
FOR INSERT TO authenticated 
WITH CHECK (user_id = public.get_my_id());

-- Allow users to view their own requests
CREATE POLICY "Users can view their own deletion requests" 
ON public.account_deletion_requests 
FOR SELECT TO authenticated 
USING (user_id = public.get_my_id());

-- Allow Super Admins to manage all deletion requests
CREATE POLICY "Super admins can manage all deletion requests" 
ON public.account_deletion_requests 
FOR ALL TO authenticated 
USING (public.is_super_admin());
