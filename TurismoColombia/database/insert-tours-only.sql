-- ================================================
-- INSERTAR SOLO LOS 47 TOURS
-- (Las propiedades ya están, no las duplicamos)
-- ================================================

INSERT INTO tours (name, description, location, city, price, duration, difficulty, max_people, featured, includes) VALUES

-- ==========================================
-- TOURS DE CARTAGENA (22 tours)
-- ==========================================
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

('BORA BORA BEACH CLUB', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo típico. Sillas acostadoras, piscina, bar, carpas acondicionadas, piscina y secciones acuáticas de la isla', 'Cartagena, Bolívar', 'Cartagena', 95000, '7.5 horas', 'fácil', 35, true, ARRAY['Beach club', 'Piscina', 'Almuerzo', 'Bar']),

('BORA BORA V.I.P', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo con opciones de paella valenciana, cordial típico, sancocho, almuerzo de pollo o pescado y cerdo asado', 'Cartagena, Bolívar', 'Cartagena', 130000, '7.5 horas', 'fácil', 25, true, ARRAY['VIP', 'Paella', 'Piscina', 'Almuerzo']),

('PAO PAO BEACH CLUB', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo con opciones de paella, pasta o la boloñesa, típico sancocho o pollo. Sillas acostadoras, piscina, hamacas, billar, mesas de ping', 'Cartagena, Bolívar', 'Cartagena', 100000, '7.5 horas', 'fácil', 30, false, ARRAY['Beach club', 'Paella', 'Piscina', 'Billar']),

('LUXURY OPEN BAR', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Barra abierta en bebidas sin bahiston. Almuerzo tipo buffet. Sillas acostadoras, piscina, bar, camastros, carpas acondicionadas', 'Cartagena, Bolívar', 'Cartagena', 140000, '7.5 horas', 'fácil', 30, true, ARRAY['Luxury', 'Open bar', 'Buffet', 'Piscina']),

('LUXURY CLASSIC', 'Transporte marítimo ida y regreso. Cóctel de bienvenida. Almuerzo tipo buffet. Sillas acostadoras, piscina, bar, camastros, carpas acondicionadas piscinas todas piscina, hamacas', 'Cartagena, Bolívar', 'Cartagena', 120000, '7.5 horas', 'fácil', 30, false, ARRAY['Luxury', 'Buffet', 'Piscina', 'Bar']),

('SIBARITA MASTER CENA', 'Cena o & Espíritu 5 platos de servido, 3 platos fuertes, 3 apetitivo y marida con vino por persona. Espectáculo de música en vivo, marisco y producto del mar, con sazón exclusivos', 'Cartagena, Bolívar', 'Cartagena', 180000, '2.5 horas', 'fácil', 20, true, ARRAY['Cena gourmet', '5 tiempos', 'Vino', 'Música en vivo']),

('BAHÍA RUMBERA (en bote deportivo)', 'Transporte en bote deportivo. Barra libre de ron con gaseosas. Pasabocas, dj marineros y agua. Galeón pirata. Recorrido por la bahía de la isla de Manga, isla, la Castillo Grande. Cumbias, Salsa y Pachanga', 'Cartagena, Bolívar', 'Cartagena', 110000, '4 horas', 'fácil', 14, true, ARRAY['Bote deportivo', 'Fiesta', 'Ron', 'DJ', 'Bahía']),

-- ==========================================
-- TOURS DE MEDELLÍN (9 tours)
-- ==========================================
('Graffiti tour + Comuna 13', 'Recorrido guiado por la Comuna 13 con escaleras eléctricas, arte urbano y historias locales.', 'Medellín, Antioquia', 'Medellín', 80000, '3 horas', 'fácil', 15, true, ARRAY['Guia local', 'Transporte', 'Fotografia']),

('Tour por la Ciudad de Medellín', 'Conoce la Ciudad de la Eterna Primavera con nuestro tour completo! Incluye transporte, entradas, guía experto, póliza de asistencia e hidratación. Visitarás el Pueblito Paisa, Milla de Oro, Graffiti Tour en la Comuna Trece, La 70 y el Parque Botero.', 'Medellín, Antioquia', 'Medellín', 90000, '4 horas', 'fácil', 20, true, ARRAY['City tour', 'Pueblito Paisa', 'Comuna 13', 'Parque Botero']),

('Tour por el Centro Histórico y Plaza Botero', 'Este tour te llevará a explorar el centro histórico de Medellín, donde podrás admirar la arquitectura colonial, visitar la famosa Plaza Botero y maravillarte con las esculturas del reconocido artista Fernando Botero.', 'Medellín, Antioquia', 'Medellín', 70000, '3 horas', 'fácil', 20, false, ARRAY['Centro histórico', 'Plaza Botero', 'Arte', 'Cultura']),

('Excursión al Parque Arví', 'Escápate del bullicio de la ciudad y sumérgete en la naturaleza en el Parque Arví. Este tour te llevará en un viaje en teleférico hasta este hermoso parque natural, donde podrás disfrutar de senderos para caminatas, actividades al aire libre y vistas panorámicas.', 'Medellín, Antioquia', 'Medellín', 85000, '5 horas', 'moderado', 15, true, ARRAY['Naturaleza', 'Teleférico', 'Senderismo', 'Parque']),

('Tour Gastronómico por Medellín', 'Embárcate en un viaje culinario por los sabores de Medellín. Prueba platos tradicionales como la bandeja paisa, la arepa de chócolo y la lechona, así como delicias modernas en restaurantes y mercados locales.', 'Medellín, Antioquia', 'Medellín', 95000, '4 horas', 'fácil', 12, true, ARRAY['Gastronomía', 'Bandeja paisa', 'Comida local', 'Mercados']),

('Tour Histórico de Pablo Escobar', 'Este tour ofrece una mirada objetiva y educativa sobre el pasado de Medellín relacionado con Pablo Escobar y el narcotráfico. Guiado por expertos locales que conocen profundamente la historia de la ciudad.', 'Medellín, Antioquia', 'Medellín', 100000, '4 horas', 'fácil', 15, false, ARRAY['Historia', 'Pablo Escobar', 'Educativo', 'Cultural']),

('Parque Explora', 'El Parque Explora es un centro interactivo de ciencia y tecnología que ofrece una experiencia educativa y divertida para visitantes de todas las edades. El Jardín Botánico es un oasis urbano de paz y naturaleza.', 'Medellín, Antioquia', 'Medellín', 75000, '4 horas', 'fácil', 20, true, ARRAY['Ciencia', 'Tecnología', 'Jardín Botánico', 'Educativo']),

('Tour por la Hacienda Nápoles', 'Vive un día en familia lleno de diversión en el Parque Temático Hacienda Nápoles desde Medellín en Doradal, municipio de Puerto Triunfo, Antioquia. Disfrutarás de imponentes atracciones acuáticas, fauna salvaje y mucha diversión.', 'Doradal, Antioquia', 'Medellín', 150000, '9 horas', 'fácil', 25, true, ARRAY['Parque temático', 'Safari', 'Familia', 'Acuático', 'Aventura']),

('Tour por Guatapé, Antioquia', 'Conoce la maravillosa piedra el Peñol, alto del chocho con granja y con su variedad de platos de nuestra gastronomía, el pueblo de Guatapé y su hermosa arquitectura patrimonial de mucho color y cultura.', 'Guatapé, Antioquia', 'Medellín', 130000, '8 horas', 'fácil', 20, true, ARRAY['Peñol', 'Pueblo', 'Lancha', 'Cultura', 'Gastronomía']),

-- ==========================================
-- TOURS DE JARDÍN (16 tours)
-- ==========================================
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
-- VERIFICAR QUE SE INSERTARON LOS 47 TOURS
-- ==========================================
SELECT 
  'Tours insertados correctamente!' as mensaje,
  COUNT(*) as total_tours,
  COUNT(*) FILTER (WHERE city = 'Cartagena') as cartagena,
  COUNT(*) FILTER (WHERE city = 'Medellín') as medellin,
  COUNT(*) FILTER (WHERE city = 'Jardín') as jardin
FROM tours;
