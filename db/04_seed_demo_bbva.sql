-- ============================================================
-- SCRIPT 04 — Seed Demo BBVA v2.0 (Datos completos)
-- App Móvil BBVA Fuerza de Ventas · v2.0
-- ============================================================
-- EJECUTAR: 5to de 7
-- ============================================================

TRUNCATE public.solicitudes_notas_internas, public.alertas_cartera, public.acciones_cobranza,
  public.consultas_buro, public.solicitudes_documentos, public.solicitudes_credito,
  public.cartera_diaria, public.creditos_preaprobados, public.creditos,
  public.scores_crediticios, public.features_scoring, public.movimientos_mensuales,
  public.perfiles_clientes, public.clientes, public.asesores_negocio,
  public.agencias RESTART IDENTITY CASCADE;

-- ============================================================
-- AGENCIAS BBVA — Red Junín
-- ============================================================
INSERT INTO public.agencias (id, codigo, nombre, tipo, departamento, provincia, distrito, direccion, lat, lng, region)
VALUES
  ('aaaaaaaa-0001-0001-0001-000000000001','HYX-01','BBVA Huancayo Principal','agencia','Junín','Huancayo','Huancayo','Jr. Ancash 745, Huancayo',-12.0653,-75.2049,'Centro'),
  ('aaaaaaaa-0001-0001-0001-000000000002','HYX-02','BBVA El Tambo','agencia','Junín','Huancayo','El Tambo','Av. Ferrocarril 1250, El Tambo',-12.0445,-75.2112,'Centro'),
  ('aaaaaaaa-0001-0001-0001-000000000003','HYX-03','BBVA Chilca','agencia','Junín','Huancayo','Chilca','Jr. Lima 320, Chilca',-12.0820,-75.2120,'Centro'),
  ('aaaaaaaa-0001-0001-0001-000000000004','HYX-04','BBVA Chupaca','oficina_especial','Junín','Chupaca','Chupaca','Jr. Grau 180, Chupaca',-12.0580,-75.2860,'Centro'),
  ('aaaaaaaa-0001-0001-0001-000000000005','HYX-05','BBVA Concepción','ventanilla','Junín','Concepción','Concepción','Jr. 9 de Julio 410',-11.9153,-75.3142,'Centro');

-- ============================================================
-- ASESORES NEGOCIO (Ejecutivos BBVA)
-- ============================================================
INSERT INTO public.asesores_negocio (id, codigo_empleado, nombres, apellidos, email, agencia_id, especialidad, perfil, zona_asignada, meta_visitas_mes, meta_creditos_mes, meta_monto_mes)
VALUES
  ('dddddddd-0001-0001-0001-000000000001','EJE-001','Jessica','Quispe Huanca','jessica.quispe@bbva.pe','aaaaaaaa-0001-0001-0001-000000000001','microempresa','operador','Huancayo centro, Cercado',80,25,200000),
  ('dddddddd-0001-0001-0001-000000000002','EJE-002','Mario','Ccanto Paucar','mario.ccanto@bbva.pe','aaaaaaaa-0001-0001-0001-000000000002','microempresa','operador','El Tambo, Huancán',80,25,200000),
  ('dddddddd-0001-0001-0001-000000000003','EJE-003','Lucía','Palomino Ríos','lucia.palomino@bbva.pe','aaaaaaaa-0001-0001-0001-000000000003','agropecuario','super_operador','Chilca, Sicaya, Orcotuna',60,18,150000),
  ('dddddddd-0001-0001-0001-000000000004','EJE-004','David','Asto Huamán','david.asto@bbva.pe','aaaaaaaa-0001-0001-0001-000000000004','agropecuario','supervisor','Chupaca, Ahuac',60,18,120000);

-- Admin asesor virtual
INSERT INTO public.asesores_negocio (id, codigo_empleado, nombres, apellidos, email, agencia_id, especialidad, perfil)
VALUES ('dddddddd-0001-0001-0001-000000000005','ADM-001','Carlos','Mendoza','admin@bbva.pe','aaaaaaaa-0001-0001-0001-000000000001','microempresa','administrador');

-- ============================================================
-- CLIENTES BBVA
-- ============================================================
INSERT INTO public.clientes (id, numero_documento, tipo_documento, nombres, apellidos, fecha_nacimiento, estado_civil, telefono, tipo_negocio, nombre_negocio, antiguedad_negocio_meses, ingresos_estimados, gastos_mensuales, deuda_actual, entidades_deuda, calificacion_sbs, estado_cliente, lat, lng)
VALUES
  ('cccccccc-0001-0001-0001-000000000001','20123456','DNI','Rosa','Condori Mamani','1985-03-15','Casado','964123456','bodega','Bodega Rosita',48,3500,1800,5000,1,'Normal','activo',-12.0653,-75.2049),
  ('cccccccc-0001-0001-0001-000000000002','20234567','DNI','Juan','Huanca Quispe','1978-07-22','Casado','964234567','ferreteria','Ferretería Huanca',72,7200,3500,15000,2,'Normal','activo',-12.0651,-75.2045),
  ('cccccccc-0001-0001-0001-000000000003','20345678','DNI','María','Paucar Flores','1990-11-08','Soltero','964345678','restaurante','Restaurante Paucar',36,4800,2500,8000,1,'Normal','activo',-12.0658,-75.2052),
  ('cccccccc-0001-0001-0001-000000000004','20456789','DNI','Pedro','Asto Ccanto','1982-05-30','Conviviente','964456789','transporte','Transporte Asto',60,5500,2800,12000,2,'Normal','activo',-12.0445,-75.2112),
  ('cccccccc-0001-0001-0001-000000000005','20567890','DNI','Luz','Ccari Huamán','1995-09-12','Soltero','964567890','confecciones','Confecciones Ccari',30,3200,1600,4000,1,'Normal','activo',-12.0645,-75.2041),
  ('cccccccc-0001-0001-0001-000000000006','20678901','DNI','Efraín','Ramos Taipe','1975-01-20','Casado','964678901','agro','Agropecuaria Ramos',84,4500,2200,20000,3,'CPP','activo',-12.0820,-75.2120),
  ('cccccccc-0001-0001-0001-000000000007','20789012','DNI','Flora','Ayala Lazo','1992-04-18','Conviviente','964789012','bodega','Bodega Flora',24,2800,1700,6000,2,'Normal','activo',-12.0450,-75.2118),
  ('cccccccc-0001-0001-0001-000000000008','20890123','DNI','Clemente','Yali Quispe','1970-08-14','Casado','964890123','agro','Granja Yali',96,6000,3000,18000,2,'Normal','activo',-12.0580,-75.2860),
  ('cccccccc-0001-0001-0001-000000000009','20901234','DNI','Elvira','Sulca Condezo','1988-12-25','Divorciado','964901234','comercio','Tienda Sulca',18,2500,1500,5000,2,'Normal','activo',-12.0455,-75.2105),
  ('cccccccc-0001-0001-0001-000000000010','21012345','DNI','Wilmer','Ore Cuadros','1980-06-03','Casado','965012345','taller','Taller Mecánico Ore',42,4200,2100,10000,1,'Normal','activo',-12.0450,-75.2108),
  ('cccccccc-0001-0001-0001-000000000011','21123456','DNI','Nelly','Zuñiga Pozo','1993-02-28','Conviviente','965123456','bodega','Bodega Zuñiga',12,1900,1400,8000,3,'Deficiente','activo',-12.0660,-75.2055),
  ('cccccccc-0001-0001-0001-000000000012','21234567','DNI','Santos','Meza Palian','1976-10-10','Casado','965234567','agro','Parcela Meza',24,3000,2000,15000,4,'Dudoso','activo',-12.0580,-75.2870),
  ('cccccccc-0001-0001-0001-000000000013','21345678','DNI','Olinda','Taipe Cóndor','1987-07-07','Casado','965345678','comercio','Puesto Taipe',8,2200,1800,10000,3,'CPP','prospecto',-12.0585,-75.2855),
  ('cccccccc-0001-0001-0001-000000000014','21456789','DNI','Teófilo','Ccente Huayta','1979-04-15','Casado','965456789','taller','Taller Ccente',15,2600,2000,12000,3,'Deficiente','activo',-12.0440,-75.2100),
  ('cccccccc-0001-0001-0001-000000000015','21567890','DNI','Máxima','Rojas Tello','1996-01-30','Soltero','965567890','confecciones','Ropa Rojas',6,1800,1400,5000,2,'CPP','prospecto',-12.0640,-75.2030),
  ('cccccccc-0001-0001-0001-000000000016','21678901','DNI','Víctor','Huari Limaylla','1984-09-19','Casado','965678901','ferreteria','Ferretería Huari',36,5800,2800,0,0,'Sin_Historial','prospecto',-12.0665,-75.2060),
  ('cccccccc-0001-0001-0001-000000000017','21789012','DNI','Gladys','Pumacayo Soto','1991-05-25','Conviviente','965789012','restaurante','Restaurante Pumacayo',24,4200,2100,0,0,'Sin_Historial','prospecto',-12.0460,-75.2110),
  ('cccccccc-0001-0001-0001-000000000018','21890123','DNI','Cirilo','Chávez Pariona','1974-12-12','Casado','965890123','agro','Chacra Chávez',48,3800,1900,0,0,'Sin_Historial','prospecto',-11.9153,-75.3142),
  ('cccccccc-0001-0001-0001-000000000019','21901234','DNI','Hermelinda','Llanos Matos','1986-08-22','Viudo','965901234','bodega','Bodega Llanos',30,2900,1700,0,0,'Sin_Historial','prospecto',-12.0470,-75.2125),
  ('cccccccc-0001-0001-0001-000000000020','22012345','DNI','Agustín','Salcedo Hinostroza','1977-03-05','Casado','966012345','transporte','Transporte Salcedo',60,6500,3200,8000,1,'Normal','activo',-12.0445,-75.2100);

-- ============================================================
-- CREDITOS (historial)
-- ============================================================
INSERT INTO public.creditos (id, cliente_id, asesor_id, agencia_id, producto, monto_desembolsado, plazo_meses, tea, cuotas_totales, cuotas_pagadas, cuotas_mora, saldo_actual, fecha_desembolso, estado)
VALUES
  ('ffffffff-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000001','dddddddd-0001-0001-0001-000000000001','aaaaaaaa-0001-0001-0001-000000000001','credito_negocios',5000,12,18.0,12,12,0,0,'2024-06-01','pagado'),
  ('ffffffff-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000001','dddddddd-0001-0001-0001-000000000001','aaaaaaaa-0001-0001-0001-000000000001','credito_negocios',8000,12,16.0,12,8,0,3500,'2025-06-01','vigente'),
  ('ffffffff-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000002','dddddddd-0001-0001-0001-000000000001','aaaaaaaa-0001-0001-0001-000000000001','credito_negocios',15000,18,15.0,18,15,0,4500,'2025-01-15','vigente'),
  ('ffffffff-0001-0001-0001-000000000004','cccccccc-0001-0001-0001-000000000006','dddddddd-0001-0001-0001-000000000003','aaaaaaaa-0001-0001-0001-000000000003','credito_agropecuario',12000,24,14.0,24,18,3,4500,'2024-06-15','vencido'),
  ('ffffffff-0001-0001-0001-000000000005','cccccccc-0001-0001-0001-000000000012','dddddddd-0001-0001-0001-000000000004','aaaaaaaa-0001-0001-0001-000000000004','credito_agropecuario',8000,12,18.0,12,6,6,4800,'2024-10-01','vencido');

-- ============================================================
-- CARTERA DIARIA (visitas de hoy)
-- ============================================================
INSERT INTO public.cartera_diaria (id, asesor_id, cliente_id, agencia_id, fecha_asignacion, tipo_gestion, prioridad, score_prioridad, monto_referencial, estado_visita)
SELECT * FROM (VALUES
  ('11111111-0001-0001-0001-000000000001'::UUID,'dddddddd-0001-0001-0001-000000000001'::UUID,'cccccccc-0001-0001-0001-000000000001'::UUID,'aaaaaaaa-0001-0001-0001-000000000001'::UUID,CURRENT_DATE,'RENOVACION'::VARCHAR,'alta'::VARCHAR,75,8000,'pendiente'::VARCHAR),
  ('11111111-0001-0001-0001-000000000002','dddddddd-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000002','aaaaaaaa-0001-0001-0001-000000000001',CURRENT_DATE,'RENOVACION','alta',85,25000,'pendiente'),
  ('11111111-0001-0001-0001-000000000003','dddddddd-0001-0001-0001-000000000001','cccccccc-0001-0001-0001-000000000005','aaaaaaaa-0001-0001-0001-000000000001',CURRENT_DATE,'SEGUIMIENTO','media',30,6000,'pendiente'),
  ('11111111-0001-0001-0001-000000000004','dddddddd-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000004','aaaaaaaa-0001-0001-0001-000000000002',CURRENT_DATE,'RENOVACION','alta',80,15000,'visitado'),
  ('11111111-0001-0001-0001-000000000005','dddddddd-0001-0001-0001-000000000002','cccccccc-0001-0001-0001-000000000010','aaaaaaaa-0001-0001-0001-000000000002',CURRENT_DATE,'AMPLIACION','media',55,9000,'pendiente'),
  ('11111111-0001-0001-0001-000000000006','dddddddd-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000006','aaaaaaaa-0001-0001-0001-000000000003',CURRENT_DATE,'RECUPERACION_MORA','alta',95,18000,'visitado'),
  ('11111111-0001-0001-0001-000000000007','dddddddd-0001-0001-0001-000000000003','cccccccc-0001-0001-0001-000000000008','aaaaaaaa-0001-0001-0001-000000000003',CURRENT_DATE,'RENOVACION','alta',70,22000,'pendiente'),
  ('11111111-0001-0001-0001-000000000008','dddddddd-0001-0001-0001-000000000004','cccccccc-0001-0001-0001-000000000012','aaaaaaaa-0001-0001-0001-000000000004',CURRENT_DATE,'RECUPERACION_MORA','alta',90,0,'pendiente')
) AS t WHERE NOT EXISTS (SELECT 1 FROM public.cartera_diaria);

-- ============================================================
-- SCORING: Ejecutar para todos los clientes
-- ============================================================
DO $$
DECLARE v_cid UUID;
BEGIN
  FOR v_cid IN SELECT id FROM public.clientes ORDER BY numero_documento LOOP
    PERFORM public.calcular_score_crediticio(v_cid);
  END LOOP;
END $$;

-- ============================================================
-- CREDITOS PREAPROBADOS (para clientes con score A/B)
-- ============================================================
INSERT INTO public.creditos_preaprobados (cliente_id, asesor_id, monto_maximo, plazo_sugerido_meses, tea_referencial, score_confianza, vigente, fecha_vencimiento)
SELECT sc.cliente_id, cd.asesor_id, sc.monto_max_sugerido, 12, 15.0, sc.nivel_confianza, TRUE, CURRENT_DATE + INTERVAL '30 days'
FROM public.scores_crediticios sc
JOIN public.cartera_diaria cd ON cd.cliente_id = sc.cliente_id AND cd.fecha_asignacion = CURRENT_DATE
WHERE sc.segmento IN ('A','B')
AND NOT EXISTS (SELECT 1 FROM public.creditos_preaprobados WHERE cliente_id = sc.cliente_id AND vigente = TRUE);

-- ============================================================
-- VERIFICACION
-- ============================================================
SELECT 'agencias' AS tabla, COUNT(*) FROM public.agencias
UNION ALL SELECT 'asesores_negocio', COUNT(*) FROM public.asesores_negocio
UNION ALL SELECT 'clientes', COUNT(*) FROM public.clientes
UNION ALL SELECT 'creditos', COUNT(*) FROM public.creditos
UNION ALL SELECT 'creditos_preaprobados', COUNT(*) FROM public.creditos_preaprobados
UNION ALL SELECT 'cartera_diaria', COUNT(*) FROM public.cartera_diaria
UNION ALL SELECT 'scores_crediticios', COUNT(*) FROM public.scores_crediticios
ORDER BY tabla;

-- ============================================================
-- FIN — 04_seed_demo_bbva.sql
-- ============================================================
