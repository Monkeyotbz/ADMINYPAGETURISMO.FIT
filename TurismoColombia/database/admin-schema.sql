-- ================================================
-- ESQUEMA COMPLETO PARA PANEL DE ADMINISTRACIÓN
-- ================================================

-- ==========================================
-- 1. AGREGAR ROLES A USUARIOS
-- ==========================================

-- Agregar columna role a la tabla users (si no existe)
ALTER TABLE users ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin'));

-- Actualizar tu usuario a admin
UPDATE users SET role = 'admin' WHERE email = 'turismocolombiafit@gmail.com';

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

-- Eliminar políticas existentes antes de crearlas
DROP POLICY IF EXISTS "Anyone can view active properties" ON properties;
DROP POLICY IF EXISTS "Only admins can insert properties" ON properties;
DROP POLICY IF EXISTS "Only admins can update properties" ON properties;
DROP POLICY IF EXISTS "Only admins can delete properties" ON properties;

DROP POLICY IF EXISTS "Anyone can view property images" ON property_images;
DROP POLICY IF EXISTS "Only admins can manage property images" ON property_images;

DROP POLICY IF EXISTS "Anyone can view active tours" ON tours;
DROP POLICY IF EXISTS "Only admins can insert tours" ON tours;
DROP POLICY IF EXISTS "Only admins can update tours" ON tours;
DROP POLICY IF EXISTS "Only admins can delete tours" ON tours;

DROP POLICY IF EXISTS "Anyone can view tour images" ON tour_images;
DROP POLICY IF EXISTS "Only admins can manage tour images" ON tour_images;

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

-- Eliminar políticas existentes de bookings
DROP POLICY IF EXISTS "Users can view own bookings" ON bookings;
DROP POLICY IF EXISTS "Users can create own bookings" ON bookings;
DROP POLICY IF EXISTS "Only admins can update bookings" ON bookings;
DROP POLICY IF EXISTS "Only admins can delete bookings" ON bookings;

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

-- Eliminar propiedades existentes (solo si quieres empezar de cero)
-- DESCOMENTA LA SIGUIENTE LÍNEA SI QUIERES BORRAR TODO Y EMPEZAR DE NUEVO
-- DELETE FROM properties;

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

-- Insertar todos los tours reales del sitio web
INSERT INTO tours (name, description, location, city, price, duration, difficulty, max_people, featured, includes) VALUES
-- Tours de Cartagena
('ISLA CHOLON', 'Full piscina oceanica. Transporte en lancha (ida y regreso). Almuerzo típico. Entradas', 'Cartagena, Bolívar', 'Cartagena', 80000, '8 horas', 'fácil', 30, true, ARRAY['Lancha', 'Almuerzo', 'Piscina oceánica']),
('PLAYA BLANCA', 'Combustible embarcación. Almuerzo típico. Hidratación. Taxituristico', 'Cartagena, Bolívar', 'Cartagena', 70000, '7.5 horas', 'fácil', 30, true, ARRAY['Playa', 'Almuerzo', 'Hidratación']),
('BARU + ISLAS DEL ROSARIO', 'Transporte en lancha (Ida y regreso). San Martin de pajarales. Cholon o visita al acuario. Observar un San Martin de pajarales. Almuerzo típico. Aragua. Jacuzzi de mar (uso del muelle 15$)', 'Cartagena, Bolívar', 'Cartagena', 120000, '8 horas', 'fácil', 25, true, ARRAY['Lancha', 'Almuerzo', 'Snorkel', 'Acuario']),
('ISLA TIERRA BOMBA (Frente a la ciudad)', 'Almuerzo en la Isla en caseta. Grillas y camas', 'Cartagena, Bolívar', 'Cartagena', 60000, '8 horas', 'fácil', 30, false, ARRAY['Isla', 'Almuerzo', 'Grillas', 'Camas']),
('PALMARITO BEACH (Isla Tierra Bomba)', 'Comida de bienvenida. Nuevo club de playa, pistas, actividad hamacas, columpio, pistas, ganas de billar y mesa picina. Y piscina. Almuerzo típico (variedad de opciones)', 'Cartagena, Bolívar', 'Cartagena', 90000, '7.5 horas', 'fácil', 40, true, ARRAY['Beach club', 'Piscina', 'Almuerzo', 'Actividades']),
('PLAYA BLANCA + PLANCTON', 'Transporte en lancha (Ida). Tour de playa blanca a San Isla del Rosario barcode del poplancio. Cena típica lancha playa, transporte lancha/salida bus-mar. Almuerzo típico', 'Cartagena, Bolívar', 'Cartagena', 150000, '12.5 horas', 'moderado', 20, true, ARRAY['Playa', 'Plancton', 'Almuerzo', 'Lancha']),
('PLAYA TRANQUILA', 'Transporte en marítimo Ida y regreso. Combustible embarcación. Almuerzo típico (lancha Barco pesca, pescado frito, patacones, ensalada, Arroz coco). Guia de avancement', 'Cartagena, Bolívar', 'Cartagena', 75000, '7.5 horas', 'fácil', 25, false, ARRAY['Playa', 'Almuerzo', 'Tranquilidad', 'Lancha']),
('PLAYA BLANCA + AVIARIO', 'Trasborto en lancha. Visita al aviario y un acuario al centro de playa. Cena de salida de centro y comida del centro. Almuerzo típico; y playa tranquila', 'Cartagena, Bolívar', 'Cartagena', 95000, '7.5 horas', 'fácil', 30, false, ARRAY['Playa', 'Aviario', 'Almuerzo', 'Lancha']),
('TOUR 4 ISLAS', 'Pasaporte en lancha rápida: Visita Playa Blanca. La tour del área 4-playa primero el dorado, desde aqu en la mochila turista. Isla playa, a choio. Almuerzo típico', 'Cartagena, Bolívar', 'Cartagena', 110000, '8 horas', 'fácil', 25, true, ARRAY['4 islas', 'Lancha rápida', 'Almuerzo', 'Playa']),
('ISLA BELA', 'Transporte marítimo ida (lancha). Durante bienvenida cocoa. Comida Bandera/día, picina. Grilla desconcertante carril, cerca y parada fraca. Wifi. Actividades acertí ócico', 'Cartagena, Bolívar', 'Cartagena', 85000, '7.5 horas', 'fácil', 30, false, ARRAY['Isla', 'Almuerzo', 'Piscina', 'WiFi']),
('ISLA DEL SOL', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo típico. Sillas acostadoras camas, sones y paddle board. Actividades con guía opcional del tour', 'Cartagena, Bolívar', 'Cartagena', 90000, '7.5 horas', 'fácil', 35, true, ARRAY['Isla', 'Almuerzo', 'Paddle board', 'Actividades']),
('ISLA DEL ENCANTO', 'Transporte marítimo ida y regreso. Puedes llevar casa de las vacaciones sociales, piscina y playa. Almuerzo tipo buffet. Actividades con guía opcional del tour', 'Cartagena, Bolívar', 'Cartagena', 100000, '7.5 horas', 'fácil', 30, true, ARRAY['Isla', 'Piscina', 'Playa', 'Buffet']),
('CITY TOURS CHIVA', 'Transporte. Guía profesional. Bebidas alcohólicas y San Felipe. Recorrido por Getsemaní, las tiendas, las Bóvedas, torres del reloj. Fuerte (plataformas Marbella), Monumento a los Zapatos viejos, candelaria por el centro histórico', 'Cartagena, Bolívar', 'Cartagena', 65000, '3.5 horas', 'fácil', 40, true, ARRAY['City tour', 'Chiva', 'Centro histórico', 'Bebidas']),
('TOUR 5 ISLAS - VIP DEPORTIVO', 'Navegación en bote deportivo de lujo, capacidad máxima 12 pax. Cholon o isla grande o playa blanca. Recorrido panorámico por las islas de Rosario. Refrigerio almuerzo completo solo champagne', 'Cartagena, Bolívar', 'Cartagena', 350000, '8 horas', 'fácil', 12, true, ARRAY['VIP', 'Bote deportivo', '5 islas', 'Lujo']),
('BORA BORA BECH CLUB', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo típico. Sillas acostadoras, piscina, bar, carpas acondicionadas, piscina y secciones acuáticas de la isla', 'Cartagena, Bolívar', 'Cartagena', 95000, '7.5 horas', 'fácil', 35, true, ARRAY['Beach club', 'Piscina', 'Almuerzo', 'Bar']),
('BORA BORA V.I.P', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo con opciones de paella valenciana, cordial típico, sancocho, almuerzo de pollo o pescado y cerdo asado', 'Cartagena, Bolívar', 'Cartagena', 130000, '7.5 horas', 'fácil', 25, true, ARRAY['VIP', 'Paella', 'Piscina', 'Almuerzo']),
('PAO PAO BEACH CLUB', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo con opciones de paella, pasta o la boloñesa, típico sancocho o pollo. Sillas acostadoras, piscina, hamacas, billar, mesas de ping', 'Cartagena, Bolívar', 'Cartagena', 100000, '7.5 horas', 'fácil', 30, false, ARRAY['Beach club', 'Paella', 'Piscina', 'Billar']),
('LUXURY OPEN BAR', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Barra abierta en bebidas sin bahiston. Almuerzo tipo buffet. Sillas acostadoras, piscina, bar, camastros, carpas acondicionadas', 'Cartagena, Bolívar', 'Cartagena', 140000, '7.5 horas', 'fácil', 30, true, ARRAY['Luxury', 'Open bar', 'Buffet', 'Piscina']),
('LUXURY CLASSIC', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo tipo buffet. Sillas acostadoras, piscina, bar, camastros, carpas acondicionadas piscinas todas piscina, hamacas', 'Cartagena, Bolívar', 'Cartagena', 120000, '7.5 horas', 'fácil', 30, false, ARRAY['Luxury', 'Buffet', 'Piscina', 'Bar']),
('SIBARITA MASTER CENA', 'Cena o & Espíritu 5 platos de servido, 3 platos fuertes, 3 apetitivo y marida con vino por persona. Espectáculo de música en vivo, marisco y producto del mar, con sazón exclusivos', 'Cartagena, Bolívar', 'Cartagena', 180000, '2.5 horas', 'fácil', 20, true, ARRAY['Cena gourmet', '5 tiempos', 'Vino', 'Música en vivo']),
('BAHÍA RUMBERA (en bote deportivo)', 'Transporte en bote deportivo. Barra libre de ron con gaseosas. Pasabocas, dj marineros y agua. Galeón pirata. Recorrido por la bahía de la isla de Manga, isla, la Castillo Grande. Cumbias, Salsa y Pachanga', 'Cartagena, Bolívar', 'Cartagena', 110000, '4 horas', 'fácil', 14, true, ARRAY['Bote deportivo', 'Fiesta', 'Ron', 'DJ', 'Bahía']),

-- Tours de Medellín
('Graffiti tour + Comuna 13', 'Recorrido guiado por la Comuna 13 con escaleras eléctricas, arte urbano y historias locales.', 'Medellín, Antioquia', 'Medellín', 80000, '3 horas', 'fácil', 15, true, ARRAY['Guia local', 'Transporte', 'Fotografia']),
('Tour por la Ciudad de Medellín', 'Conoce la Ciudad de la Eterna Primavera con nuestro tour completo! Incluye transporte, entradas, guía experto, póliza de asistencia e hidratación. Visitarás el Pueblito Paisa, Milla de Oro, Graffiti Tour en la Comuna Trece, La 70 y el Parque Botero.', 'Medellín, Antioquia', 'Medellín', 90000, '4 horas', 'fácil', 20, true, ARRAY['City tour', 'Pueblito Paisa', 'Comuna 13', 'Parque Botero']),
('Tour por el Centro Histórico y Plaza Botero', 'Este tour te llevará a explorar el centro histórico de Medellín, donde podrás admirar la arquitectura colonial, visitar la famosa Plaza Botero y maravillarte con las esculturas del reconocido artista Fernando Botero.', 'Medellín, Antioquia', 'Medellín', 70000, '3 horas', 'fácil', 20, false, ARRAY['Centro histórico', 'Plaza Botero', 'Arte', 'Cultura']),
('Excursión al Parque Arví', 'Escápate del bullicio de la ciudad y sumérgete en la naturaleza en el Parque Arví. Este tour te llevará en un viaje en teleférico hasta este hermoso parque natural, donde podrás disfrutar de senderos para caminatas, actividades al aire libre y vistas panorámicas.', 'Medellín, Antioquia', 'Medellín', 85000, '5 horas', 'moderado', 15, true, ARRAY['Naturaleza', 'Teleférico', 'Senderismo', 'Parque']),
('Tour Gastronómico por Medellín', 'Embárcate en un viaje culinario por los sabores de Medellín. Prueba platos tradicionales como la bandeja paisa, la arepa de chócolo y la lechona, así como delicias modernas en restaurantes y mercados locales.', 'Medellín, Antioquia', 'Medellín', 95000, '4 horas', 'fácil', 12, true, ARRAY['Gastronomía', 'Bandeja paisa', 'Comida local', 'Mercados']),
('Tour Histórico de Pablo Escobar', 'Este tour ofrece una mirada objetiva y educativa sobre el pasado de Medellín relacionado con Pablo Escobar y el narcotráfico. Guiado por expertos locales que conocen profundamente la historia de la ciudad.', 'Medellín, Antioquia', 'Medellín', 100000, '4 horas', 'fácil', 15, false, ARRAY['Historia', 'Pablo Escobar', 'Educativo', 'Cultural']),
('Parque Explora', 'El Parque Explora es un centro interactivo de ciencia y tecnología que ofrece una experiencia educativa y divertida para visitantes de todas las edades. El Jardín Botánico es un oasis urbano de paz y naturaleza.', 'Medellín, Antioquia', 'Medellín', 75000, '4 horas', 'fácil', 20, true, ARRAY['Ciencia', 'Tecnología', 'Jardín Botánico', 'Educativo']),
('Tour por la Hacienda Nápoles', 'Vive un día en familia lleno de diversión en el Parque Temático Hacienda Nápoles desde Medellín en Doradal, municipio de Puerto Triunfo, Antioquia. Disfrutarás de imponentes atracciones acuáticas, fauna salvaje y mucha diversión.', 'Doradal, Antioquia', 'Medellín', 150000, '9 horas', 'fácil', 25, true, ARRAY['Parque temático', 'Safari', 'Familia', 'Acuático', 'Aventura']),
('Tour por Guatapé, Antioquia', 'Conoce la maravillosa piedra el Peñol, alto del chocho con granja y con su variedad de platos de nuestra gastronomía, el pueblo de Guatapé y su hermosa arquitectura patrimonial de mucho color y cultura.', 'Guatapé, Antioquia', 'Medellín', 130000, '8 horas', 'fácil', 20, true, ARRAY['Peñol', 'Pueblo', 'Lancha', 'Cultura', 'Gastronomía']),

-- Tours de Jardín
('Travesía Filo de Oro | Caminata', 'Visita a la garucha, tunel con salida a cascada escondida, entrada al tunel, charco corazón, cascada del amor, camino de herradura la herrera, casa de los dulces, hidratación, almuerzo tipo fiambre.', 'Jardín, Antioquia', 'Jardín', 70000, '4 horas', 'moderado', 15, true, ARRAY['Caminata', 'Cascada', 'Tunel', 'Naturaleza']),
('Travesía Filo de Oro | Transporte', 'Visita a la garucha, tunel con salida a cascada escondida, entrada al tunel, charco corazón, cascada del amor, camino de herradura la herrera, casa de los dulces, hidratación, almuerzo tipo fiambre, transporte ida y regreso.', 'Jardín, Antioquia', 'Jardín', 85000, '3 horas', 'fácil', 15, true, ARRAY['Transporte', 'Cascada', 'Tunel', 'Almuerzo']),
('Travesía Filo de Oro | Cabalgata', 'Visita a la garucha, tunel con salida a cascada escondida, entrada al tunel, charco corazón, cascada del amor, camino de herradura la herrera, casa de los dulces, hidratación, almuerzo tipo fiambre, caballo y guía.', 'Jardín, Antioquia', 'Jardín', 95000, '3 horas', 'moderado', 12, true, ARRAY['Cabalgata', 'Cascada', 'Tunel', 'Caballos']),
('Travesía Finca Cafetera | Transporte', 'Charla sobre el café, recorrido finca cafetera, recolección, despulpado, secado del café, Tostión, hidratación, degustación del café, almuerzo tipo fiambre, transporte ida y regreso.', 'Jardín, Antioquia', 'Jardín', 80000, '3 horas', 'fácil', 15, true, ARRAY['Café', 'Finca', 'Degustación', 'Transporte']),
('Travesía Finca Cafetera | Cabalgata', 'Charla sobre el café, recorrido finca cafetera, recolección, despulpado, secado del café, Tostión, hidratación, degustación del café, almuerzo tipo fiambre, caballo y guía.', 'Jardín, Antioquia', 'Jardín', 90000, '3 horas', 'moderado', 12, true, ARRAY['Café', 'Finca', 'Cabalgata', 'Degustación']),
('Travesía Salto del Ángel', 'Transporte ida y regreso, almuerzo tipo fiambre, visita cascada Salto del Ángel, camino del diablo, santuario de los guacharos, hidratación.', 'Jardín, Antioquia', 'Jardín', 100000, '7 horas', 'difícil', 12, true, ARRAY['Cascada', 'Aventura', 'Santuario', 'Transporte']),
('Travesía Cristo Rey | Caminata', 'Visita cascada la escalera, mirador cristo rey, truchera, trapiche, almuerzo tipo fiambre, hidratación.', 'Jardín, Antioquia', 'Jardín', 65000, '4 horas', 'moderado', 15, false, ARRAY['Caminata', 'Mirador', 'Cascada', 'Truchera']),
('Travesía Cristo Rey | Transporte', 'Transporte ida y regreso, visita cascada la escalera, mirador cristo rey, truchera, trapiche, almuerzo tipo fiambre, hidratación.', 'Jardín, Antioquia', 'Jardín', 75000, '3 horas', 'fácil', 15, false, ARRAY['Transporte', 'Mirador', 'Cascada', 'Cristo Rey']),
('Travesía Cristo Rey | Cabalgata', 'Visita cascada la escalera, mirador cristo rey, truchera, trapiche, almuerzo tipo fiambre, hidratación, caballo y guía.', 'Jardín, Antioquia', 'Jardín', 85000, '4 horas', 'moderado', 12, false, ARRAY['Cabalgata', 'Mirador', 'Cascada', 'Caballos']),
('Travesía del Amor', 'Decoración aniversario o cumpleaños, bombas, velas, chocolates y cena. Puedes optar por: vino, ron 8 años o whisky.', 'Jardín, Antioquia', 'Jardín', 120000, '3 horas', 'fácil', 2, true, ARRAY['Romántico', 'Aniversario', 'Cena', 'Decoración']),
('Travesía Resguardo Indígena', 'Transporte ida y regreso, guía logístico y operador, entrada, visita a la ramada (trapiche) tiendas de artesanías, visita resguardo karmata rua, almuerzo tipo fiambre.', 'Jardín, Antioquia', 'Jardín', 90000, '4 horas', 'fácil', 15, true, ARRAY['Cultural', 'Indígena', 'Artesanías', 'Transporte']),
('Travesía Gallito de Roca', 'Guía, entradas, hidratación. Hora de avistamiento 5:30 a.m y 4:30 p.m', 'Jardín, Antioquia', 'Jardín', 55000, '1 hora', 'fácil', 10, true, ARRAY['Avistamiento', 'Aves', 'Naturaleza', 'Madrugada']),
('Tour de café en Jardín', 'Visita finca cafetera, proceso completo del grano a la taza y cata guiada.', 'Jardín, Antioquia', 'Jardín', 95000, '3 horas', 'fácil', 12, true, ARRAY['Café', 'Cata', 'Finca', 'Gastronomía']);

-- ==========================================
-- VERIFICACIÓN FINAL
-- ==========================================

SELECT 'Schema created successfully!' as status;
