-- ============================================================
-- SCRIPT 14 — Seed 30 Casos de Solicitudes de Crédito
-- App Móvil BBVA Fuerza de Ventas + App Clientes v2.0
-- ============================================================
-- Propósito: Insertar 30 solicitudes pre-asignadas a asesores
-- por agencia para prueba integral del flujo completo.
-- Estado inicial: 'enviado' (aparecen en Tablero del asesor)
-- ============================================================

-- Clean previous runs of this same seed
DELETE FROM public.sync_outbox WHERE solicitud_id IN (
  SELECT id FROM public.solicitudes_credito
  WHERE numero_expediente LIKE 'EXP-30C-%'
);
DELETE FROM public.solicitudes_credito
WHERE numero_expediente LIKE 'EXP-30C-%';

-- ============================================================
-- UUIDs fijos para esta seed
-- Solicitud IDs: bbbbbbbb-0030-00NN-0001-0000000000NN
-- ============================================================

INSERT INTO public.solicitudes_credito (
  id, numero_expediente, asesor_id, cliente_id, agencia_id,
  destino_credito, monto_solicitado, plazo_meses,
  moneda, tipo_cuota, garantia,
  cuota_estimada, tea_referencial,
  estado, canal, con_seguro
)
VALUES
-- Caso 01 - Anaximandro Quispe - S/1,000 - 12m - 43.92% - Sin seguro - Sin garantía - Capital de trabajo - HYX-02 (Mario)
('bbbbbbbb-0030-0001-0001-000000000001','EXP-30C-001',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000001','aaaaaaaa-0001-0001-0001-000000000002',
 'Capital de trabajo',1000,12,
 'PEN','mensual','sin_garantia',
 100.95,43.92,
 'enviado','cliente',FALSE),

-- Caso 02 - Eulalia Mamani - S/3,000 - 12m - 40.92% - Con seguro - Sin garantía - Compra cocina industrial - HYX-03 (Lucía)
('bbbbbbbb-0030-0002-0001-000000000002','EXP-30C-002',
 'dddddddd-0001-0001-0001-000000000003','cccccccc-0002-0001-0001-000000000002','aaaaaaaa-0001-0001-0001-000000000003',
 'Compra cocina industrial',3000,12,
 'PEN','mensual','sin_garantia',
 299.59,40.92,
 'enviado','cliente',TRUE),

-- Caso 03 - Teófilo Huamán - S/5,000 - 18m - 43.92% - Sin seguro - Sin garantía - Maquinaria - HYX-02 (Mario)
('bbbbbbbb-0030-0003-0001-000000000003','EXP-30C-003',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000003','aaaaaaaa-0001-0001-0001-000000000002',
 'Maquinaria',5000,18,
 'PEN','mensual','sin_garantia',
 366.02,43.92,
 'enviado','cliente',FALSE),

-- Caso 04 - Casandra Flores - S/8,000 - 6m - 43.92% - Sin seguro - Sin garantía - Reposición stock - HYX-01 (Jessica)
('bbbbbbbb-0030-0004-0001-000000000004','EXP-30C-004',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000004','aaaaaaaa-0001-0001-0001-000000000001',
 'Reposición stock',8000,6,
 'PEN','mensual','sin_garantia',
 1480.73,43.92,
 'enviado','cliente',FALSE),

-- Caso 05 - Demóstenes Rojas - S/10,000 - 12m - 43.92% - Sin seguro - Hipotecaria - Ampliación local - HYX-01 (Jessica)
('bbbbbbbb-0030-0005-0001-000000000005','EXP-30C-005',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000005','aaaaaaaa-0001-0001-0001-000000000001',
 'Ampliación local',10000,12,
 'PEN','mensual','hipotecaria',
 1009.46,43.92,
 'enviado','cliente',FALSE),

-- Caso 06 - Hipatia Condori - S/12,000 - 24m - 40.92% - Con seguro - Hipotecaria - Máquinas remalladoras - HYX-02 (Mario)
('bbbbbbbb-0030-0006-0001-000000000006','EXP-30C-006',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000006','aaaaaaaa-0001-0001-0001-000000000002',
 'Máquinas remalladoras',12000,24,
 'PEN','mensual','hipotecaria',
 700.94,40.92,
 'enviado','cliente',TRUE),

-- Caso 07 - Aníbal Vargas - S/15,000 - 18m - 43.92% - Sin seguro - Vehicular - Cuota inicial vehículo - HYX-05 (Jessica)
('bbbbbbbb-0030-0007-0001-000000000007','EXP-30C-007',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000007','aaaaaaaa-0001-0001-0001-000000000005',
 'Cuota inicial vehículo',15000,18,
 'PEN','mensual','prendaria',
 1098.07,43.92,
 'enviado','cliente',FALSE),

-- Caso 08 - Penélope Apaza - S/18,000 - 24m - 43.92% - Sin seguro - Hipotecaria - Ampliación galpón - HYX-03 (Lucía)
('bbbbbbbb-0030-0008-0001-000000000008','EXP-30C-008',
 'dddddddd-0001-0001-0001-000000000003','cccccccc-0002-0001-0001-000000000008','aaaaaaaa-0001-0001-0001-000000000003',
 'Ampliación galpón',18000,24,
 'PEN','mensual','hipotecaria',
 1072.10,43.92,
 'enviado','cliente',FALSE),

-- Caso 09 - Heráclito Ccahua - S/20,000 - 36m - 43.92% - Sin seguro - Hipotecaria - Nueva sucursal - HYX-01 (Jessica)
('bbbbbbbb-0030-0009-0001-000000000009','EXP-30C-009',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000009','aaaaaaaa-0001-0001-0001-000000000001',
 'Nueva sucursal',20000,36,
 'PEN','mensual','hipotecaria',
 927.12,43.92,
 'enviado','cliente',FALSE),

-- Caso 10 - Cleopatra Soto - S/25,000 - 24m - 40.92% - Con seguro - Hipotecaria - Equipamiento farmacia - HYX-04 (David)
('bbbbbbbb-0030-0010-0001-000000000010','EXP-30C-010',
 'dddddddd-0001-0001-0001-000000000004','cccccccc-0002-0001-0001-000000000010','aaaaaaaa-0001-0001-0001-000000000004',
 'Equipamiento farmacia',25000,24,
 'PEN','mensual','hipotecaria',
 1460.29,40.92,
 'enviado','cliente',TRUE),

-- Caso 11 - Esquilo Ramos - S/2,000 - 12m - 43.92% - Sin seguro - Sin garantía - Compra congeladora - HYX-03 (Lucía)
('bbbbbbbb-0030-0011-0001-000000000011','EXP-30C-011',
 'dddddddd-0001-0001-0001-000000000003','cccccccc-0002-0001-0001-000000000011','aaaaaaaa-0001-0001-0001-000000000003',
 'Compra congeladora',2000,12,
 'PEN','mensual','sin_garantia',
 201.89,43.92,
 'enviado','cliente',FALSE),

-- Caso 12 - Ariadna Quispe - S/4,000 - 18m - 43.92% - Sin seguro - Sin garantía - Mobiliario salón - HYX-02 (Mario)
('bbbbbbbb-0030-0012-0001-000000000012','EXP-30C-012',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000012','aaaaaaaa-0001-0001-0001-000000000002',
 'Mobiliario salón',4000,18,
 'PEN','mensual','sin_garantia',
 292.82,43.92,
 'enviado','cliente',FALSE),

-- Caso 13 - Sócrates Huanca - S/6,000 - 12m - 40.92% - Con seguro - Sin garantía - Horno rotativo - HYX-03 (Lucía)
('bbbbbbbb-0030-0013-0001-000000000013','EXP-30C-013',
 'dddddddd-0001-0001-0001-000000000003','cccccccc-0002-0001-0001-000000000013','aaaaaaaa-0001-0001-0001-000000000003',
 'Horno rotativo',6000,12,
 'PEN','mensual','sin_garantia',
 599.17,40.92,
 'enviado','cliente',TRUE),

-- Caso 14 - Casiopea Torres - S/7,500 - 6m - 43.92% - Sin seguro - Sin garantía - Herramienta neumática - HYX-02 (Mario)
('bbbbbbbb-0030-0014-0001-000000000014','EXP-30C-014',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000014','aaaaaaaa-0001-0001-0001-000000000002',
 'Herramienta neumática',7500,6,
 'PEN','mensual','sin_garantia',
 1388.18,43.92,
 'enviado','cliente',FALSE),

-- Caso 15 - Aristófanes Cruz - S/9,000 - 24m - 43.92% - Sin seguro - Hipotecaria - Capital campaña agrícola - HYX-03 (Lucía)
('bbbbbbbb-0030-0015-0001-000000000015','EXP-30C-015',
 'dddddddd-0001-0001-0001-000000000003','cccccccc-0002-0001-0001-000000000015','aaaaaaaa-0001-0001-0001-000000000003',
 'Capital campaña agrícola',9000,24,
 'PEN','mensual','hipotecaria',
 536.05,43.92,
 'enviado','cliente',FALSE),

-- Caso 16 - Calipso Mendoza - S/11,000 - 18m - 40.92% - Con seguro - Hipotecaria - Cuero y maquinaria - HYX-01 (Jessica)
('bbbbbbbb-0030-0016-0001-000000000016','EXP-30C-016',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000016','aaaaaaaa-0001-0001-0001-000000000001',
 'Cuero y maquinaria',11000,18,
 'PEN','mensual','hipotecaria',
 793.03,40.92,
 'enviado','cliente',TRUE),

-- Caso 17 - Demetrio Quispe - S/13,500 - 12m - 43.92% - Sin seguro - Hipotecaria - Reposición inventario - HYX-05 (Jessica)
('bbbbbbbb-0030-0017-0001-000000000017','EXP-30C-017',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000017','aaaaaaaa-0001-0001-0001-000000000005',
 'Reposición inventario',13500,12,
 'PEN','mensual','hipotecaria',
 1362.77,43.92,
 'enviado','cliente',FALSE),

-- Caso 18 - Antígona Flores - S/16,000 - 36m - 43.92% - Sin seguro - Hipotecaria - Ampliación restaurante - HYX-05 (Jessica)
('bbbbbbbb-0030-0018-0001-000000000018','EXP-30C-018',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000018','aaaaaaaa-0001-0001-0001-000000000005',
 'Ampliación restaurante',16000,36,
 'PEN','mensual','hipotecaria',
 741.70,43.92,
 'enviado','cliente',FALSE),

-- Caso 19 - Pitágoras Rojas - S/17,000 - 24m - 40.92% - Con seguro - Hipotecaria - Stock estructural - HYX-02 (Mario)
('bbbbbbbb-0030-0019-0001-000000000019','EXP-30C-019',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000019','aaaaaaaa-0001-0001-0001-000000000002',
 'Stock estructural',17000,24,
 'PEN','mensual','hipotecaria',
 993.00,40.92,
 'enviado','cliente',TRUE),

-- Caso 20 - Berenice Apaza - S/19,000 - 18m - 43.92% - Sin seguro - Hipotecaria - Maquinaria tejido - HYX-02 (Mario)
('bbbbbbbb-0030-0020-0001-000000000020','EXP-30C-020',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000020','aaaaaaaa-0001-0001-0001-000000000002',
 'Maquinaria tejido',19000,18,
 'PEN','mensual','hipotecaria',
 1390.89,43.92,
 'enviado','cliente',FALSE),

-- Caso 21 - Anaxágoras Huamán - S/22,000 - 36m - 43.92% - Sin seguro - Vehicular - Cuota inicial camión - HYX-01 (Jessica)
('bbbbbbbb-0030-0021-0001-000000000021','EXP-30C-021',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000021','aaaaaaaa-0001-0001-0001-000000000001',
 'Cuota inicial camión',22000,36,
 'PEN','mensual','prendaria',
 1019.83,43.92,
 'enviado','cliente',FALSE),

-- Caso 22 - Climene Vargas - S/24,000 - 24m - 40.92% - Con seguro - Hipotecaria - Equipamiento planta - HYX-03 (Lucía)
('bbbbbbbb-0030-0022-0001-000000000022','EXP-30C-022',
 'dddddddd-0001-0001-0001-000000000003','cccccccc-0002-0001-0001-000000000022','aaaaaaaa-0001-0001-0001-000000000003',
 'Equipamiento planta',24000,24,
 'PEN','mensual','hipotecaria',
 1401.88,40.92,
 'enviado','cliente',TRUE),

-- Caso 23 - Epaminondas Soto - S/1,500 - 6m - 43.92% - Sin seguro - Sin garantía - Compra vitrinas - HYX-03 (Lucía)
('bbbbbbbb-0030-0023-0001-000000000023','EXP-30C-023',
 'dddddddd-0001-0001-0001-000000000003','cccccccc-0002-0001-0001-000000000023','aaaaaaaa-0001-0001-0001-000000000003',
 'Compra vitrinas',1500,6,
 'PEN','mensual','sin_garantia',
 277.64,43.92,
 'enviado','cliente',FALSE),

-- Caso 24 - Lisístrata Ramos - S/3,500 - 12m - 43.92% - Sin seguro - Sin garantía - Capital de trabajo - HYX-01 (Jessica)
('bbbbbbbb-0030-0024-0001-000000000024','EXP-30C-024',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000024','aaaaaaaa-0001-0001-0001-000000000001',
 'Capital de trabajo',3500,12,
 'PEN','mensual','sin_garantia',
 353.31,43.92,
 'enviado','cliente',FALSE),

-- Caso 25 - Filoctetes Cruz - S/11,000 - 18m - 40.92% - Con seguro - Sin garantía - Ampliación local nuevo - HYX-03 (Lucía)
('bbbbbbbb-0030-0025-0001-000000000025','EXP-30C-025',
 'dddddddd-0001-0001-0001-000000000003','cccccccc-0002-0001-0001-000000000025','aaaaaaaa-0001-0001-0001-000000000003',
 'Ampliación local nuevo',11000,18,
 'PEN','mensual','sin_garantia',
 793.03,40.92,
 'enviado','cliente',TRUE),

-- Caso 26 - Calirroe Mendoza - S/16,000 - 24m - 43.92% - Sin seguro - Hipotecaria - Maquinaria capacidad - HYX-02 (Mario)
('bbbbbbbb-0030-0026-0001-000000000026','EXP-30C-026',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000026','aaaaaaaa-0001-0001-0001-000000000002',
 'Maquinaria capacidad',16000,24,
 'PEN','mensual','hipotecaria',
 952.98,43.92,
 'enviado','cliente',FALSE),

-- Caso 27 - Tucídides Quispe - S/20,000 - 24m - 40.92% - Con seguro - Hipotecaria - Stock y montacarga - HYX-05 (Jessica)
('bbbbbbbb-0030-0027-0001-000000000027','EXP-30C-027',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000027','aaaaaaaa-0001-0001-0001-000000000005',
 'Stock y montacarga',20000,24,
 'PEN','mensual','hipotecaria',
 1168.23,40.92,
 'enviado','cliente',TRUE),

-- Caso 28 - Aquiles Mamani - S/15,000 - 24m - 43.92% - Sin seguro - Hipotecaria - Capital de trabajo - HYX-01 (Jessica)
('bbbbbbbb-0030-0028-0001-000000000028','EXP-30C-028',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000028','aaaaaaaa-0001-0001-0001-000000000001',
 'Capital de trabajo',15000,24,
 'PEN','mensual','hipotecaria',
 893.42,43.92,
 'enviado','cliente',FALSE),

-- Caso 29 - Medea Apaza - S/14,000 - 18m - 43.92% - Sin seguro - Sin garantía - Compra camioneta reparto - HYX-02 (Mario)
('bbbbbbbb-0030-0029-0001-000000000029','EXP-30C-029',
 'dddddddd-0001-0001-0001-000000000002','cccccccc-0002-0001-0001-000000000029','aaaaaaaa-0001-0001-0001-000000000002',
 'Compra camioneta reparto',14000,18,
 'PEN','mensual','sin_garantia',
 1024.87,43.92,
 'enviado','cliente',FALSE),

-- Caso 30 - Esquines Rojas - S/30,000 - 24m - 43.92% - Sin seguro - Vehicular - Compra unidad transporte - HYX-05 (Jessica)
('bbbbbbbb-0030-0030-0001-000000000030','EXP-30C-030',
 'dddddddd-0001-0001-0001-000000000001','cccccccc-0002-0001-0001-000000000030','aaaaaaaa-0001-0001-0001-000000000005',
 'Compra unidad transporte',30000,24,
 'PEN','mensual','prendaria',
 1786.83,43.92,
 'enviado','cliente',FALSE);

-- ============================================================
-- Sync Outbox: simular promoción al núcleo financiero
-- ============================================================
INSERT INTO public.sync_outbox (solicitud_id, tabla_destino, accion, payload_json, estado)
SELECT id, 'solicitudes_credito', 'INSERT',
  jsonb_build_object(
    'id', id,
    'numero_expediente', numero_expediente,
    'cliente_id', cliente_id,
    'monto_solicitado', monto_solicitado,
    'plazo_meses', plazo_meses,
    'estado', estado,
    'canal', canal
  ),
  'pendiente'
FROM public.solicitudes_credito
WHERE numero_expediente LIKE 'EXP-30C-%'
  AND id NOT IN (
    SELECT solicitud_id FROM public.sync_outbox WHERE solicitud_id IS NOT NULL
  );

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
SELECT 'solicitudes_credito' AS tabla, COUNT(*) AS total
FROM public.solicitudes_credito WHERE numero_expediente LIKE 'EXP-30C-%'
UNION ALL
SELECT 'sync_outbox', COUNT(*)
FROM public.sync_outbox
WHERE solicitud_id IN (
  SELECT id FROM public.solicitudes_credito WHERE numero_expediente LIKE 'EXP-30C-%'
);

-- ============================================================
-- FIN — 14_seed_solicitudes_30casos.sql
-- ============================================================
