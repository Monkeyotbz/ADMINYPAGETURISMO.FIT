-- ================================================
-- CONFIGURACIÓN DE STORAGE PARA IMÁGENES
-- ================================================

-- Este archivo debe ejecutarse en Supabase Dashboard > Storage
-- Instrucciones:
-- 1. Ve a Storage en el dashboard de Supabase
-- 2. Crea un nuevo bucket llamado "property-images"
-- 3. Configúralo como PÚBLICO
-- 4. Luego ejecuta las políticas de abajo en SQL Editor

-- ==========================================
-- POLÍTICAS DE STORAGE PARA property-images
-- ==========================================

-- Política: Cualquiera puede VER las imágenes (público)
CREATE POLICY "Anyone can view property images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'property-images');

-- Política: Solo admins pueden SUBIR imágenes
CREATE POLICY "Only admins can upload property images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'property-images' 
  AND auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
);

-- Política: Solo admins pueden ACTUALIZAR imágenes
CREATE POLICY "Only admins can update property images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'property-images'
  AND auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
);

-- Política: Solo admins pueden ELIMINAR imágenes
CREATE POLICY "Only admins can delete property images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'property-images'
  AND auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
);

-- ==========================================
-- VERIFICACIÓN
-- ==========================================
SELECT 'Políticas de storage creadas exitosamente!' as mensaje;
SELECT 'Recuerda crear el bucket "property-images" en Storage y marcarlo como PÚBLICO' as recordatorio;
