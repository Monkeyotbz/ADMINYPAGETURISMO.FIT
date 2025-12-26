-- ================================================
-- DIAGNÓSTICO COMPLETO DE SUPABASE
-- Ejecuta estas queries UNA POR UNA y copia los resultados
-- ================================================

-- ==========================================
-- 1. VERIFICAR COLUMNA ROLE EN USERS
-- ==========================================
SELECT column_name, data_type, column_default
FROM information_schema.columns 
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- ==========================================
-- 2. VERIFICAR TU ROL DE USUARIO
-- ==========================================
SELECT id, email, role 
FROM users 
WHERE email = 'turismocolombiafit@gmail.com';

-- ==========================================
-- 3. VERIFICAR TABLAS EXISTENTES
-- ==========================================
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ==========================================
-- 4. CONTAR PROPIEDADES
-- ==========================================
SELECT COUNT(*) as total_properties FROM properties;

-- ==========================================
-- 5. VER PROPIEDADES EXISTENTES
-- ==========================================
SELECT id, name, city, price_per_night, featured, active, created_at
FROM properties
ORDER BY city, name
LIMIT 20;

-- ==========================================
-- 6. CONTAR TOURS
-- ==========================================
SELECT COUNT(*) as total_tours FROM tours;

-- ==========================================
-- 7. VER TOURS EXISTENTES (si hay)
-- ==========================================
SELECT id, name, city, price, duration, difficulty, featured, active
FROM tours
ORDER BY city, name
LIMIT 20;

-- ==========================================
-- 8. VERIFICAR POLÍTICAS RLS
-- ==========================================
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ==========================================
-- 9. VERIFICAR IMÁGENES DE PROPIEDADES
-- ==========================================
SELECT COUNT(*) as total_property_images FROM property_images;

-- ==========================================
-- 10. VERIFICAR IMÁGENES DE TOURS
-- ==========================================
SELECT COUNT(*) as total_tour_images FROM tour_images;

-- ==========================================
-- RESUMEN FINAL
-- ==========================================
SELECT 
  (SELECT COUNT(*) FROM users) as total_usuarios,
  (SELECT COUNT(*) FROM users WHERE role = 'admin') as total_admins,
  (SELECT COUNT(*) FROM properties) as total_propiedades,
  (SELECT COUNT(*) FROM tours) as total_tours,
  (SELECT COUNT(*) FROM bookings) as total_reservaciones;
