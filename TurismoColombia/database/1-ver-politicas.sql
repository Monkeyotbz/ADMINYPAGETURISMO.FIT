-- VER TODAS LAS POLÍTICAS ACTUALES
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'users'
ORDER BY cmd, policyname;
