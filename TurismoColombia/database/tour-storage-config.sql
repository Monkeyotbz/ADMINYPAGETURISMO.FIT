-- Crear bucket para imágenes de tours
INSERT INTO storage.buckets (id, name, public)
VALUES ('tour-images', 'tour-images', true)
ON CONFLICT (id) DO NOTHING;

-- Políticas de Storage para tour-images
-- 1. Permitir SELECT público (cualquiera puede ver las imágenes)
CREATE POLICY "Public Access to tour images"
ON storage.objects FOR SELECT
USING (bucket_id = 'tour-images');

-- 2. Permitir INSERT solo a admins
CREATE POLICY "Admin can upload tour images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'tour-images' 
  AND auth.jwt() ->> 'role' = 'admin'
);

-- 3. Permitir UPDATE solo a admins
CREATE POLICY "Admin can update tour images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'tour-images' 
  AND auth.jwt() ->> 'role' = 'admin'
)
WITH CHECK (
  bucket_id = 'tour-images' 
  AND auth.jwt() ->> 'role' = 'admin'
);

-- 4. Permitir DELETE solo a admins
CREATE POLICY "Admin can delete tour images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'tour-images' 
  AND auth.jwt() ->> 'role' = 'admin'
);
