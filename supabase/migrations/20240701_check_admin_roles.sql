SELECT ur.user_id, ur.role_id, r.name as role_name FROM public.user_roles ur JOIN public.roles r ON r.id = ur.role_id WHERE ur.user_id = 'ab563ebf-1396-4b0f-a4b7-8d1dec846790';
