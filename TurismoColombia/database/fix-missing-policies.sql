-- ================================================
-- SCRIPT DE CORRECCIÓN - POLÍTICAS FALTANTES
-- ================================================
-- Ejecuta este código en el SQL Editor de Supabase
-- para arreglar las tablas "UNRESTRICTED"

-- ================================================
-- HABILITAR RLS EN TABLAS FALTANTES
-- ================================================

-- Habilitar RLS en property_availability
ALTER TABLE property_availability ENABLE ROW LEVEL SECURITY;

-- Habilitar RLS en tour_capacity
ALTER TABLE tour_capacity ENABLE ROW LEVEL SECURITY;

-- ================================================
-- POLÍTICAS PARA PROPERTY_AVAILABILITY
-- ================================================

-- Todos pueden ver disponibilidad (es información pública)
CREATE POLICY "Anyone can view property availability" ON property_availability
  FOR SELECT USING (true);

-- Solo sistema puede crear/actualizar disponibilidad (se hace automáticamente)
-- Los usuarios no deberían modificar esto directamente
CREATE POLICY "Service role can manage availability" ON property_availability
  FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- ================================================
-- POLÍTICAS PARA TOUR_CAPACITY
-- ================================================

-- Todos pueden ver cupos disponibles (es información pública)
CREATE POLICY "Anyone can view tour capacity" ON tour_capacity
  FOR SELECT USING (true);

-- Solo sistema puede crear/actualizar cupos
CREATE POLICY "Service role can manage capacity" ON tour_capacity
  FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- ================================================
-- VERIFICAR QUE TODAS LAS TABLAS TENGAN RLS
-- ================================================

-- Esta query te mostrará qué tablas tienen RLS habilitado
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'users', 
    'reservations', 
    'payments', 
    'invoices', 
    'refunds', 
    'property_availability', 
    'tour_capacity'
  )
ORDER BY tablename;

-- ================================================
-- RESULTADO ESPERADO:
-- ================================================
-- Todas las tablas deberían mostrar rls_enabled = true
-- Si alguna muestra false, ejecuta:
-- ALTER TABLE nombre_tabla ENABLE ROW LEVEL SECURITY;
