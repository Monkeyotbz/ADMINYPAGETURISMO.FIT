-- ================================================
-- SOLUCIÓN COMPLETA: Permitir registro de usuarios
-- ================================================
-- Ejecuta este script COMPLETO en Supabase SQL Editor

-- 1. DESHABILITAR TEMPORALMENTE RLS EN USERS
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- 2. ELIMINAR TODAS LAS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can create own profile" ON users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON users;
DROP POLICY IF EXISTS "Enable read access for users based on user_id" ON users;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON users;

-- 3. VOLVER A HABILITAR RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 4. CREAR POLÍTICAS CORRECTAS

-- Política para INSERTAR (crear perfil durante registro)
-- Permitir insertar SI el ID coincide con el usuario autenticado
-- O si el registro es parte del proceso de signup
CREATE POLICY "Enable insert for authenticated users only" ON users
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

-- Política para LEER (ver perfil)
-- Los usuarios solo pueden ver su propio perfil
CREATE POLICY "Enable read access for users based on user_id" ON users
  FOR SELECT 
  TO authenticated
  USING (auth.uid() = id);

-- Política para ACTUALIZAR (editar perfil)
-- Los usuarios solo pueden actualizar su propio perfil
CREATE POLICY "Enable update for users based on user_id" ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 5. VERIFICAR QUE LAS POLÍTICAS ESTÁN ACTIVAS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'users'
ORDER BY policyname;

-- 6. VERIFICAR QUE RLS ESTÁ HABILITADO
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'users';
