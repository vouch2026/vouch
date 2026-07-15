-- Safe update script to ensure Senator has view_events permission
-- This script does not modify existing data or tables structure, and will not cause duplicate key issues.

-- 1. Ensure the 'view_events' permission exists in the database
INSERT INTO public.permissions (action)
VALUES ('view_events')
ON CONFLICT (action) DO NOTHING;

-- 2. Ensure the 'Senator' role is mapped to 'view_events' permission
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id 
FROM public.roles r, public.permissions p
WHERE r.name = 'Senator' AND p.action = 'view_events'
ON CONFLICT (role_id, permission_id) DO NOTHING;
