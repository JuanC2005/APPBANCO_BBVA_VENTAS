-- ============================================================
-- SCRIPT 09 — Tablas espejo cr_* para App Clientes (Homebanking)
-- App Móvil BBVA Fuerza de Ventas + App Clientes · v2.0
-- ============================================================
-- EJECUTAR: después del 04_seed_demo_bbva.sql
-- ============================================================
-- TABLAS: cr_cuentas_ahorro, cr_movimientos, cr_cronograma_cuotas,
--          cr_tarjetas, cr_notificaciones_cliente, clientes_app
-- ============================================================

-- ── Limpieza segura ───────────────────────────────────────
DROP TABLE IF EXISTS public.cr_notificaciones_cliente CASCADE;
DROP TABLE IF EXISTS public.cr_tarjetas CASCADE;
DROP TABLE IF EXISTS public.cr_cronograma_cuotas CASCADE;
DROP TABLE IF EXISTS public.cr_movimientos CASCADE;
DROP TABLE IF EXISTS public.cr_cuentas_ahorro CASCADE;
DROP TABLE IF EXISTS public.clientes_app CASCADE;

-- ============================================================
-- 1. CLIENTES_APP — Usuarios de la App Clientes (homebanking)
-- ============================================================
CREATE TABLE public.clientes_app (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id        UUID        NOT NULL,
  user_id           UUID        UNIQUE,
  email             TEXT,
  password_hash     TEXT,
  activo            BOOLEAN     NOT NULL DEFAULT TRUE,
  ultimo_acceso     TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT fk_clientes_app_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_clientes_app_cliente ON public.clientes_app(cliente_id);

-- ============================================================
-- 2. CR_CUENTAS_AHORRO — Cuentas de ahorro / corriente
-- ============================================================
CREATE TABLE public.cr_cuentas_ahorro (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id        UUID        NOT NULL,
  numero_cuenta     TEXT        NOT NULL UNIQUE,
  tipo_cuenta       TEXT        NOT NULL CHECK (tipo_cuenta IN ('ahorros','corriente','plazo_fijo')),
  moneda            TEXT        NOT NULL DEFAULT 'PEN' CHECK (moneda IN ('PEN','USD')),
  saldo_actual      NUMERIC(12,2) NOT NULL DEFAULT 0,
  estado            TEXT        NOT NULL DEFAULT 'activa' CHECK (estado IN ('activa','bloqueada','cerrada')),
  fecha_apertura    DATE        NOT NULL DEFAULT CURRENT_DATE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT fk_cuentas_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE
);

CREATE INDEX idx_cr_cuentas_cliente ON public.cr_cuentas_ahorro(cliente_id);
CREATE INDEX idx_cr_cuentas_estado ON public.cr_cuentas_ahorro(estado);

-- ============================================================
-- 3. CR_MOVIMIENTOS — Historial de transacciones
-- ============================================================
CREATE TABLE public.cr_movimientos (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cuenta_id         UUID        NOT NULL,
  cliente_id        UUID        NOT NULL,
  tipo_movimiento   TEXT        NOT NULL CHECK (tipo_movimiento IN ('deposito','retiro','transferencia','pago','comision','interes','cargo')),
  monto             NUMERIC(12,2) NOT NULL,
  moneda            TEXT        NOT NULL DEFAULT 'PEN',
  saldo_anterior    NUMERIC(12,2) NOT NULL DEFAULT 0,
  saldo_posterior   NUMERIC(12,2) NOT NULL DEFAULT 0,
  descripcion       TEXT,
  referencia        TEXT,
  fecha_operacion   DATE        NOT NULL DEFAULT CURRENT_DATE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT fk_movimientos_cuenta FOREIGN KEY (cuenta_id) REFERENCES public.cr_cuentas_ahorro(id) ON DELETE CASCADE,
  CONSTRAINT fk_movimientos_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE
);

CREATE INDEX idx_cr_movimientos_cuenta ON public.cr_movimientos(cuenta_id);
CREATE INDEX idx_cr_movimientos_cliente ON public.cr_movimientos(cliente_id);
CREATE INDEX idx_cr_movimientos_fecha ON public.cr_movimientos(fecha_operacion DESC);

-- ============================================================
-- 4. CR_CRONOGRAMA_CUOTAS — Cronograma de pagos de créditos
-- ============================================================
CREATE TABLE public.cr_cronograma_cuotas (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  credito_id        UUID        NOT NULL,
  cliente_id        UUID        NOT NULL,
  nro_cuota         INTEGER     NOT NULL,
  fecha_vencimiento DATE        NOT NULL,
  capital           NUMERIC(12,2) NOT NULL DEFAULT 0,
  interes           NUMERIC(12,2) NOT NULL DEFAULT 0,
  seguro            NUMERIC(12,2) NOT NULL DEFAULT 0,
  cuota_total       NUMERIC(12,2) NOT NULL DEFAULT 0,
  saldo             NUMERIC(12,2) NOT NULL DEFAULT 0,
  estado            TEXT        NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','pagada','vencida','castigada')),
  fecha_pago        DATE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT fk_cronograma_credito FOREIGN KEY (credito_id) REFERENCES public.creditos(id) ON DELETE CASCADE,
  CONSTRAINT fk_cronograma_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE,
  CONSTRAINT uq_cuota_credito UNIQUE (credito_id, nro_cuota)
);

CREATE INDEX idx_cr_cronograma_credito ON public.cr_cronograma_cuotas(credito_id);
CREATE INDEX idx_cr_cronograma_cliente ON public.cr_cronograma_cuotas(cliente_id);

-- ============================================================
-- 5. CR_TARJETAS — Tarjetas de crédito/débito
-- ============================================================
CREATE TABLE public.cr_tarjetas (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id        UUID        NOT NULL,
  numero_tarjeta    TEXT        NOT NULL,
  tipo_tarjeta      TEXT        NOT NULL CHECK (tipo_tarjeta IN ('credito','debito','prepago')),
  marca             TEXT        NOT NULL DEFAULT 'Visa' CHECK (marca IN ('Visa','MasterCard','American Express')),
  estado            TEXT        NOT NULL DEFAULT 'activa' CHECK (estado IN ('activa','bloqueada','vencida','cancelada')),
  limite_credito    NUMERIC(12,2) DEFAULT 0,
  saldo_utilizado   NUMERIC(12,2) DEFAULT 0,
  fecha_vencimiento DATE        NOT NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT fk_tarjetas_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE
);

CREATE INDEX idx_cr_tarjetas_cliente ON public.cr_tarjetas(cliente_id);

-- ============================================================
-- 6. CR_NOTIFICACIONES_CLIENTE — Notificaciones push/in-app
-- ============================================================
CREATE TABLE public.cr_notificaciones_cliente (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id        UUID        NOT NULL,
  tipo              TEXT        NOT NULL DEFAULT 'info' CHECK (tipo IN ('info','alerta','pago','promocion','seguridad')),
  titulo            TEXT        NOT NULL,
  mensaje           TEXT        NOT NULL,
  leida             BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT fk_notificaciones_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE
);

CREATE INDEX idx_cr_notificaciones_cliente ON public.cr_notificaciones_cliente(cliente_id);
CREATE INDEX idx_cr_notificaciones_leida ON public.cr_notificaciones_cliente(leida);

-- ============================================================
-- SEED DATA — Datos demo para App Clientes
-- ============================================================
-- Usar clientes existentes del seed 04

-- Usuarios de la App Clientes (password: 123456, SHA-256)
INSERT INTO public.clientes_app (id, cliente_id, password_hash, activo)
VALUES
  ('ca000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',TRUE),
  ('ca000001-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000002','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',TRUE),
  ('ca000001-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000003','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',TRUE),
  ('ca000001-0001-0001-0001-000000000006','cccccccc-0001-0001-0001-000000000006','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',TRUE);

-- Cuentas de ahorro
INSERT INTO public.cr_cuentas_ahorro (id, cliente_id, numero_cuenta, tipo_cuenta, moneda, saldo_actual, fecha_apertura)
VALUES
  ('a0000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','0011-2233-4455-6677','ahorros','PEN',5000.00,'2024-01-15'),
  ('a0000001-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001','0011-2233-4455-6678','corriente','PEN',2500.00,'2024-03-01'),
  ('a0000001-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002','0011-2233-4455-6679','ahorros','PEN',12000.00,'2024-02-20'),
  ('a0000001-0001-0001-0001-000000000004','cccccccc-0001-0001-0001-000000000003','0011-2233-4455-6680','ahorros','PEN',3200.00,'2024-06-10'),
  ('a0000001-0001-0001-0001-000000000005','cccccccc-0001-0001-0001-000000000006','0011-2233-4455-6681','ahorros','PEN',800.00,'2024-05-05');

-- Movimientos de ejemplo (últimos 15 días)
INSERT INTO public.cr_movimientos (cuenta_id, cliente_id, tipo_movimiento, monto, moneda, saldo_anterior, saldo_posterior, descripcion, fecha_operacion, created_at)
SELECT * FROM (VALUES
  ('a0000001-0001-0001-0001-000000000001'::UUID,'cccccccc-0001-0001-0001-000000000001'::UUID,'deposito'::TEXT,2000.00,'PEN'::TEXT,3000.00,5000.00,'Depósito por venta del día'::TEXT,CURRENT_DATE - 1,CURRENT_DATE - 1),
  ('a0000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','retiro',500.00,'PEN',3500.00,3000.00,'Retiro ATM'::TEXT,CURRENT_DATE - 3,CURRENT_DATE - 3),
  ('a0000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','transferencia',800.00,'PEN',4300.00,3500.00,'Transferencia a proveedor'::TEXT,CURRENT_DATE - 5,CURRENT_DATE - 5),
  ('a0000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','pago',450.00,'PEN',4750.00,4300.00,'Pago de cuota crédito'::TEXT,CURRENT_DATE - 7,CURRENT_DATE - 7),
  ('a0000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','deposito',1500.00,'PEN',3250.00,4750.00,'Depósito en ventanilla'::TEXT,CURRENT_DATE - 10,CURRENT_DATE - 10),
  ('a0000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','comision',15.00,'PEN',3265.00,3250.00,'Comisión mantenimiento'::TEXT,CURRENT_DATE - 12,CURRENT_DATE - 12),
  ('a0000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','interes',25.00,'PEN',3240.00,3265.00,'Interés por ahorros'::TEXT,CURRENT_DATE - 14,CURRENT_DATE - 14),
  ('a0000001-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002','deposito',3000.00,'PEN',9000.00,12000.00,'Depósito por cobranza'::TEXT,CURRENT_DATE - 2,CURRENT_DATE - 2),
  ('a0000001-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002','transferencia',1500.00,'PEN',10500.00,9000.00,'Transferencia a sede central'::TEXT,CURRENT_DATE - 4,CURRENT_DATE - 4),
  ('a0000001-0001-0001-0001-000000000004','cccccccc-0001-0001-0001-000000000003','deposito',800.00,'PEN',2400.00,3200.00,'Depósito en agencia'::TEXT,CURRENT_DATE - 6,CURRENT_DATE - 6)
) AS t;

-- Cronograma de cuotas para créditos existentes
-- Crédito ffffffff-0001-0001-0001-000000000002 (8,000 a 12 meses, 16% TEA)
INSERT INTO public.cr_cronograma_cuotas (credito_id, cliente_id, nro_cuota, fecha_vencimiento, capital, interes, seguro, cuota_total, saldo, estado, fecha_pago)
SELECT * FROM (VALUES
  ('ffffffff-0001-0001-0001-000000000002'::UUID,'cccccccc-0001-0001-0001-000000000001'::UUID,1,'2025-07-01'::DATE,620.00,106.67,15.00,741.67,7380.00,'pagada'::TEXT,'2025-07-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',2,'2025-08-01'::DATE,626.00,98.40,15.00,739.40,6754.00,'pagada','2025-08-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',3,'2025-09-01'::DATE,632.00,90.05,15.00,737.05,6122.00,'pagada','2025-09-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',4,'2025-10-01'::DATE,638.00,81.63,15.00,734.63,5484.00,'pagada','2025-10-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',5,'2025-11-01'::DATE,645.00,73.12,15.00,733.12,4839.00,'pagada','2025-11-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',6,'2025-12-01'::DATE,651.00,64.52,15.00,730.52,4188.00,'pagada','2025-12-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',7,'2026-01-01'::DATE,658.00,55.84,15.00,728.84,3530.00,'pagada','2026-01-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',8,'2026-02-01'::DATE,664.00,47.07,15.00,726.07,2866.00,'pagada','2026-02-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',9,'2026-03-01'::DATE,671.00,38.21,15.00,724.21,2195.00,'pagada','2026-03-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',10,'2026-04-01'::DATE,677.00,29.27,15.00,721.27,1518.00,'pagada','2026-04-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',11,'2026-05-01'::DATE,684.00,20.24,15.00,719.24,834.00,'pagada','2026-05-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001',12,'2026-06-01'::DATE,691.00,11.12,15.00,717.12,0.00,'pagada','2026-06-01'::DATE),
  ('ffffffff-0001-0001-0001-000000000003'::UUID,'cccccccc-0001-0001-0001-000000000002'::UUID,1,'2025-02-15'::DATE,700.00,187.50,20.00,907.50,14300.00,'pagada'::TEXT,'2025-02-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',2,'2025-03-15'::DATE,708.00,178.75,20.00,906.75,13592.00,'pagada','2025-03-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',3,'2025-04-15'::DATE,717.00,169.90,20.00,906.90,12875.00,'pagada','2025-04-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',4,'2025-05-15'::DATE,726.00,160.94,20.00,906.94,12149.00,'pagada','2025-05-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',5,'2025-06-15'::DATE,735.00,151.86,20.00,906.86,11414.00,'pagada','2025-06-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',6,'2025-07-15'::DATE,744.00,142.68,20.00,906.68,10670.00,'pagada','2025-07-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',7,'2025-08-15'::DATE,753.00,133.38,20.00,906.38,9917.00,'pagada','2025-08-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',8,'2025-09-15'::DATE,763.00,123.96,20.00,906.96,9154.00,'pagada','2025-09-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',9,'2025-10-15'::DATE,772.00,114.43,20.00,906.43,8382.00,'pagada','2025-10-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',10,'2025-11-15'::DATE,782.00,104.78,20.00,906.78,7600.00,'pagada','2025-11-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',11,'2025-12-15'::DATE,792.00,95.00,20.00,907.00,6808.00,'pagada','2025-12-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',12,'2026-01-15'::DATE,802.00,85.10,20.00,907.10,6006.00,'pagada','2026-01-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',13,'2026-02-15'::DATE,812.00,75.08,20.00,907.08,5194.00,'pagada','2026-02-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',14,'2026-03-15'::DATE,822.00,64.93,20.00,906.93,4372.00,'pagada','2026-03-15'::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',15,'2026-04-15'::DATE,832.00,54.65,20.00,906.65,3540.00,'pendiente',NULL::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',16,'2026-05-15'::DATE,843.00,44.25,20.00,907.25,2697.00,'pendiente',NULL::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',17,'2026-06-15'::DATE,853.00,33.71,20.00,906.71,1844.00,'pendiente',NULL::DATE),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002',18,'2026-07-15'::DATE,864.00,23.05,20.00,907.05,980.00,'pendiente',NULL::DATE)
) AS t;

-- Tarjetas de ejemplo
INSERT INTO public.cr_tarjetas (id, cliente_id, numero_tarjeta, tipo_tarjeta, marca, estado, limite_credito, saldo_utilizado, fecha_vencimiento)
VALUES
  ('b0000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','**** **** **** 4567','debito','Visa','activa',0,0,'2028-12-31'),
  ('b0000001-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001','**** **** **** 8901','credito','MasterCard','activa',5000.00,1500.00,'2027-06-30'),
  ('b0000001-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002','**** **** **** 2345','debito','Visa','activa',0,0,'2028-11-30'),
  ('b0000001-0001-0001-0001-000000000004','cccccccc-0001-0001-0001-000000000002','**** **** **** 6789','credito','Visa','activa',8000.00,3200.00,'2026-09-30'),
  ('b0000001-0001-0001-0001-000000000005','cccccccc-0001-0001-0001-000000000003','**** **** **** 0123','debito','Visa','activa',0,0,'2029-03-31');

-- Notificaciones de ejemplo
INSERT INTO public.cr_notificaciones_cliente (id, cliente_id, tipo, titulo, mensaje, leida, created_at)
VALUES
  ('00000001-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','pago','Pago de cuota registrado','Tu pago de S/ 721.27 por el crédito CR-0002 fue registrado con éxito.',TRUE,CURRENT_DATE - 5),
  ('00000001-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001','info','Depósito recibido','Se ha acreditado S/ 2,000.00 en tu cuenta de ahorros 0011-2233-4455-6677.',FALSE,CURRENT_DATE - 1),
  ('00000001-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000001','alerta','Proximo vencimiento','Tu cuota N°12 del crédito CR-0002 vence en 5 días.',FALSE,CURRENT_DATE),
  ('00000001-0001-0001-0001-000000000004','cccccccc-0001-0001-0001-000000000002','promocion','Oferta especial','¡Pre-calificado! Solicita hasta S/ 25,000 en tu próximo crédito con tasa preferencial.',FALSE,CURRENT_DATE - 2),
  ('00000001-0001-0001-0001-000000000005','cccccccc-0001-0001-0001-000000000003','seguridad','Inicio de sesión detectado','Se detectó un inicio de sesión desde un nuevo dispositivo. Si no fuiste tú, contacta a tu agente.',TRUE,CURRENT_DATE - 3);

-- ============================================================
-- VERIFICACION
-- ============================================================
SELECT 'clientes_app' AS tabla, COUNT(*) FROM public.clientes_app
UNION ALL SELECT 'cr_cuentas_ahorro', COUNT(*) FROM public.cr_cuentas_ahorro
UNION ALL SELECT 'cr_movimientos', COUNT(*) FROM public.cr_movimientos
UNION ALL SELECT 'cr_cronograma_cuotas', COUNT(*) FROM public.cr_cronograma_cuotas
UNION ALL SELECT 'cr_tarjetas', COUNT(*) FROM public.cr_tarjetas
UNION ALL SELECT 'cr_notificaciones_cliente', COUNT(*) FROM public.cr_notificaciones_cliente
ORDER BY tabla;

-- ============================================================
-- FIN — 09_cr_tables_homebanking.sql
-- ============================================================
