-- ================================================
-- SISTEMA DE CALENDARIO Y PRECIOS ESPECIALES
-- ================================================

-- ==========================================
-- 1. TABLA DE PRECIOS ESPECIALES POR FECHA
-- ==========================================
CREATE TABLE IF NOT EXISTS special_pricing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  price_per_night DECIMAL(10,2) NOT NULL,
  reason TEXT, -- Ej: "Temporada Alta", "Fin de Semana Largo", "Descuento Black Friday"
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  created_by UUID REFERENCES users(id)
);

-- ==========================================
-- 2. TABLA DE DISPONIBILIDAD BLOQUEADA
-- ==========================================
CREATE TABLE IF NOT EXISTS blocked_dates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason TEXT, -- Ej: "Mantenimiento", "Reservado fuera del sistema", "Bloqueado por propietario"
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  created_by UUID REFERENCES users(id)
);

-- ==========================================
-- 3. TABLA DE DESCUENTOS Y OFERTAS
-- ==========================================
CREATE TABLE IF NOT EXISTS discounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  tour_id UUID REFERENCES tours(id) ON DELETE CASCADE,
  discount_type TEXT CHECK (discount_type IN ('percentage', 'fixed_amount', 'nights_free')) NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL, -- Porcentaje o monto fijo
  min_nights INTEGER, -- Mínimo de noches para aplicar el descuento
  start_date DATE,
  end_date DATE,
  code TEXT UNIQUE, -- Código de cupón (opcional)
  description TEXT,
  active BOOLEAN DEFAULT true,
  max_uses INTEGER, -- Máximo de veces que se puede usar
  times_used INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  created_by UUID REFERENCES users(id),
  CONSTRAINT property_or_tour CHECK (
    (property_id IS NOT NULL AND tour_id IS NULL) OR 
    (property_id IS NULL AND tour_id IS NOT NULL)
  )
);

-- ==========================================
-- 4. ACTUALIZAR TABLA BOOKINGS (si es necesario)
-- ==========================================
-- Agregar campos útiles para el calendario
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS discount_id UUID REFERENCES discounts(id);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS original_price DECIMAL(10,2);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS discount_applied DECIMAL(10,2) DEFAULT 0;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS nights INTEGER;

-- ==========================================
-- 5. ÍNDICES PARA MEJOR RENDIMIENTO
-- ==========================================
CREATE INDEX IF NOT EXISTS idx_special_pricing_property_dates ON special_pricing(property_id, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_blocked_dates_property_dates ON blocked_dates(property_id, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_discounts_property ON discounts(property_id) WHERE property_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_discounts_tour ON discounts(tour_id) WHERE tour_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_discounts_code ON discounts(code) WHERE code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bookings_property_dates ON bookings(property_id, check_in, check_out);

-- ==========================================
-- 6. ROW LEVEL SECURITY
-- ==========================================

-- Habilitar RLS
ALTER TABLE special_pricing ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_dates ENABLE ROW LEVEL SECURITY;
ALTER TABLE discounts ENABLE ROW LEVEL SECURITY;

-- Políticas para SPECIAL_PRICING
DROP POLICY IF EXISTS "Anyone can view special pricing" ON special_pricing;
CREATE POLICY "Anyone can view special pricing" ON special_pricing
  FOR SELECT USING (active = true OR auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

DROP POLICY IF EXISTS "Only admins can manage special pricing" ON special_pricing;
CREATE POLICY "Only admins can manage special pricing" ON special_pricing
  FOR ALL TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Políticas para BLOCKED_DATES
DROP POLICY IF EXISTS "Anyone can view blocked dates" ON blocked_dates;
CREATE POLICY "Anyone can view blocked dates" ON blocked_dates
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Only admins can manage blocked dates" ON blocked_dates;
CREATE POLICY "Only admins can manage blocked dates" ON blocked_dates
  FOR ALL TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- Políticas para DISCOUNTS
DROP POLICY IF EXISTS "Anyone can view active discounts" ON discounts;
CREATE POLICY "Anyone can view active discounts" ON discounts
  FOR SELECT USING (active = true OR auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

DROP POLICY IF EXISTS "Only admins can manage discounts" ON discounts;
CREATE POLICY "Only admins can manage discounts" ON discounts
  FOR ALL TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE role = 'admin'));

-- ==========================================
-- 7. FUNCIÓN PARA CALCULAR PRECIO TOTAL
-- ==========================================
CREATE OR REPLACE FUNCTION calculate_booking_price(
  p_property_id UUID,
  p_check_in DATE,
  p_check_out DATE,
  p_discount_code TEXT DEFAULT NULL
)
RETURNS TABLE(
  total_nights INTEGER,
  base_price DECIMAL(10,2),
  special_pricing_total DECIMAL(10,2),
  discount_amount DECIMAL(10,2),
  final_price DECIMAL(10,2)
) AS $$
DECLARE
  v_base_price DECIMAL(10,2);
  v_nights INTEGER;
  v_current_date DATE;
  v_daily_price DECIMAL(10,2);
  v_special_total DECIMAL(10,2) := 0;
  v_discount RECORD;
  v_discount_amount DECIMAL(10,2) := 0;
BEGIN
  -- Calcular noches
  v_nights := p_check_out - p_check_in;
  
  -- Obtener precio base de la propiedad
  SELECT price_per_night INTO v_base_price
  FROM properties
  WHERE id = p_property_id;
  
  -- Calcular precio considerando precios especiales
  v_current_date := p_check_in;
  WHILE v_current_date < p_check_out LOOP
    -- Buscar si hay precio especial para esta fecha
    SELECT price_per_night INTO v_daily_price
    FROM special_pricing
    WHERE property_id = p_property_id
      AND start_date <= v_current_date
      AND end_date >= v_current_date
      AND active = true
    LIMIT 1;
    
    IF v_daily_price IS NOT NULL THEN
      v_special_total := v_special_total + v_daily_price;
    ELSE
      v_special_total := v_special_total + v_base_price;
    END IF;
    
    v_current_date := v_current_date + 1;
    v_daily_price := NULL;
  END LOOP;
  
  -- Aplicar descuentos si hay código
  IF p_discount_code IS NOT NULL THEN
    SELECT * INTO v_discount
    FROM discounts
    WHERE code = p_discount_code
      AND property_id = p_property_id
      AND active = true
      AND (start_date IS NULL OR start_date <= p_check_in)
      AND (end_date IS NULL OR end_date >= p_check_out)
      AND (min_nights IS NULL OR v_nights >= min_nights)
      AND (max_uses IS NULL OR times_used < max_uses)
    LIMIT 1;
    
    IF v_discount.id IS NOT NULL THEN
      IF v_discount.discount_type = 'percentage' THEN
        v_discount_amount := v_special_total * (v_discount.discount_value / 100);
      ELSIF v_discount.discount_type = 'fixed_amount' THEN
        v_discount_amount := v_discount.discount_value;
      ELSIF v_discount.discount_type = 'nights_free' THEN
        v_discount_amount := v_base_price * v_discount.discount_value;
      END IF;
    END IF;
  END IF;
  
  RETURN QUERY SELECT 
    v_nights,
    v_base_price * v_nights,
    v_special_total,
    v_discount_amount,
    v_special_total - v_discount_amount;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- 8. FUNCIÓN PARA VERIFICAR DISPONIBILIDAD
-- ==========================================
CREATE OR REPLACE FUNCTION check_availability(
  p_property_id UUID,
  p_check_in DATE,
  p_check_out DATE
)
RETURNS BOOLEAN AS $$
DECLARE
  v_booking_count INTEGER;
  v_blocked_count INTEGER;
BEGIN
  -- Verificar si hay reservas en esas fechas
  SELECT COUNT(*) INTO v_booking_count
  FROM bookings
  WHERE property_id = p_property_id
    AND status NOT IN ('cancelled')
    AND (
      (check_in < p_check_out AND check_out > p_check_in)
    );
  
  -- Verificar si hay fechas bloqueadas
  SELECT COUNT(*) INTO v_blocked_count
  FROM blocked_dates
  WHERE property_id = p_property_id
    AND start_date < p_check_out
    AND end_date > p_check_in;
  
  RETURN (v_booking_count = 0 AND v_blocked_count = 0);
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- VERIFICACIÓN
-- ==========================================
SELECT 'Sistema de calendario y precios creado exitosamente!' as mensaje;
