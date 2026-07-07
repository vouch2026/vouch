-- Safe update script to grant sanction permissions to Faculty Dean and Program Head roles
-- This script does not drop any tables and will not affect existing data.

-- 1. Insert permissions if they do not already exist
INSERT INTO public.permissions (action) VALUES
('create_sanction_rules'),
('edit_sanction_rules'),
('delete_sanction_rules'),
('receive_sanction_items'),
('view_sanctions')
ON CONFLICT (action) DO NOTHING;

-- 2. Grant permissions to Faculty Dean
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id 
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.name = 'Faculty Dean' 
AND p.action IN (
    'create_sanction_rules', 
    'edit_sanction_rules', 
    'delete_sanction_rules', 
    'receive_sanction_items', 
    'view_sanctions'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- 3. Grant permissions to Program Head
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id 
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.name = 'Program Head' 
AND p.action IN (
    'create_sanction_rules', 
    'edit_sanction_rules', 
    'delete_sanction_rules', 
    'receive_sanction_items', 
    'view_sanctions'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- 4. Grant permission for Deans and Program Heads to sign their signature slots (RLS update policy)
DROP POLICY IF EXISTS "Deans and Program Heads can sign slots" ON public.activity_card_clearance_signatures;

CREATE POLICY "Deans and Program Heads can sign slots" ON public.activity_card_clearance_signatures FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = public.get_my_id() AND ur.role_id = required_role_id AND ur.scope_id = required_scope_id AND ur.is_active = true));

-- 5. Grant view_fees permission to Secretary and Assistant Secretary
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id 
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.name IN ('Secretary', 'Assistant Secretary') 
AND p.action = 'view_fees'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- 6. Grant SELECT permission for Deans, Program Heads, and Officers to view all clearance requests and signatures (to resolve hierarchy/prerequisite checks during review)
DROP POLICY IF EXISTS "Officers can view all clearance requests" ON public.activity_card_clearance_requests;
CREATE POLICY "Officers can view all clearance requests" ON public.activity_card_clearance_requests FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.organization_members om WHERE om.user_id = public.get_my_id() AND om.role_id IS NOT NULL) OR EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = public.get_my_id() AND ur.is_active = true));

DROP POLICY IF EXISTS "Officers can view all clearance signatures" ON public.activity_card_clearance_signatures;
CREATE POLICY "Officers can view all clearance signatures" ON public.activity_card_clearance_signatures FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.organization_members om WHERE om.user_id = public.get_my_id() AND om.role_id IS NOT NULL) OR EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = public.get_my_id() AND ur.is_active = true));
