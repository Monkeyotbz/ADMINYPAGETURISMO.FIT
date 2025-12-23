-- ================================================
-- ESQUEMA DE BASE DE DATOS - TURISMOCOLOMBIA
-- ================================================
-- Ejecuta este código en el SQL Editor de Supabase
-- Dashboard > SQL Editor > New Query > Pega este código > Run

-- ================================================
-- 1. TABLA DE USUARIOS
-- ================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  document_type TEXT CHECK (document_type IN ('CC', 'CE', 'Pasaporte', 'NIT')),
  document_number TEXT,
  country TEXT DEFAULT 'Colombia',
  city TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para búsquedas rápidas
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_document ON users(document_number);

-- ================================================
-- 2. TABLA DE RESERVAS
-- ================================================
CREATE TABLE IF NOT EXISTS reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Tipo de reserva
  reservation_type TEXT NOT NULL CHECK (reservation_type IN ('property', 'tour')),
  item_id TEXT NOT NULL, -- ID de la propiedad o tour
  item_name TEXT NOT NULL, -- Nombre para referencia rápida
  
  -- Fechas
  check_in DATE NOT NULL,
  check_out DATE,
  nights INTEGER,
  guests INTEGER NOT NULL DEFAULT 1,
  
  -- Precios
  base_price DECIMAL(10,2) NOT NULL,
  services_price DECIMAL(10,2) DEFAULT 0,
  discounts DECIMAL(10,2) DEFAULT 0,
  total_price DECIMAL(10,2) NOT NULL,
  
  -- Servicios adicionales (JSON)
  additional_services JSONB DEFAULT '[]',
  
  -- Estado de la reserva
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',      -- Esperando pago
    'confirmed',    -- Pagado y confirmado
    'cancelled',    -- Cancelado por usuario
    'completed',    -- Servicio completado
    'refunded'      -- Reembolsado
  )),
  
  -- Pago
  payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN (
    'pending',      -- Esperando pago
    'paid',         -- Pagado
    'failed',       -- Pago fallido
    'refunded'      -- Reembolsado
  )),
  payment_method TEXT,
  payment_id TEXT, -- ID de transacción de Mercado Pago
  
  -- Notas especiales del cliente
  special_requests TEXT,
  
  -- Auditoría
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  confirmed_at TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE
);

-- Índices
CREATE INDEX idx_reservations_user ON reservations(user_id);
CREATE INDEX idx_reservations_status ON reservations(status);
CREATE INDEX idx_reservations_dates ON reservations(check_in, check_out);
CREATE INDEX idx_reservations_item ON reservations(item_id);

-- ================================================
-- 3. TABLA DE PAGOS
-- ================================================
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id UUID REFERENCES reservations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  
  -- Información del pago
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'COP',
  payment_method TEXT NOT NULL, -- 'credit_card', 'pse', 'nequi', etc.
  
  -- IDs de la pasarela
  payment_gateway TEXT DEFAULT 'mercadopago',
  gateway_payment_id TEXT UNIQUE, -- ID de Mercado Pago
  gateway_status TEXT,
  
  -- Estado
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',
    'approved',
    'rejected',
    'refunded',
    'cancelled'
  )),
  
  -- Metadata
  metadata JSONB,
  
  -- Auditoría
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  approved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_payments_reservation ON payments(reservation_id);
CREATE INDEX idx_payments_gateway_id ON payments(gateway_payment_id);

-- ================================================
-- 4. TABLA DE FACTURAS
-- ================================================
CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id UUID REFERENCES reservations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  
  -- Numeración
  invoice_number TEXT UNIQUE NOT NULL, -- Ej: FAC-2025-0001
  
  -- Montos
  subtotal DECIMAL(10,2) NOT NULL,
  tax DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  
  -- PDF
  pdf_url TEXT, -- URL del PDF en Supabase Storage
  
  -- Estado
  status TEXT DEFAULT 'issued' CHECK (status IN ('issued', 'paid', 'cancelled')),
  
  -- Fechas
  issue_date DATE DEFAULT CURRENT_DATE,
  due_date DATE,
  paid_date DATE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_invoices_number ON invoices(invoice_number);
CREATE INDEX idx_invoices_reservation ON invoices(reservation_id);

-- ================================================
-- 5. TABLA DE REEMBOLSOS
-- ================================================
CREATE TABLE IF NOT EXISTS refunds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id UUID REFERENCES reservations(id) ON DELETE CASCADE,
  payment_id UUID REFERENCES payments(id),
  user_id UUID REFERENCES users(id),
  
  -- Monto
  amount DECIMAL(10,2) NOT NULL,
  reason TEXT NOT NULL,
  
  -- Estado
  status TEXT DEFAULT 'requested' CHECK (status IN (
    'requested',    -- Solicitado por usuario
    'approved',     -- Aprobado por admin
    'rejected',     -- Rechazado
    'processing',   -- En proceso
    'completed'     -- Completado
  )),
  
  -- Información del reembolso
  refund_method TEXT, -- Mismo método de pago original
  gateway_refund_id TEXT,
  
  -- Notas del admin
  admin_notes TEXT,
  
  -- Auditoría
  requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_refunds_reservation ON refunds(reservation_id);
CREATE INDEX idx_refunds_status ON refunds(status);

-- ================================================
-- 6. TABLA DE DISPONIBILIDAD (Para propiedades)
-- ================================================
CREATE TABLE IF NOT EXISTS property_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id TEXT NOT NULL,
  date DATE NOT NULL,
  available BOOLEAN DEFAULT TRUE,
  reason TEXT, -- 'reserved', 'maintenance', 'blocked'
  reservation_id UUID REFERENCES reservations(id) ON DELETE SET NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(property_id, date)
);

CREATE INDEX idx_availability_property ON property_availability(property_id, date);

-- ================================================
-- 7. TABLA DE CUPOS DE TOURS
-- ================================================
CREATE TABLE IF NOT EXISTS tour_capacity (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tour_id TEXT NOT NULL,
  date DATE NOT NULL,
  total_capacity INTEGER NOT NULL DEFAULT 20,
  reserved_spots INTEGER DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(tour_id, date),
  CHECK (reserved_spots <= total_capacity)
);

CREATE INDEX idx_tour_capacity_tour ON tour_capacity(tour_id, date);

-- ================================================
-- 8. FUNCIONES Y TRIGGERS
-- ================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para actualizar updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reservations_updated_at BEFORE UPDATE ON reservations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para generar número de factura
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TEXT AS $$
DECLARE
  year TEXT;
  seq INTEGER;
BEGIN
  year := TO_CHAR(CURRENT_DATE, 'YYYY');
  
  SELECT COALESCE(MAX(CAST(SUBSTRING(invoice_number FROM '\d+$') AS INTEGER)), 0) + 1
  INTO seq
  FROM invoices
  WHERE invoice_number LIKE 'FAC-' || year || '-%';
  
  RETURN 'FAC-' || year || '-' || LPAD(seq::TEXT, 4, '0');
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 9. ROW LEVEL SECURITY (RLS)
-- ================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;

-- Políticas básicas (los usuarios solo ven sus propios datos)
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own reservations" ON reservations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create reservations" ON reservations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own payments" ON payments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own invoices" ON invoices
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can request refunds" ON refunds
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own refunds" ON refunds
  FOR SELECT USING (auth.uid() = user_id);

-- ================================================
-- 10. DATOS DE EJEMPLO (OPCIONAL - PARA TESTING)
-- ================================================
-- Descomentar si quieres datos de prueba

/*
INSERT INTO users (id, email, full_name, phone, document_type, document_number, city) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'test@example.com', 'Usuario de Prueba', '3001234567', 'CC', '123456789', 'Bogotá');

INSERT INTO reservations (user_id, reservation_type, item_id, item_name, check_in, check_out, nights, guests, base_price, total_price, status) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'property', 'penthouse-panorama', 'Penthouse Panorama Medellín', '2025-01-15', '2025-01-17', 2, 2, 520000, 1040000, 'confirmed');
*/

-- ================================================
-- FIN DEL SCRIPT
-- ================================================
-- Ahora puedes empezar a usar estas tablas en tu aplicación
