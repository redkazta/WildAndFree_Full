SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('user_roles', 'roles', 'permissions', 'role_permissions');
