-- ============================================================
-- SCRIPT 12 — Seed data para los 30 Casos de Práctica
-- App Móvil BBVA Fuerza de Ventas + App Clientes · v2.0
-- ============================================================
-- EJECUTAR: después del 11_sync_comite.sql
-- Los clientes se insertan solo si no existen (por DNI)
-- ============================================================

-- Helper: SHA-256 de '123456' para clientes_app
-- En Supabase (pgcrypto habilitado):
-- \df para confirmar que sha256 está disponible

DO $$
DECLARE
  v_password_hash TEXT := '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';
  v_clientes_app_id UUID;
  v_cliente_id UUID;
  v_cliente_data RECORD;
BEGIN

FOR v_cliente_data IN (
  SELECT * FROM (VALUES
    -- id_suffix, dni, nombres, apellidos, estado_civil, telefono, tipo_negocio, nombre_negocio, antiguedad_meses, ingresos, gastos, deuda, entidades, sbs, lat, lng, agencia_id
    ('001','40118120','Anaximandro','Quispe','Casado','964110201','bodega','Bodega Don Anaxi',48,2200,900,4500,1,'Normal',-12.0581,-75.2027,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('002','41223341','Eulalia','Mamani','Conviviente','964110202','restaurante','Picantería La Eulalia',36,3000,1400,12000,2,'Normal',-12.0921,-75.2105,'aaaaaaaa-0001-0001-0001-000000000003'),
    ('003','42330336','Teófilo','Huamán','Casado','964110203','carpinteria','Maderas Huamán',60,4200,1800,6000,1,'Normal',-12.0496,-75.2486,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('004','43440349','Casandra','Flores','Soltero','964110204','abarrotes','Distribuidora Casandra',84,7000,2600,14000,2,'Normal',-12.0651,-75.2049,'aaaaaaaa-0001-0001-0001-000000000001'),
    ('005','40556071','Demóstenes','Rojas','Casado','964110205','ferreteria','Ferretería El Constructor',30,5200,2100,12000,2,'Normal',-12.0188,-75.2271,'aaaaaaaa-0001-0001-0001-000000000001'),
    ('006','41669066','Hipatia','Condori','Conviviente','964110206','textil','Confecciones Hipatia',54,6800,2900,6000,1,'Normal',-12.0612,-75.2118,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('007','43773379','Aníbal','Vargas','Casado','964110207','transporte','Transportes Aníbal',42,9500,4200,14000,2,'Normal',-11.9182,-75.3142,'aaaaaaaa-0001-0001-0001-000000000005'),
    ('008','40886086','Penélope','Apaza','Casado','964110208','avicola','Granja Penélope',72,8800,3600,6000,1,'Normal',-12.1581,-75.1762,'aaaaaaaa-0001-0001-0001-000000000003'),
    ('009','41990091','Heráclito','Ccahua','Casado','964110209','comercio','Importaciones Heráclito',96,12000,5000,12000,2,'Normal',-12.0668,-75.2103,'aaaaaaaa-0001-0001-0001-000000000001'),
    ('010','43003039','Cleopatra','Soto','Viudo','964110210','farmacia','Botica Cleopatra',66,11000,4400,14000,2,'Normal',-12.0560,-75.2870,'aaaaaaaa-0001-0001-0001-000000000004'),
    ('011','40110010','Esquilo','Ramos','Casado','964110211','bodega','Minimarket Esquilo',24,1900,800,4500,1,'Normal',-12.1339,-75.2090,'aaaaaaaa-0001-0001-0001-000000000003'),
    ('012','41226021','Ariadna','Quispe','Soltero','964110212','peluqueria','Estilos Ariadna',40,3300,1300,12000,2,'Normal',-12.0573,-75.2161,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('013','43336033','Sócrates','Huanca','Casado','964110213','panaderia','Panadería Sócrates',58,5600,2300,0,0,'Normal',-12.0228,-75.3134,'aaaaaaaa-0001-0001-0001-000000000003'),
    ('014','40550055','Casiopea','Torres','Conviviente','964110214','mecanica','Taller Casiopea',50,7400,3000,16000,2,'Deficiente',-12.0512,-75.2451,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('015','41669166','Aristófanes','Cruz','Casado','964110215','agropecuario','Insumos Aristófanes',78,8200,3300,6000,1,'Normal',-11.9760,-75.3361,'aaaaaaaa-0001-0001-0001-000000000003'),
    ('016','43880088','Calipso','Mendoza','Casado','964110216','calzado','Calzados Calipso',62,7900,3100,9000,1,'CPP',-12.0689,-75.2055,'aaaaaaaa-0001-0001-0001-000000000001'),
    ('017','40119019','Demetrio','Quispe','Casado','964110217','comercio','Mayorista Demetrio',90,11500,4700,14000,2,'Normal',-11.7752,-75.4995,'aaaaaaaa-0001-0001-0001-000000000005'),
    ('018','41226126','Antígona','Flores','Conviviente','964110218','restaurante','Recreo Antígona',70,9200,3900,6000,1,'Normal',-11.9201,-75.3110,'aaaaaaaa-0001-0001-0001-000000000005'),
    ('019','43339033','Pitágoras','Rojas','Casado','964110219','ferreteria','Ferretería Pitágoras',100,13000,5200,0,0,'Normal',-12.0599,-75.2143,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('020','40556056','Berenice','Apaza','Casado','964110220','textil','Tejidos Berenice',46,8600,3500,6000,1,'Normal',-11.9871,-75.2899,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('021','43889089','Anaxágoras','Huamán','Casado','964110221','transporte','Carga Anaxágoras',84,14000,5800,14000,2,'Normal',-12.0644,-75.2088,'aaaaaaaa-0001-0001-0001-000000000001'),
    ('022','41003001','Climene','Vargas','Casado','964110222','avicola','Avícola Climene',76,13500,5500,12000,2,'Normal',-12.1560,-75.1790,'aaaaaaaa-0001-0001-0001-000000000003'),
    ('023','40115011','Epaminondas','Soto','Casado','964110223','bodega','Bodega Epaminondas',28,2600,1000,12000,2,'Normal',-12.1701,-75.1611,'aaaaaaaa-0001-0001-0001-000000000003'),
    ('024','41336036','Lisístrata','Ramos','Soltero','964110224','comercio','Variedades Lisístrata',52,4100,1700,6000,1,'Normal',-12.0633,-75.2071,'aaaaaaaa-0001-0001-0001-000000000001'),
    ('025','41552052','Filoctetes','Cruz','Casado','964110225','restaurante','Cevichería Filoctetes',18,3800,2200,18000,2,'CPP',-12.0930,-75.2090,'aaaaaaaa-0001-0001-0001-000000000003'),
    ('026','41888088','Calirroe','Mendoza','Casado','964110226','calzado','Calzados Calirroe',34,5000,2600,9000,1,'CPP',-12.0588,-75.2129,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('027','42220022','Tucídides','Quispe','Casado','964110227','ferreteria','Ferretería Tucídides',40,6200,2900,18000,2,'CPP',-11.9176,-75.3155,'aaaaaaaa-0001-0001-0001-000000000005'),
    ('028','43337037','Aquiles','Mamani','Casado','964110228','comercio','Comercial Aquiles',60,9000,3600,40000,4,'Perdida',-12.0657,-75.2099,'aaaaaaaa-0001-0001-0001-000000000001'),
    ('029','41884084','Medea','Apaza','Conviviente','964110229','bodega','Bodega Medea',22,1800,1100,25000,3,'Dudoso',-12.0489,-75.2470,'aaaaaaaa-0001-0001-0001-000000000002'),
    ('030','43334034','Esquines','Rojas','Casado','964110230','transporte','Fletes Esquines',30,7000,3200,25000,3,'Dudoso',-11.7740,-75.5010,'aaaaaaaa-0001-0001-0001-000000000005')
  ) AS t(id_suffix, dni, nombres, apellidos, estado_civil, telefono, tipo_negocio, nombre_negocio, antiguedad_meses, ingresos, gastos, deuda, entidades, sbs, lat, lng, agencia_id)
) LOOP
  -- Verificar si el cliente ya existe
  SELECT id INTO v_cliente_id FROM public.clientes WHERE numero_documento = v_cliente_data.dni;

  IF v_cliente_id IS NULL THEN
    -- Insertar cliente
    INSERT INTO public.clientes (
      id, numero_documento, tipo_documento, nombres, apellidos,
      fecha_nacimiento, estado_civil, telefono,
      tipo_negocio, nombre_negocio, antiguedad_negocio_meses,
      ingresos_estimados, gastos_mensuales,
      deuda_actual, entidades_deuda, calificacion_sbs, estado_cliente,
      lat, lng
    ) VALUES (
      ('cccccccc-0002-0001-0001-0000000000' || v_cliente_data.id_suffix)::UUID,
      v_cliente_data.dni, 'DNI', v_cliente_data.nombres, v_cliente_data.apellidos,
      '1985-01-15', v_cliente_data.estado_civil, v_cliente_data.telefono,
      v_cliente_data.tipo_negocio, v_cliente_data.nombre_negocio, v_cliente_data.antiguedad_meses,
      v_cliente_data.ingresos, v_cliente_data.gastos,
      v_cliente_data.deuda, v_cliente_data.entidades, v_cliente_data.sbs, 'activo',
      v_cliente_data.lat, v_cliente_data.lng
    )
    RETURNING id INTO v_cliente_id;

    -- Crear cliente_app para login
    INSERT INTO public.clientes_app (cliente_id, password_hash, activo)
    VALUES (v_cliente_id, v_password_hash, TRUE);

    -- Insertar scoring básico
    INSERT INTO public.scores_crediticios (cliente_id, score, segmento, recomendacion, monto_max_sugerido, nivel_confianza)
    VALUES (v_cliente_id, 85, 'A', 'aprobado_preaprobado', 50000, 80);

    -- Insertar perfil básico
    INSERT INTO public.perfiles_clientes (cliente_id, tipo_negocio, antiguedad_negocio, ingreso_mensual_est, gasto_mensual_est)
    VALUES (v_cliente_id, v_cliente_data.tipo_negocio, v_cliente_data.antiguedad_meses, v_cliente_data.ingresos, v_cliente_data.gastos);

  END IF;
END LOOP;

END $$;

-- ============================================================
-- Verificación
-- ============================================================
SELECT 'clientes_30casos' AS tabla, COUNT(*) FROM public.clientes WHERE numero_documento LIKE '4%'
UNION ALL SELECT 'clientes_app_30casos', COUNT(*) FROM public.clientes_app ca JOIN public.clientes c ON c.id = ca.cliente_id AND c.numero_documento LIKE '4%';
