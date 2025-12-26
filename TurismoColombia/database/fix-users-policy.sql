-- ================================================
-- CORRECCIÓN: Permitir inserción de usuarios
-- ================================================
-- Ejecuta este script en Supabase SQL Editor

-- Eliminar políticas antiguas que pueden estar causando conflicto
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can create own profile" ON users;

-- Crear políticas corregidas
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can create own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Verificar que las políticas están activas
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'users';
