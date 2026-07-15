-- SQL Migration: Allow students to resubmit their own rejected clearance requests and signatures
-- This policy allows students to update their own rejected clearance requests back to 'Pending' and reset the status of rejected signature slots.

-- 1. Policy for updating the clearance request
CREATE POLICY "Students can update their own rejected clearance requests" 
ON public.activity_card_clearance_requests 
FOR UPDATE 
TO authenticated 
USING (student_id = public.get_my_id() AND status = 'Rejected')
WITH CHECK (student_id = public.get_my_id() AND status = 'Pending');

-- 2. Policy for updating the signature slots
CREATE POLICY "Students can update their own rejected signatures" 
ON public.activity_card_clearance_signatures 
FOR UPDATE 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM public.activity_card_clearance_requests r 
    WHERE r.id = clearance_request_id 
      AND r.student_id = public.get_my_id()
      AND (r.status = 'Rejected' OR r.status = 'Pending')
  )
)
WITH CHECK (
  status = 'Pending' 
  AND signed_by_user_id IS NULL 
  AND signed_at IS NULL 
  AND remarks IS NULL
);
