-- ================================================
-- DIAGNÓSTICO COMPLETO DE LA TABLA USERS
-- ================================================
-- Ejecuta este script para ver el estado actual

-- 1. VER TODAS LAS POLÍTICAS ACTUALES
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'users'
ORDER BY cmd, policyname;

-- 2. VERIFICAR RLS ESTÁ HABILITADO
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'users';

-- 3. VER ESTRUCTURA DE LA TABLA
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'users'
ORDER BY ordinal_position;

-- 4. VER PERMISOS DE LA TABLA
SELECT 
  grantee,
  privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'public' 
  AND table_name = 'users';

-- 5. CONTAR USUARIOS EXISTENTES
SELECT COUNT(*) as total_users FROM users;

-- 6. VER USUARIOS EN AUTH (si tienes acceso)
-- Esto puede fallar si no tienes permisos, es normal
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;
