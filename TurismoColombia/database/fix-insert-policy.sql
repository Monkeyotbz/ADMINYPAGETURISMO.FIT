-- ================================================
-- FIX: Permitir INSERT durante el registro
-- ================================================

-- 1. Eliminar la política de INSERT actual
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON users;

-- 2. Crear nueva política que permita INSERT para usuarios autenticados Y durante signup
-- La clave es usar public en vez de authenticated para permitir el insert durante signup
CREATE POLICY "Enable insert for authenticated users only" ON users
  FOR INSERT 
  TO public
  WITH CHECK (auth.uid() = id);

-- 3. Verificar que quedó bien
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'users' AND cmd = 'INSERT';
