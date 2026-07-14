-- Safe update script to ensure Auditor has view_events and view_fees permissions
-- This script does not modify existing data or tables structure, and will not cause duplicate key issues.

-- 1. Ensure the permissions exist in the database
INSERT INTO public.permissions (action)
VALUES ('view_events'), ('view_fees')
ON CONFLICT (action) DO NOTHING;

-- 2. Ensure the 'Auditor' role is mapped to 'view_events' and 'view_fees' permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id 
FROM public.roles r, public.permissions p
WHERE r.name = 'Auditor' AND p.action IN ('view_events', 'view_fees')
ON CONFLICT (role_id, permission_id) DO NOTHING;
