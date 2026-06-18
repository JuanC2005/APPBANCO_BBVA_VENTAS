# Rúbrica de Evaluación - Proyecto Final Móvil Banco Andino

**Ecosistema móvil integrado:** App Fuerza de Ventas (Flutter) + App Clientes / Homebanking móvil + Core Mobile (FastAPI), funcionando como un único proyecto **end-to-end**.

- **Puntaje total:** 20 puntos
- **Criterios:** 5 criterios × 4 puntos cada uno
- **Alcance:** Las tres piezas deben comportarse como un solo sistema que:
  - Comparte la misma base de datos (`bd_core_mobile`).
  - Se conecta al núcleo financiero (`bd_core_financiero`) mediante el puente de sincronización.
  - Permite flujos completos de extremo a extremo:
    **Asesor origina un crédito en campo → Core lo evalúa/aprueba/desembolsa → Cliente lo ve reflejado en su app**.

---

## 📌 Criterio 1: Integración end-to-end (FVentas ↔ Core Mobile ↔ App Clientes) **(4 pts)**

**Evalúa:** Que las tres piezas compartan la misma base de datos y que el flujo cruce de un sistema a otro sin rupturas, incluyendo el puente al núcleo financiero.

| Nivel            | Pts | Descripción                                                                                                                                                                                                                                                                                                                                                                        |
| ---------------- | --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Excelente**    | 4   | El asesor registra una solicitud desde la **App FVentas** → se encola en `sync_outbox` y se promueve al **Core** (`bd_core_financiero: dcliente/dsolicitud`) → el crédito/desembolso se refleja de vuelta en las tablas espejo `cr_*` y aparece en la **App Clientes** (créditos, cronograma, saldo y movimientos). **Flujo completo verificado sobre una sola `bd_core_mobile`**. |
| **Bueno**        | 3   | El flujo cruza las tres piezas pero requiere algún paso manual (ej: disparar `POST /sync/promover` a mano) o un dato no se sincroniza automáticamente.                                                                                                                                                                                                                             |
| **Regular**      | 2   | **FVentas**, **App Clientes** y **Core** funcionan por separado sobre la misma BD, pero no hay un flujo que los conecte (no hay puente al núcleo ni reflejo en la app de clientes).                                                                                                                                                                                                |
| **Insuficiente** | 0-1 | Sistemas aislados, BDs distintas, o no hay integración.                                                                                                                                                                                                                                                                                                                            |

---

## 📌 Criterio 2: App Fuerza de Ventas - Originación de crédito en campo **(4 pts)**

**Evalúa:** El flujo del oficial de crédito: gestión de cartera, ficha, pre-evaluación, buró, solicitud y desembolso, alineado a la normativa de originación.

| Nivel         | Pts | Descripción |
| ------------- | --- | ----------- |
| **Excelente** | 4   | Implementa: |

- **Cartera offline-first** con filtros/orden y marca de visita (GPS).
- **Ficha del cliente** (posición, historial, oferta, semáforo de riesgo).
- **Pre-evaluación** (elegibilidad/sujeto de crédito).
- **Consulta de buró** (SBS + lista negra) con consentimiento firmado.
- **Solicitud por stepper** con simulador de cronograma (RF-47) y firma.
- **Transmisión/expediente** y registro real en backend. |
  | **Bueno** | 3 | Implementa el flujo completo pero faltan 1-2 piezas (ej: simulador de cuotas sin cronograma, o buró sin lista negra/consentimiento). |
  | **Regular** | 2 | Flujo básico: `solicitud → envío` sin reglas de originación reales (sin pre-evaluación, scoring ni buró). |
  | **Insuficiente** | 0-1 | No hay lógica de originación o es inventada/incoherente. |

---

## 📌 Criterio 3: App Clientes (Homebanking móvil) - Autoservicio **(4 pts)**

**Evalúa:** Que el cliente autenticado consulte y opere sus productos sobre los datos reales del Core compartido.

| Nivel         | Pts | Descripción |
| ------------- | --- | ----------- |
| **Excelente** | 4   | Incluye:    |

- Login del cliente con **DNI**.
- Perfil, cuentas de ahorro (saldo).
- Créditos con **cronograma de cuotas**, movimientos, tarjetas y notificaciones.
- Registro de operaciones (transferencia/pago) que impactan la BD.
- **Todos los datos provienen de `bd_core_mobile/espejo cr_*`**, coherentes con lo originado en **FVentas**. |
  | **Bueno** | 3 | Consulta de productos completa, pero falta una vista (ej: tarjetas o notificaciones) o las operaciones no persisten/impactan saldos. |
  | **Regular** | 2 | Solo login + una o dos consultas de productos, sin cronograma ni operaciones. |
  | **Insuficiente** | 0-1 | No existe la app de clientes o no opera sobre datos reales. |

---

## 📌 Criterio 4: Seguridad y control de acceso por roles (RBAC + JWT) **(4 pts)**

**Evalúa:** Autenticación, autorización por cargo y que cada actor (asesor, supervisor/admin, cliente) solo pueda hacer lo que le corresponde, validado en el backend.

| Nivel         | Pts | Descripción |
| ------------- | --- | ----------- |
| **Excelente** | 4   | Incluye:    |

- Login con **JWT** en las tres piezas (asesor en FVentas, cliente en App Clientes).
- Token en almacenamiento seguro (`flutter_secure_storage`).
- Bloqueo por **5 intentos fallidos** persistente.
- Matriz de permisos por rol (**asesor / supervisor / administrador / cliente**).
- Acciones restringidas (ej: reportes solo supervisor/admin, endpoints de cliente solo con su propio token) **bloqueadas en backend** (401/403 a quien no corresponde). |
  | **Bueno** | 3 | JWT + roles funcionando, pero algún permiso mal asignado o validado solo parcialmente en backend. |
  | **Regular** | 2 | Hay login pero el control de roles es parcial o solo en el frontend. |
  | **Insuficiente** | 0-1 | Sin autenticación real o cualquier usuario puede hacer cualquier cosa. |

---

## 📌 Criterio 5: Calidad de datos, arquitectura y documentación **(4 pts)**

**Evalúa:** La consistencia de la BD compartida, la arquitectura en capas de cada pieza y la documentación de respaldo.

| Nivel         | Pts | Descripción |
| ------------- | --- | ----------- |
| **Excelente** | 4   | Incluye:    |

- `bd_core_mobile` con **integridad referencial**.
- Tablas espejo `cr_*` del núcleo y puente `sync_outbox/sync_log` consistentes.
- Datos demo calibrados (mora con semáforo, productos coherentes).
- Arquitectura por capas en el **Core** (rutas → controladores → servicios/repositorios → BD).
- **MVVM/Riverpod offline-first** en Flutter (`data/domain/presentation`).
- **DDL y scripts SQL/seed versionados**.
- **Historias de Usuario + RF** y diagramas UML completos (clases, secuencia, componentes, casos de uso, estados). |
  | **Bueno** | 3 | Arquitectura y datos correctos, pero documentación, UML o scripts incompletos. |
  | **Regular** | 2 | Funciona pero con datos inconsistentes o sin documentación. |
  | **Insuficiente** | 0-1 | Datos incoherentes, sin estructura ni documentación. |

---

## 📊 Resumen de Puntaje

| #         | Criterio                                                  | Pts     |
| --------- | --------------------------------------------------------- | ------- |
| 1         | Integración end-to-end (FVentas ↔ Core Mobile ↔ Clientes) | /4      |
| 2         | App Fuerza de Ventas - Originación de crédito en campo    | /4      |
| 3         | App Clientes (Homebanking móvil) - Autoservicio           | /4      |
| 4         | Seguridad y RBAC (JWT + roles)                            | /4      |
| 5         | Calidad de datos, arquitectura y documentación            | /4      |
| **TOTAL** |                                                           | **/20** |

---

## 🎯 Escala de Calificación

| Rango | Calificación      |
| ----- | ----------------- |
| 18-20 | **Sobresaliente** |
| 14-17 | **Notable**       |
| 11-13 | **Aprobado**      |
| 0-10  | **Desaprobado**   |

---

## 📝 Hoja de Autoevaluación

| #         | Criterio                                           | Nivel obtenido | Pts | Evidencia / Observación |
| --------- | -------------------------------------------------- | -------------- | --- | ----------------------- |
| 1         | Integración end-to-end (FVentas ↔ Core ↔ Clientes) |                | /4  |                         |
| 2         | App Fuerza de Ventas - Originación                 |                | /4  |                         |
| 3         | App Clientes - Autoservicio                        |                | /4  |                         |
| 4         | Seguridad y RBAC                                   |                | /4  |                         |
| 5         | Calidad de datos, arquitectura y documentación     |                | /4  |                         |
| **TOTAL** |                                                    | **/20**        |     |                         |

---

**Documento original:** Rúbrica de Evaluación - Proyecto Final Móvil Banco Andino
**Adaptado a Markdown por Vibe**
