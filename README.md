# App Banco BBVA — Fuerza de Ventas

Ecosistema móvil integrado para oficiales de crédito en campo. Permite gestionar cartera diaria, capturar solicitudes de crédito offline, consultar buró, registrar cobranza y sincronizar con el sistema central — todo desde el dispositivo móvil.

---

## Tech Stack

| Capa | Tecnología |
|------|-----------|
| **Frontend Móvil** | Flutter 3.x + Riverpod (MVVM) |
| **Backend API** | FastAPI (Python 3.12) |
| **Base de Datos** | PostgreSQL 15 (Supabase) |
| **Autenticación** | Supabase Auth (JWT) |
| **Caché Local** | SQLite (offline-first) |
| **Mapas** | OpenStreetMap / Google Maps |
| **SDK Backend** | supabase-py (HTTPS, sin SQLAlchemy) |

---

## Arquitectura

### Backend (FastAPI) — Capas

```
routes/ (endpoints HTTP)
    │
    ▼
repositories/ (lógica de negocio + consultas Supabase)
    │
    ▼
core/database.py (cliente supabase-py + supabase_execute async)
core/dependencies.py (get_current_user vía JWT)
core/security.py (generación/verificación de tokens HS256)
    │
    ▼
Supabase (PostgreSQL + Auth + Storage)
```

- Sin SQLAlchemy, sin asyncpg, sin ORM — todo vía `supabase-py` sobre HTTPS.
- Las consultas pesadas se envuelven con `asyncio.to_thread()` para no bloquear el event loop de FastAPI.

### Flutter — MVVM con Riverpod (offline-first)

```
presentation/ (Screens + ViewModels / StateNotifier)
    │  observa estado
    ▼
domain/ (Modelos puros: fromJson / toMap)
    │  solicita datos
    ▼
data/ (Repositorios → Remote Datasource + Local SQLite)
    │           │
    ▼           ▼
Supabase    SQLite local
(remoto)    (caché offline)
```

- **Con red**: consulta Supabase, guarda en SQLite como caché, devuelve datos.
- **Sin red**: lee del caché SQLite, muestra banner "modo offline".
- **Escritura offline**: guarda en cola local (`pendiente_sync = true`), sincroniza al reconectar.

### Estructura de Carpetas (Flutter)

```
lib/
├── main.dart
├── app/ (app.dart, router.dart)
├── core/
│   ├── constants/ (app_colors, app_strings)
│   ├── network/ (api_client, api_config, network_monitor)
│   └── storage/ (local_db, secure_storage)
├── features/
│   ├── auth/ (data/domain/presentation)
│   ├── cartera/
│   ├── ruta/
│   ├── ficha_cliente/
│   ├── solicitud/
│   ├── documentos/
│   ├── buro/
│   ├── estado_solicitudes/
│   ├── cobranza/
│   └── reportes/
└── shared/ (widgets, utils)
```

---

## Base de Datos

### Scripts SQL Versionados (`db/`)

| Archivo | Descripción |
|---------|------------|
| `00_schema_bbva.sql` | Esquema completo con integridad referencial |
| `01_cartera_solicitudes.sql` | Tablas de cartera diaria y solicitudes |
| `02_scoring_funciones_bbva.sql` | Funciones de scoring y priorización |
| `03_buro_cobranza.sql` | Consultas de buró y acciones de cobranza |
| `04_seed_demo_bbva.sql` | Datos demo calibrados (mora, productos) |
| `05_rls_policies.sql` | Políticas de seguridad RLS |
| `06_test_queries_bbva.sql` | Consultas de prueba |
| `07_link_auth_users.sql` | Vinculación Auth → asesores |
| `08_registrar_asesor.sql` | Registro de asesores |
| `10_campanas_marketing.sql` | Campañas y ofertas comerciales |

### Principales Tablas (`bd_core_mobile`)

- **Identidad**: `agencias`, `asesores_negocio`, `clientes`
- **Créditos**: `creditos`, `creditos_preaprobados`
- **Operación**: `cartera_diaria`, `solicitudes_credito`, `solicitudes_documentos`
- **Riesgo**: `consultas_buro`, `acciones_cobranza`, `alertas_cartera`
- **Espejo núcleo**: `cr_*` (sincronizadas desde `bd_core_financiero`)
- **Sincronización**: `sync_outbox`, `sync_log`
- **Locales (SQLite)**: `solicitudes_borrador`, `visitas_pendientes`

Diagrama entidad-relación completo en [`historias de usuario y mas.md`](historias%20de%20usuario%20y%20mas.md) (sección *Estructura de Base de Datos*).

---

## Documentación Funcional

El archivo [`historias de usuario y mas.md`](historias%20de%20usuario%20y%20mas.md) contiene la documentación completa:

| Documento | Contenido |
|-----------|-----------|
| **Historias de Usuario** | HU-01 a HU-33 (11 módulos: Autenticación → Reportes) |
| **Requerimientos Funcionales** | RF-01 a RF-90 |
| **Diagramas de Flujo** | Ciclo del crédito, captura 4 pasos, modo offline |
| **Diagrama ER** | Relaciones completas de la base de datos |
| **Arquitectura MVVM** | Estructura de capas y carpetas |
| **Dependencias** | Tabla completa de paquetes Flutter |
| **Offline-First** | Flujo de datos lectura/escritura sin conexión |
| **Políticas RLS** | Seguridad por filas en Supabase |

---

## Seguridad y Control de Acceso

- **Autenticación**: Supabase Auth con JWT (HS256).
- **Roles**: `operador` / `super_operador` / `supervisor` / `administrador`.
- **Token**: almacenado en `flutter_secure_storage`.
- **Backend**: todos los endpoints validan el token y el perfil del usuario (`get_current_user`).
- **RLS**: políticas de seguridad a nivel de fila en Supabase (cada asesor ve solo sus datos).
- **Bloqueo**: 5 intentos fallidos = bloqueo de 30 minutos.

---

## Getting Started

### Requisitos

- Python 3.12+
- Flutter 3.x
- Supabase project (URL + service_role key)

### Backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

Configurar variables de entorno en `backend/.env`:

```env
SUPABASE_URL=https://slvfourmyqgkzjddyliv.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SECRET_KEY=una-clave-secreta-segura
```

Ejecutar:

```bash
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Ver API en: [http://localhost:8000/docs](http://localhost:8000/docs)

### Flutter

```bash
cd appbanco_bbva_ventas
flutter pub get
flutter run
```

Configurar URL del backend en `lib/core/network/api_config.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
```

---

## Documentación Adicional

- [`rubrica.md`](rubrica.md) — Rúbrica de evaluación del proyecto
- [`historias de usuario y mas.md`](historias%20de%20usuario%20y%20mas.md) — HU, RF, diagramas, esquema BD completo
