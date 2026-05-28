-- ============================================================
-- SCRIPT 03 — Seed Demo BBVA: Datos de Prueba
-- App Móvil BBVA Fuerza de Ventas · v1.0
-- ============================================================
-- EJECUTAR: 4to de 5 (después de 02_sucursales_ejecutivos_bbva.sql)
-- TIEMPO ESTIMADO: < 10 segundos
-- DB: bd_appbanco_bbva_ventas
-- ============================================================
-- QUÉ INSERTA:
--   5 sucursales BBVA en Junín/Huancayo
--   4 ejecutivos de negocio BBVA
--   1 admin
--   20 clientes reales con perfil socioeconómico andino
--   Historial de movimientos (6 meses por cliente)
--   Fichas de campo (10 visitas demo)
-- ============================================================

-- ── Limpieza en orden correcto (FK) ──────────────────────
TRUNCATE TABLE public.rutas_planificadas     RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.metas_ejecutivos       RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.creditos_preaprobados  RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.fichas_campo           RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.scores_crediticios     RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.features_scoring       RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.movimientos_mensuales  RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.perfiles_clientes      RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.ejecutivos_negocio     RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.sucursales_bbva        RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.solicitudes_credito    RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.cuentas_ahorro         RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.pagos_servicios        RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.transacciones          RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.cuentas_bbva           RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.usuarios_app           RESTART IDENTITY CASCADE;

-- ============================================================
-- 1. SUCURSALES BBVA — Red Junín
-- ============================================================
INSERT INTO public.sucursales_bbva
  (id, codigo, nombre, tipo, departamento, provincia, distrito, direccion, latitud, longitud)
VALUES
  ('aaaaaaaa-0001-0001-0001-000000000001',
   'HYX-01','BBVA Huancayo Principal','agencia',
   'Junín','Huancayo','Huancayo',
   'Jr. Ancash 745, Huancayo', -12.0653, -75.2049),

  ('aaaaaaaa-0001-0001-0001-000000000002',
   'HYX-02','BBVA El Tambo','agencia',
   'Junín','Huancayo','El Tambo',
   'Av. Ferrocarril 1250, El Tambo', -12.0445, -75.2112),

  ('aaaaaaaa-0001-0001-0001-000000000003',
   'HYX-03','BBVA Chilca','agencia',
   'Junín','Huancayo','Chilca',
   'Jr. Lima 320, Chilca', -12.0820, -75.2120),

  ('aaaaaaaa-0001-0001-0001-000000000004',
   'HYX-04','BBVA Chupaca','oficina_especial',
   'Junín','Chupaca','Chupaca',
   'Jr. Grau 180, Chupaca', -12.0580, -75.2860),

  ('aaaaaaaa-0001-0001-0001-000000000005',
   'HYX-05','BBVA Concepción','ventanilla',
   'Junín','Concepción','Concepción',
   'Jr. 9 de Julio 410, Concepción', -11.9153, -75.3142);

-- ============================================================
-- 2. USUARIOS BBVA — Ejecutivos, Admin y Clientes
-- ============================================================

-- Ejecutivos (4) y Admin (1)
INSERT INTO public.usuarios_app
  (id, email, nombre, apellido, rol)
VALUES
  ('bbbbbbbb-0001-0001-0001-000000000001',
   'admin@bbva.pe', 'Carlos', 'Mendoza','admin'),

  ('bbbbbbbb-0001-0001-0001-000000000002',
   'jessica.quispe@bbva.pe', 'Jessica', 'Quispe Huanca', 'ejecutivo'),

  ('bbbbbbbb-0001-0001-0001-000000000003',
   'mario.ccanto@bbva.pe', 'Mario', 'Ccanto Paucar', 'ejecutivo'),

  ('bbbbbbbb-0001-0001-0001-000000000004',
   'lucia.palomino@bbva.pe', 'Lucía', 'Palomino Ríos', 'ejecutivo'),

  ('bbbbbbbb-0001-0001-0001-000000000005',
   'david.asto@bbva.pe', 'David', 'Asto Huamán', 'ejecutivo');

-- Clientes (20) — Perfiles andinos realistas
INSERT INTO public.usuarios_app
  (id, email, nombre, apellido, rol)
VALUES
  ('cccccccc-0001-0001-0001-000000000001',
   'rosa.condori@gmail.com',    'Rosa',     'Condori Mamani',  'cliente'),
  ('cccccccc-0001-0001-0001-000000000002',
   'juan.huanca@gmail.com',     'Juan',     'Huanca Quispe',   'cliente'),
  ('cccccccc-0001-0001-0001-000000000003',
   'maria.paucar@gmail.com',    'María',    'Paucar Flores',   'cliente'),
  ('cccccccc-0001-0001-0001-000000000004',
   'pedro.asto@gmail.com',      'Pedro',    'Asto Ccanto',     'cliente'),
  ('cccccccc-0001-0001-0001-000000000005',
   'luz.ccari@gmail.com',       'Luz',      'Ccari Huamán',    'cliente'),
  ('cccccccc-0001-0001-0001-000000000006',
   'efrain.ramos@gmail.com',    'Efraín',   'Ramos Taipe',     'cliente'),
  ('cccccccc-0001-0001-0001-000000000007',
   'flora.ayala@gmail.com',     'Flora',    'Ayala Lazo',      'cliente'),
  ('cccccccc-0001-0001-0001-000000000008',
   'clemente.yali@gmail.com',   'Clemente', 'Yali Quispe',     'cliente'),
  ('cccccccc-0001-0001-0001-000000000009',
   'elvira.sulca@gmail.com',    'Elvira',   'Sulca Condezo',   'cliente'),
  ('cccccccc-0001-0001-0001-000000000010',
   'wilmer.ore@gmail.com',      'Wilmer',   'Ore Cuadros',     'cliente'),
  ('cccccccc-0001-0001-0001-000000000011',
   'nelly.zuñiga@gmail.com',    'Nelly',    'Zuñiga Pozo',     'cliente'),
  ('cccccccc-0001-0001-0001-000000000012',
   'santos.meza@gmail.com',     'Santos',   'Meza Palian',     'cliente'),
  ('cccccccc-0001-0001-0001-000000000013',
   'olinda.taipe@gmail.com',    'Olinda',   'Taipe Cóndor',    'cliente'),
  ('cccccccc-0001-0001-0001-000000000014',
   'teofilo.ccente@gmail.com',  'Teófilo',  'Ccente Huayta',   'cliente'),
  ('cccccccc-0001-0001-0001-000000000015',
   'maxima.rojas@gmail.com',    'Máxima',   'Rojas Tello',     'cliente'),
  ('cccccccc-0001-0001-0001-000000000016',
   'victor.huari@gmail.com',    'Víctor',   'Huari Limaylla',  'cliente'),
  ('cccccccc-0001-0001-0001-000000000017',
   'gladys.pumacayo@gmail.com', 'Gladys',   'Pumacayo Soto',   'cliente'),
  ('cccccccc-0001-0001-0001-000000000018',
   'cirilo.chávez@gmail.com',   'Cirilo',   'Chávez Pariona',  'cliente'),
  ('cccccccc-0001-0001-0001-000000000019',
   'hermelinda.llanos@gmail.com','Hermelinda','Llanos Matos',  'cliente'),
  ('cccccccc-0001-0001-0001-000000000020',
   'agustin.salcedo@gmail.com', 'Agustín',  'Salcedo Hinostroza','cliente');

-- ============================================================
-- 3. EJECUTIVOS DE NEGOCIO BBVA
-- ============================================================
INSERT INTO public.ejecutivos_negocio
  (id, user_id, sucursal_id, codigo_ejecutivo, especialidad,
   zona_asignada, meta_visitas_mes, meta_creditos_mes, meta_monto_mes)
VALUES
  ('dddddddd-0001-0001-0001-000000000001',
   'bbbbbbbb-0001-0001-0001-000000000002',
   'aaaaaaaa-0001-0001-0001-000000000001',
   'EJE-001', 'microempresa',
   'Huancayo centro, Cercado, San Carlos',
   80, 25, 200000),

  ('dddddddd-0001-0001-0001-000000000002',
   'bbbbbbbb-0001-0001-0001-000000000003',
   'aaaaaaaa-0001-0001-0001-000000000002',
   'EJE-002', 'microempresa',
   'El Tambo, Huancán, Pilcomayo',
   80, 25, 200000),

  ('dddddddd-0001-0001-0001-000000000003',
   'bbbbbbbb-0001-0001-0001-000000000004',
   'aaaaaaaa-0001-0001-0001-000000000003',
   'EJE-003', 'agropecuario',
   'Chilca, Sicaya, Orcotuna',
   60, 18, 150000),

  ('dddddddd-0001-0001-0001-000000000004',
   'bbbbbbbb-0001-0001-0001-000000000005',
   'aaaaaaaa-0001-0001-0001-000000000004',
   'EJE-004', 'agropecuario',
   'Chupaca, Ahuac, Chongos Bajo',
   60, 18, 120000);

-- ============================================================
-- 4. PERFILES DE CLIENTES BBVA
-- ============================================================
INSERT INTO public.perfiles_clientes
  (user_id, nombres, apellidos, tipo_negocio, antiguedad_negocio,
   local_propio, zona_negocio, ingreso_mensual_est,
   gasto_mensual_est, deuda_actual, entidades_deuda, estado_cliente)
VALUES
  -- Segmento A-B (BBVA Premium / Oro)
  ('cccccccc-0001-0001-0001-000000000001',
   'Rosa','Condori Mamani','bodega',48,TRUE,'urbano',3500,1800,5000,1,'activo'),

  ('cccccccc-0001-0001-0001-000000000002',
   'Juan','Huanca Quispe','ferreteria',72,TRUE,'urbano',7200,3500,15000,2,'activo'),

  ('cccccccc-0001-0001-0001-000000000003',
   'María','Paucar Flores','restaurante',36,TRUE,'urbano',4800,2500,8000,1,'activo'),

  ('cccccccc-0001-0001-0001-000000000004',
   'Pedro','Asto Ccanto','transporte',60,FALSE,'periurbano',5500,2800,12000,2,'activo'),

  ('cccccccc-0001-0001-0001-000000000005',
   'Luz','Ccari Huamán','confecciones',30,TRUE,'urbano',3200,1600,4000,1,'activo'),

  -- Segmento B-C (BBVA Plata)
  ('cccccccc-0001-0001-0001-000000000006',
   'Efraín','Ramos Taipe','agro',84,TRUE,'rural',4500,2200,20000,3,'activo'),

  ('cccccccc-0001-0001-0001-000000000007',
   'Flora','Ayala Lazo','bodega',24,FALSE,'periurbano',2800,1700,6000,2,'activo'),

  ('cccccccc-0001-0001-0001-000000000008',
   'Clemente','Yali Quispe','agro',96,TRUE,'rural',6000,3000,18000,2,'activo'),

  ('cccccccc-0001-0001-0001-000000000009',
   'Elvira','Sulca Condezo','comercio',18,FALSE,'periurbano',2500,1500,5000,2,'activo'),

  ('cccccccc-0001-0001-0001-000000000010',
   'Wilmer','Ore Cuadros','taller',42,TRUE,'periurbano',4200,2100,10000,1,'activo'),

  -- Segmento C-D (BBVA Bronce / Riesgo)
  ('cccccccc-0001-0001-0001-000000000011',
   'Nelly','Zuñiga Pozo','bodega',12,FALSE,'periurbano',1900,1400,8000,3,'activo'),

  ('cccccccc-0001-0001-0001-000000000012',
   'Santos','Meza Palian','agro',24,FALSE,'rural',3000,2000,15000,4,'activo'),

  ('cccccccc-0001-0001-0001-000000000013',
   'Olinda','Taipe Cóndor','comercio',8,FALSE,'rural',2200,1800,10000,3,'prospecto'),

  ('cccccccc-0001-0001-0001-000000000014',
   'Teófilo','Ccente Huayta','taller',15,FALSE,'periurbano',2600,2000,12000,3,'activo'),

  ('cccccccc-0001-0001-0001-000000000015',
   'Máxima','Rojas Tello','confecciones',6,FALSE,'rural',1800,1400,5000,2,'prospecto'),

  -- Prospectos nuevos BBVA
  ('cccccccc-0001-0001-0001-000000000016',
   'Víctor','Huari Limaylla','ferreteria',36,TRUE,'urbano',5800,2800,0,0,'prospecto'),

  ('cccccccc-0001-0001-0001-000000000017',
   'Gladys','Pumacayo Soto','restaurante',24,TRUE,'urbano',4200,2100,0,0,'prospecto'),

  ('cccccccc-0001-0001-0001-000000000018',
   'Cirilo','Chávez Pariona','agro',48,TRUE,'rural',3800,1900,0,0,'prospecto'),

  ('cccccccc-0001-0001-0001-000000000019',
   'Hermelinda','Llanos Matos','bodega',30,FALSE,'periurbano',2900,1700,0,0,'prospecto'),

  ('cccccccc-0001-0001-0001-000000000020',
   'Agustín','Salcedo Hinostroza','transporte',60,TRUE,'periurbano',6500,3200,8000,1,'activo');

-- ============================================================
-- 5. MOVIMIENTOS MENSUALES — 6 meses
-- ============================================================

-- Cliente 1 — Rosa Condori
INSERT INTO public.movimientos_mensuales
  (user_id, periodo, total_creditos, total_debitos,
   saldo_promedio, num_transacciones, num_pagos_puntual, num_pagos_tardio)
SELECT
  'cccccccc-0001-0001-0001-000000000001',
  TO_CHAR(NOW() - (n || ' months')::INTERVAL, 'YYYY-MM'),
  3500 + (random()*500)::INT, 1800 + (random()*300)::INT,
  1200 + (random()*400)::INT, 18 + (random()*6)::INT, 3, 0
FROM generate_series(1,6) n;

-- Cliente 2 — Juan Huanca
INSERT INTO public.movimientos_mensuales
  (user_id, periodo, total_creditos, total_debitos,
   saldo_promedio, num_transacciones, num_pagos_puntual, num_pagos_tardio)
SELECT
  'cccccccc-0001-0001-0001-000000000002',
  TO_CHAR(NOW() - (n || ' months')::INTERVAL, 'YYYY-MM'),
  7000 + (random()*1000)::INT, 3500 + (random()*500)::INT,
  3500 + (random()*800)::INT, 28 + (random()*8)::INT, 4, 0
FROM generate_series(1,6) n;

-- Cliente 3 — María Paucar
INSERT INTO public.movimientos_mensuales
  (user_id, periodo, total_creditos, total_debitos,
   saldo_promedio, num_transacciones, num_pagos_puntual, num_pagos_tardio)
SELECT
  'cccccccc-0001-0001-0001-000000000003',
  TO_CHAR(NOW() - (n || ' months')::INTERVAL, 'YYYY-MM'),
  4800 + (random()*600)::INT, 2500 + (random()*400)::INT,
  2100 + (random()*500)::INT, 22 + (random()*6)::INT, 3, 0
FROM generate_series(1,6) n;

-- Cliente 4 — Pedro Asto
INSERT INTO public.movimientos_mensuales
  (user_id, periodo, total_creditos, total_debitos,
   saldo_promedio, num_transacciones, num_pagos_puntual, num_pagos_tardio)
SELECT
  'cccccccc-0001-0001-0001-000000000004',
  TO_CHAR(NOW() - (n || ' months')::INTERVAL, 'YYYY-MM'),
  5500 + (random()*800)::INT, 2800 + (random()*400)::INT,
  2500 + (random()*600)::INT, 20 + (random()*5)::INT, 3, 1
FROM generate_series(1,6) n;

-- Cliente 5 — Luz Ccari
INSERT INTO public.movimientos_mensuales
  (user_id, periodo, total_creditos, total_debitos,
   saldo_promedio, num_transacciones, num_pagos_puntual, num_pagos_tardio)
SELECT
  'cccccccc-0001-0001-0001-000000000005',
  TO_CHAR(NOW() - (n || ' months')::INTERVAL, 'YYYY-MM'),
  3200 + (random()*400)::INT, 1600 + (random()*300)::INT,
  1400 + (random()*300)::INT, 16 + (random()*4)::INT, 3, 0
FROM generate_series(1,6) n;

-- Clientes 6-10: perfil medio
INSERT INTO public.movimientos_mensuales
  (user_id, periodo, total_creditos, total_debitos,
   saldo_promedio, num_transacciones, num_pagos_puntual, num_pagos_tardio)
SELECT uid::UUID,
  TO_CHAR(NOW() - (n || ' months')::INTERVAL, 'YYYY-MM'),
  cred + (random()*400)::INT, deb + (random()*300)::INT,
  saldo + (random()*300)::INT, 15 + (random()*5)::INT, punt, tard
FROM generate_series(1,6) n
CROSS JOIN (
  SELECT 'cccccccc-0001-0001-0001-000000000006'::TEXT AS uid, 4500 AS cred, 2200 AS deb, 1500 AS saldo, 2 AS punt, 1 AS tard
  UNION ALL SELECT 'cccccccc-0001-0001-0001-000000000007', 2800, 1700,  800, 2, 1
  UNION ALL SELECT 'cccccccc-0001-0001-0001-000000000008', 6000, 3000, 2000, 3, 1
  UNION ALL SELECT 'cccccccc-0001-0001-0001-000000000009', 2500, 1500,  700, 1, 2
  UNION ALL SELECT 'cccccccc-0001-0001-0001-000000000010', 4200, 2100, 1600, 2, 1
) AS u;

-- Clientes 11-15: historial irregular
INSERT INTO public.movimientos_mensuales
  (user_id, periodo, total_creditos, total_debitos,
   saldo_promedio, num_transacciones, num_pagos_puntual, num_pagos_tardio)
SELECT uid::UUID,
  TO_CHAR(NOW() - (n || ' months')::INTERVAL, 'YYYY-MM'),
  cred + (random()*300)::INT, deb + (random()*400)::INT,
  saldo + (random()*200)::INT, 10 + (random()*4)::INT, punt, tard
FROM generate_series(1,6) n
CROSS JOIN (
  SELECT 'cccccccc-0001-0001-0001-000000000011'::TEXT AS uid, 1900 AS cred, 1400 AS deb, 300 AS saldo, 1 AS punt, 2 AS tard
  UNION ALL SELECT 'cccccccc-0001-0001-0001-000000000012', 3000, 2000, 700, 1, 2
  UNION ALL SELECT 'cccccccc-0001-0001-0001-000000000013', 2200, 1800, 400, 0, 3
  UNION ALL SELECT 'cccccccc-0001-0001-0001-000000000014', 2600, 2000, 500, 1, 2
  UNION ALL SELECT 'cccccccc-0001-0001-0001-000000000015', 1800, 1400, 250, 0, 3
) AS u;

-- ============================================================
-- 6. EJECUTAR SCORING para clientes 1-15
-- ============================================================
DO $$
DECLARE
  v_uid UUID;
  v_score NUMERIC(5,2);
BEGIN
  FOR v_uid IN (
    SELECT id FROM public.usuarios_app
    WHERE rol = 'cliente'
    AND id NOT IN (
      'cccccccc-0001-0001-0001-000000000016',
      'cccccccc-0001-0001-0001-000000000017',
      'cccccccc-0001-0001-0001-000000000018',
      'cccccccc-0001-0001-0001-000000000019'
    )
    ORDER BY email
  ) LOOP
    v_score := public.calcular_score_crediticio(v_uid);
    RAISE NOTICE 'Scoring BBVA ejecutado para %: score = %', v_uid, v_score;
  END LOOP;
END;
$$;

-- ============================================================
-- 7. FICHAS DE CAMPO — 10 visitas demo
-- ============================================================
INSERT INTO public.fichas_campo
  (id, ejecutivo_id, cliente_user_id,
   latitud, longitud, distrito, tipo_visita,
   negocio_nombre, negocio_rubro,
   ingreso_declarado, gasto_declarado,
   estado_ficha, monto_solicitado, observaciones, creada_offline)
VALUES
  ('eeeeeeee-0001-0001-0001-000000000001',
   'bbbbbbbb-0001-0001-0001-000000000002',
   'cccccccc-0001-0001-0001-000000000001',
   -12.0653, -75.2049, 'Huancayo', 'renovacion',
   'Bodega Rosita', 'bodega', 3500, 1800,
   'completada', 8000,
   'Cliente solicita ampliación Crédito Negocios BBVA para campaña escolar', FALSE),

  ('eeeeeeee-0001-0001-0001-000000000002',
   'bbbbbbbb-0001-0001-0001-000000000002',
   'cccccccc-0001-0001-0001-000000000002',
   -12.0651, -75.2045, 'Huancayo', 'renovacion',
   'Ferretería Huanca', 'ferreteria', 7200, 3500,
   'completada', 25000,
   'Renovación BBVA con ampliación. Nuevo local en El Tambo.', FALSE),

  ('eeeeeeee-0001-0001-0001-000000000003',
   'bbbbbbbb-0001-0001-0001-000000000003',
   'cccccccc-0001-0001-0001-000000000004',
   -12.0445, -75.2112, 'El Tambo', 'seguimiento',
   'Transporte Asto', 'transporte', 5500, 2800,
   'completada', 15000,
   'Ampliación de flota con Crédito Efectivo BBVA. Cuota al día.', FALSE),

  ('eeeeeeee-0001-0001-0001-000000000004',
   'bbbbbbbb-0001-0001-0001-000000000003',
   'cccccccc-0001-0001-0001-000000000007',
   -12.0450, -75.2118, 'El Tambo', 'prospeccion',
   'Bodega Flora', 'bodega', 2800, 1700,
   'completada', 5000,
   'Primera visita. Muestra interés en Crédito Negocios BBVA.', TRUE),

  ('eeeeeeee-0001-0001-0001-000000000005',
   'bbbbbbbb-0001-0001-0001-000000000004',
   'cccccccc-0001-0001-0001-000000000006',
   -12.0820, -75.2120, 'Chilca', 'renovacion',
   'Agropecuaria Ramos', 'agro', 4500, 2200,
   'completada', 18000,
   'Campaña papa. Solicita Crédito Agropecuario BBVA para fertilizantes.', FALSE),

  ('eeeeeeee-0001-0001-0001-000000000006',
   'bbbbbbbb-0001-0001-0001-000000000005',
   'cccccccc-0001-0001-0001-000000000008',
   -12.0580, -75.2860, 'Chupaca', 'renovacion',
   'Granja Yali', 'agro', 6000, 3000,
   'completada', 22000,
   'Ampliación crianza de cuyes con BBVA. Mercado en Huancayo.', FALSE),

  -- Fichas offline
  ('eeeeeeee-0001-0001-0001-000000000007',
   'bbbbbbbb-0001-0001-0001-000000000004',
   'cccccccc-0001-0001-0001-000000000018',
   -11.9153, -75.3142, 'Concepción', 'prospeccion',
   'Chacra Chávez', 'agro', 3800, 1900,
   'sincronizada', 12000,
   'Zona rural sin señal. Datos offline BBVA, sync al regresar.', TRUE),

  ('eeeeeeee-0001-0001-0001-000000000008',
   'bbbbbbbb-0001-0001-0001-000000000005',
   'cccccccc-0001-0001-0001-000000000012',
   -12.0580, -75.2870, 'Chupaca', 'cobranza',
   'Parcela Meza', 'agro', 3000, 2000,
   'completada', 0,
   'Visita de cobranza BBVA. Acuerdo de pago en cuotas.', FALSE),

  -- Ficha de prospecto sin user_id
  ('eeeeeeee-0001-0001-0001-000000000009',
   'bbbbbbbb-0001-0001-0001-000000000002',
   NULL,
   -12.0660, -75.2055, 'Huancayo', 'prospeccion',
   'Librería Central', 'comercio', 4500, 2200,
   'borrador', 10000,
   'Prospecto BBVA nuevo. DNI pendiente de verificar.', FALSE),

  ('eeeeeeee-0001-0001-0001-000000000010',
   'bbbbbbbb-0001-0001-0001-000000000003',
   'cccccccc-0001-0001-0001-000000000020',
   -12.0445, -75.2100, 'El Tambo', 'renovacion',
   'Transporte Salcedo', 'transporte', 6500, 3200,
   'completada', 20000,
   'Tercer crédito BBVA. Historial impecable. Ampliación de flota.', FALSE);

-- Sincronización para fichas offline
UPDATE public.fichas_campo
   SET sincronizada_at = NOW() - INTERVAL '2 hours'
 WHERE creada_offline = TRUE
   AND estado_ficha = 'sincronizada';

-- ============================================================
-- 8. RUTAS PLANIFICADAS — Día de hoy
-- ============================================================
INSERT INTO public.rutas_planificadas
  (ejecutivo_id, fecha_ruta, cliente_user_id,
   latitud_cliente, longitud_cliente, referencia_dir,
   tipo_visita, monto_estimado, hora_sugerida,
   estado, cargado_automatico)
VALUES
  -- Ruta de Jessica (EJE-001) — hoy
  ('dddddddd-0001-0001-0001-000000000001', CURRENT_DATE,
   'cccccccc-0001-0001-0001-000000000001',
   -12.0653, -75.2049, 'Mercado Modelo, puesto 14 - Jr. Puno',
   'renovacion', 8000, '08:30', 'pendiente', TRUE),

  ('dddddddd-0001-0001-0001-000000000001', CURRENT_DATE,
   'cccccccc-0001-0001-0001-000000000003',
   -12.0658, -75.2052, 'Av. Huancavelica frente a bodega el sol',
   'renovacion', 12000, '10:00', 'pendiente', TRUE),

  ('dddddddd-0001-0001-0001-000000000001', CURRENT_DATE,
   'cccccccc-0001-0001-0001-000000000005',
   -12.0645, -75.2041, 'Jr. Loreto 240, tienda esquina',
   'seguimiento', 6000, '11:30', 'pendiente', TRUE),

  -- Ruta de Mario (EJE-002) — hoy
  ('dddddddd-0001-0001-0001-000000000002', CURRENT_DATE,
   'cccccccc-0001-0001-0001-000000000004',
   -12.0445, -75.2112, 'Terminal El Tambo, paradero 3',
   'renovacion', 15000, '08:00', 'visitado', TRUE),

  ('dddddddd-0001-0001-0001-000000000002', CURRENT_DATE,
   'cccccccc-0001-0001-0001-000000000010',
   -12.0450, -75.2108, 'Av. Ferrocarril 890, taller mecánico',
   'prospeccion', 9000, '10:00', 'pendiente', TRUE),

  -- Ruta de Lucía (EJE-003) — hoy
  ('dddddddd-0001-0001-0001-000000000003', CURRENT_DATE,
   'cccccccc-0001-0001-0001-000000000006',
   -12.0820, -75.2120, 'Comunidad Huayucachi — chacra entrada por puente',
   'renovacion', 18000, '07:30', 'visitado', TRUE),

  ('dddddddd-0001-0001-0001-000000000003', CURRENT_DATE,
   'cccccccc-0001-0001-0001-000000000008',
   -12.0580, -75.2860, 'Carretera Chupaca km 3.5 — granja cuyes',
   'renovacion', 22000, '09:30', 'pendiente', TRUE);

-- Marcar primera visita de Mario como visitada
UPDATE public.rutas_planificadas
   SET estado = 'visitado',
       ficha_generada_id = 'eeeeeeee-0001-0001-0001-000000000003'
 WHERE ejecutivo_id = 'dddddddd-0001-0001-0001-000000000002'
   AND cliente_user_id = 'cccccccc-0001-0001-0001-000000000004';

-- ============================================================
-- 9. METAS DEL MES
-- ============================================================
INSERT INTO public.metas_ejecutivos
  (ejecutivo_id, periodo,
   meta_visitas, meta_creditos, meta_monto,
   real_visitas, real_creditos, real_monto)
VALUES
  ('dddddddd-0001-0001-0001-000000000001',
   TO_CHAR(NOW(), 'YYYY-MM'), 80, 25, 200000, 52, 16, 132000),
  ('dddddddd-0001-0001-0001-000000000002',
   TO_CHAR(NOW(), 'YYYY-MM'), 80, 25, 200000, 61, 19, 158000),
  ('dddddddd-0001-0001-0001-000000000003',
   TO_CHAR(NOW(), 'YYYY-MM'), 60, 18, 150000, 44, 13, 98000),
  ('dddddddd-0001-0001-0001-000000000004',
   TO_CHAR(NOW(), 'YYYY-MM'), 60, 18, 120000, 38, 11, 82000);

-- Sincronizar métricas en ejecutivos_negocio
UPDATE public.ejecutivos_negocio en
   SET visitas_mes_actual  = me.real_visitas,
       creditos_mes_actual = me.real_creditos,
       monto_mes_actual    = me.real_monto
  FROM public.metas_ejecutivos me
 WHERE me.ejecutivo_id = en.id
   AND me.periodo = TO_CHAR(NOW(), 'YYYY-MM');

-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SELECT
  'usuarios_app'              AS tabla, COUNT(*) AS registros FROM public.usuarios_app
UNION ALL SELECT 'sucursales_bbva',       COUNT(*) FROM public.sucursales_bbva
UNION ALL SELECT 'ejecutivos_negocio',    COUNT(*) FROM public.ejecutivos_negocio
UNION ALL SELECT 'perfiles_clientes',     COUNT(*) FROM public.perfiles_clientes
UNION ALL SELECT 'movimientos_mensuales', COUNT(*) FROM public.movimientos_mensuales
UNION ALL SELECT 'features_scoring',      COUNT(*) FROM public.features_scoring
UNION ALL SELECT 'scores_crediticios',    COUNT(*) FROM public.scores_crediticios
UNION ALL SELECT 'fichas_campo',          COUNT(*) FROM public.fichas_campo
UNION ALL SELECT 'rutas_planificadas',    COUNT(*) FROM public.rutas_planificadas
UNION ALL SELECT 'metas_ejecutivos',      COUNT(*) FROM public.metas_ejecutivos
ORDER BY tabla;

-- Vista rápida: scores generados
SELECT
  pc.nombres || ' ' || pc.apellidos AS cliente,
  pc.tipo_negocio, pc.zona_negocio,
  sc.score, sc.segmento, sc.recomendacion,
  sc.monto_max_sugerido
FROM public.scores_crediticios sc
JOIN public.perfiles_clientes pc ON pc.user_id = sc.user_id
ORDER BY sc.score DESC;

-- ============================================================
-- FIN — 03_seed_demo_bbva.sql · v1.0
-- Siguiente: ejecutar 04_test_queries_bbva.sql
-- ============================================================
