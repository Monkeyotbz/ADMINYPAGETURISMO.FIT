-- ================================================
-- DIAGNÓSTICO RÁPIDO - Ejecuta TODO de una sola vez
-- ================================================

-- 📊 RESUMEN GENERAL
SELECT 
  (SELECT COUNT(*) FROM users) as total_usuarios,
  (SELECT COUNT(*) FROM users WHERE role = 'admin') as total_admins,
  (SELECT COUNT(*) FROM properties) as total_propiedades,
  (SELECT COUNT(*) FROM tours) as total_tours,
  (SELECT COUNT(*) FROM bookings) as total_reservaciones;

-- 👤 TU USUARIO
SELECT id, email, role
FROM users 
WHERE email = 'turismocolombiafit@gmail.com';

-- 🏠 PROPIEDADES POR CIUDAD
SELECT city, COUNT(*) as cantidad
FROM properties
GROUP BY city
ORDER BY cantidad DESC;

-- 🎯 TOURS POR CIUDAD  
SELECT city, COUNT(*) as cantidad
FROM tours
GROUP BY city
ORDER BY cantidad DESC;
