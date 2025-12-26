-- ================================================
-- ESQUEMA COMPLETO PARA PANEL DE ADMINISTRACIÓN
-- ================================================

-- ==========================================
-- 1. AGREGAR ROLES A USUARIOS
-- ==========================================

-- Agregar columna role a la tabla users (si no existe)
ALTER TABLE users ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin'));

-- Actualizar tu usuario a admin (CAMBIA EL EMAIL)
UPDATE users SET role = 'admin' WHERE email = 'TU_EMAIL_AQUI@example.com';

-- ==========================================
-- 2. TABLA DE PROPIEDADES
-- ==========================================

CREATE TABLE IF NOT EXISTS properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  location TEXT NOT NULL,
  city TEXT NOT NULL,
  price_per_night DECIMAL(10,2) NOT NULL,
  bedrooms INTEGER DEFAULT 1,
  bathrooms INTEGER DEFAULT 1,
  guests INTEGER DEFAULT 2,
  rating DECIMAL(3,2) DEFAULT 0,
  reviews_count INTEGER DEFAULT 0,
  amenities TEXT[], -- Array de amenidades
  property_type TEXT CHECK (property_type IN ('hotel', 'casa', 'apartamento', 'cabaña', 'hostal')),
  featured BOOLEAN DEFAULT false,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  created_by UUID REFERENCES users(id)
);

-- ==========================================
-- 3. TABLA DE IMÁGENES DE PROPIEDADES
-- ==========================================

CREATE TABLE IF NOT EXISTS property_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT NOT NULL,
  is_main BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==========================================
-- 4. TABLA DE TOURS
-- ==========================================

CREATE TABLE IF NOT EXISTS tours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  location TEXT NOT NULL,
  city TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  duration TEXT, -- Ej: "4 horas", "1 día"
  difficulty TEXT CHECK (difficulty IN ('fácil', 'moderado', 'difícil')),
  max_people INTEGER DEFAULT 10,
  rating DECIMAL(3,2) DEFAULT 0,
  reviews_count INTEGER DEFAULT 0,
  includes TEXT[], -- Array de lo que incluye
  featured BOOLEAN DEFAULT false,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  created_by UUID REFERENCES users(id)
);

-- ==========================================
-- 5. TABLA DE IMÁGENES DE TOURS
-- ==========================================

CREATE TABLE IF NOT EXISTS tour_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tour_id UUID REFERENCES tours(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT NOT NULL,
  is_main BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==========================================
-- 6. ÍNDICES PARA MEJOR RENDIMIENTO
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_properties_city ON properties(city);
CREATE INDEX IF NOT EXISTS idx_properties_featured ON properties(featured);
CREATE INDEX IF NOT EXISTS idx_properties_active ON properties(active);
CREATE INDEX IF NOT EXISTS idx_property_images_property_id ON property_images(property_id);
CREATE INDEX IF NOT EXISTS idx_tours_city ON tours(city);
CREATE INDEX IF NOT EXISTS idx_tours_featured ON tours(featured);
CREATE INDEX IF NOT EXISTS idx_tour_images_tour_id ON tour_images(tour_id);

-- ==========================================
-- 7. ROW LEVEL SECURITY (RLS)
-- ==========================================

-- Habilitar RLS
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE tours ENABLE ROW LEVEL SECURITY;
ALTER TABLE tour_images ENABLE ROW LEVEL SECURITY;

-- Políticas para PROPERTIES
-- Lectura: todos pueden ver propiedades activas
CREATE POLICY "Anyone can view active properties" ON properties
  FOR SELECT USING (active = true OR auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Insertar: solo admins
CREATE POLICY "Only admins can insert properties" ON properties
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Actualizar: solo admins
CREATE POLICY "Only admins can update properties" ON properties
  FOR UPDATE TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Eliminar: solo admins
CREATE POLICY "Only admins can delete properties" ON properties
  FOR DELETE TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Políticas para PROPERTY_IMAGES
CREATE POLICY "Anyone can view property images" ON property_images
  FOR SELECT USING (true);

CREATE POLICY "Only admins can manage property images" ON property_images
  FOR ALL TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Políticas para TOURS (similares a properties)
CREATE POLICY "Anyone can view active tours" ON tours
  FOR SELECT USING (active = true OR auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

CREATE POLICY "Only admins can insert tours" ON tours
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

CREATE POLICY "Only admins can update tours" ON tours
  FOR UPDATE TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

CREATE POLICY "Only admins can delete tours" ON tours
  FOR DELETE TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Políticas para TOUR_IMAGES
CREATE POLICY "Anyone can view tour images" ON tour_images
  FOR SELECT USING (true);

CREATE POLICY "Only admins can manage tour images" ON tour_images
  FOR ALL TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- ==========================================
-- 8. FUNCIÓN PARA ACTUALIZAR updated_at
-- ==========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at
DROP TRIGGER IF EXISTS update_properties_updated_at ON properties;
CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON properties
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_tours_updated_at ON tours;
CREATE TRIGGER update_tours_updated_at BEFORE UPDATE ON tours
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- 9. TABLA DE RESERVACIONES
-- ==========================================

CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) NOT NULL,
  property_id UUID REFERENCES properties(id),
  tour_id UUID REFERENCES tours(id),
  booking_type TEXT CHECK (booking_type IN ('property', 'tour')) NOT NULL,
  check_in DATE NOT NULL,
  check_out DATE,
  guests INTEGER NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  status TEXT CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
  payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'refunded')) DEFAULT 'pending',
  special_requests TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Índices para bookings
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_tour_id ON bookings(tour_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_check_in ON bookings(check_in);

-- RLS para bookings
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Los usuarios pueden ver sus propias reservas
CREATE POLICY "Users can view own bookings" ON bookings
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Los usuarios pueden crear sus propias reservas
CREATE POLICY "Users can create own bookings" ON bookings
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Solo admins pueden actualizar reservas
CREATE POLICY "Only admins can update bookings" ON bookings
  FOR UPDATE TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Solo admins pueden eliminar reservas
CREATE POLICY "Only admins can delete bookings" ON bookings
  FOR DELETE TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Trigger para actualizar updated_at en bookings
DROP TRIGGER IF EXISTS update_bookings_updated_at ON bookings;
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- 10. DATOS DE PRUEBA (OPCIONAL)
-- ==========================================

-- Insertar todas las propiedades reales del sitio web (ejecutar DESPUÉS de configurar tu usuario como admin)
INSERT INTO properties (name, description, location, city, price_per_night, bedrooms, bathrooms, guests, property_type, featured, amenities) VALUES
('Cabaña Las Águilas', 'Cabaña rodeada de naturaleza en destino rural. Diseñada para amantes de la naturaleza con jardín, balcón, WiFi gratis y cocina compartida. Incluye traslados al aeropuerto, alquiler de caballos, vistas a montañas, cascadas, ríos y cuevas. Una experiencia única e inolvidable.', 'Jardín, Antioquia', 'Jardín', 180000, 2, 1, 4, 'cabaña', true, ARRAY['Naturaleza', 'Alquiler caballos', 'WiFi gratis', 'Traslado aeropuerto', 'Vistas panorámicas', 'Cocina compartida']),

('Hotel Opera Medellín Centro Only Adults', 'Hotel solo para adultos en la zona rosa del centro de Medellín. Habitaciones confortables, bar exclusivo hasta la 1:00 A.M, wifi y lavandería. Ubicado cerca del Edificio Coltejer, La Plazoleta de Botero y la estación Parque Berrío.', 'Centro, Medellín', 'Medellín', 280000, 1, 1, 2, 'hotel', true, ARRAY['Solo adultos', 'Bar hasta 1:00 A.M', 'WiFi gratis', 'Lavandería', 'Traslado aeropuerto', 'Cerca Parque Berrío']),

('Hotel Medellín Opera Habitación con Jacuzzi', 'Quédate en este espectacular hotel en el centro de la ciudad. Habitación con jacuzzi turco, uno de los pocos lugares en la zona con este servicio. Ideal para parejas que buscan relajarse en un ambiente íntimo y confortable. WiFi, TV, aire acondicionado y servicio de equipaje.', 'Centro, Medellín', 'Medellín', 320000, 1, 1, 2, 'hotel', true, ARRAY['Jacuzzi turco', 'WiFi gratis', 'TV', 'Aire acondicionado', 'Centro', 'Romántico', 'Solo adultos']),

('Hotel Opera Medellín Habitación Semi Suite', 'Quédate en este lugar único ubicado en pleno centro y no te pierdas los lugares históricos que puedes visitar con nosotros. En Pleno Corazón de Medellín, habitación con jacuzzi, bas discoteca, puede haber ruido, solo para adultos, zona rosa de el centro de Medellín. Relájate en el jacuzzi.', 'Centro, Medellín', 'Medellín', 300000, 1, 1, 2, 'hotel', true, ARRAY['Jacuzzi', 'WiFi gratis', 'TV', 'Centro', 'Solo adultos', 'Zona rosa', 'Cámaras seguridad']),

('Hotel Medellín Opera Habitación Doble Clásica', 'Quédate en este lugar único ubicado en pleno centro y no te pierdas nada. Habitación cómoda y acogedora en el corazón de Medellín, perfecta para parejas o viajeros que buscan una estancia económica en la zona rosa del centro.', 'Centro, Medellín', 'Medellín', 250000, 1, 1, 2, 'hotel', false, ARRAY['WiFi gratis', 'TV', 'Centro', 'Económico', 'Zona rosa', 'Solo adultos']),

('Penthouse Panorama Medellín', 'Penthouse panorámico en El Poblado con terraza y vistas 360° a la ciudad. Ideal para viajes de lujo o estancias largas; incluye zonas sociales amplias, cocina equipada y múltiples ambientes para trabajar o descansar.', 'El Poblado, Medellín', 'Medellín', 520000, 3, 2, 6, 'apartamento', true, ARRAY['Vistas 360°', 'Terraza', 'WiFi gratis', 'Cocina equipada', 'A/C', 'Espacios amplios']),

('Hospedaje Rural Jericó', 'Cabaña rural con wifi gratis y cocina compartida, perfecta para vivir Jericó: pueblo de balcones coloridos, cafés de origen y atardeceres frente al Cauca. Incluye traslados al aeropuerto, alquiler de bicicletas, vistas hermosas y desayuno americano diario. Habitaciones con cafetera, TV de pantalla plana y baño privado; a pocas cuadras de la iglesia principal y el mirador.', 'Jericó, Antioquia', 'Jericó', 190000, 2, 1, 4, 'cabaña', true, ARRAY['Wifi gratis', 'Cocina compartida', 'Desayuno americano', 'Traslado aeropuerto', 'Alquiler de bicicletas', 'Vistas hermosas']),

('Hospedaje Delux Cartagena', 'Ofrece vistas al lago y piscina al aire libre y está en el barrio de Laguito, en Cartagena de Indias, a 4 min a pie de Playa El Laguito y a 5.2 km de Palacio de la Inquisición. Hay wifi gratis en todo el alojamiento y parking privado. Todas las unidades tienen aire acondicionado y disponen de baño privado, TV de pantalla plana, cocina totalmente equipada y balcón.', 'El Laguito, Cartagena de Indias', 'Cartagena', 150000, 1, 1, 3, 'apartamento', false, ARRAY['Piscina al aire libre', 'WiFi gratis', 'Parking privado', 'Aire acondicionado', 'TV plasma', 'Cocina equipada', 'Balcón privado', 'Traslado aeropuerto']),

('Hospedajes Penthouse Cartagena El Laguito', 'Está en el barrio de Laguito, en Cartagena de Indias, a 1 min a pie de Playa El Laguito y a 4.9 km de Palacio de la Inquisición, y ofrece alojamiento equipado con balcón y wifi gratis. Este apartamento está a 4.3 km de Museo del Oro de Cartagena. Este apartamento con aire acondicionado se compone de 1 dormitorio independiente, una cocina totalmente equipada y 1 baño.', 'El Laguito, Cartagena de Indias', 'Cartagena', 250000, 1, 1, 4, 'apartamento', true, ARRAY['180 m² tamaño', 'Piscina', 'Baño privado', 'Balcón', 'Vistas panorámicas', 'WiFi gratis', 'Aire acondicionado', 'Cocina equipada']),

('Hospedaje Cartagena Turismocolombia', 'Se encuentra en Cartagena de Indias y ofrece alojamiento con piscina al aire libre y wifi gratis a 1 min a pie de Playa El Laguito y a 4.9 km de Palacio de la Inquisición. Algunas unidades tienen aire acondicionado e incluyen balcón y/o zona de estar con TV de pantalla plana. El apartamento ofrece servicio de alquiler de coches.', 'El Laguito, Cartagena de Indias', 'Cartagena', 120000, 1, 1, 3, 'apartamento', false, ARRAY['Piscina al aire libre', 'WiFi gratis', 'Aire acondicionado', 'Baño privado', 'Balcón', 'TV pantalla plana', 'Traslado aeropuerto', 'Alquiler coches']),

('Hospedajes Cartagena Tours El Laguito', 'Se encuentra en Cartagena de Indias y ofrece alojamiento con wifi gratis y TV, además de la posibilidad de alojarse en la azotea. Cada unidad está equipada con aire acondicionado, baño privado y cocina con nevera y fogones. El apartamento ofrece servicio de alquiler de coches.', 'El Laguito, Cartagena de Indias', 'Cartagena', 140000, 1, 1, 3, 'apartamento', false, ARRAY['Apartamentos', 'Piscina al aire libre', 'Baño privado', 'Balcón', 'Vistas', 'WiFi gratis', 'Aire acondicionado', 'Habitaciones familiares']),

('Hoteles Cartagena Bocagrande', 'Está a pocos pasos de Playa de Bocagrande y ofrece alojamiento con piscina al aire libre, spa y recepción 24 horas. Hay wifi gratis en todo el alojamiento y parking privado en el establecimiento. El apartamento ofrece servicio de alquiler de coches.', 'Bocagrande, Cartagena de Indias', 'Cartagena', 165000, 1, 1, 3, 'apartamento', false, ARRAY['Apartamentos', 'Piscina al aire libre', 'Parking privado', 'Baño privado', 'Balcón', 'WiFi gratis', 'Aire acondicionado', 'Recepción 24h']),

('Alojamiento Rural San Jerónimo', 'Villa completa en San Jerónimo, Colombia. Lugar único ubicado en pleno centro y no te pierdas nada. Más de 16 huéspedes, 8 habitaciones, 12 camas, 8 baños. Sumérgete en una de las pocas albercas de la zona. Disfruta las vistas a la montaña y al jardín. Una habitación con wifi apta para trabajar.', 'San Jerónimo, Antioquia', 'San Jerónimo', 350000, 8, 8, 16, 'casa', true, ARRAY['Montaña', 'Piscina', 'Familiar', 'Grupos Grandes', 'WiFi gratis', 'Rural', 'Vistas panorámicas', '8 habitaciones']),

('Turismo Rural, Rancho California', 'Cabaña entera en Timaná, Colombia. Crea recuerdos inolvidables en este alojamiento único y familiar. 12 huéspedes, 4 habitaciones, 4 camas, 2 baños. Sumérgete en una de las pocas albercas de la zona con diseño único. Ideal para familias y grupos que buscan desconectar en un ambiente rural tranquilo.', 'Timaná, Huila', 'Pitalito', 280000, 4, 2, 12, 'cabaña', false, ARRAY['Rural', 'Piscina', 'Familiar', 'Grupos Grandes', 'Naturaleza', 'Tranquilidad', '4 habitaciones']);

-- ==========================================
-- VERIFICACIÓN FINAL
-- ==========================================

SELECT 'Schema created successfully!' as status;
