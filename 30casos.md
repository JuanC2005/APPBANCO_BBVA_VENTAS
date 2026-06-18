# 📋 30 Casos para Practicar — Crédito Empresarial (Flujo de Originación Móvil)

---

## 🌐 Ecosistema y Alcance

Cada caso representa **una operación de crédito empresarial (Microempresa)** que recorre el flujo completo del ecosistema **Banco Andino**, de extremo a extremo:

```
App Clientes (Flutter) → Core / API REST (FastAPI · 8003) → App Fuerza de Ventas (Flutter)
                     ↓
               Base de datos bd_core_mobile (PostgreSQL)
                     ↓ (sync_outbox)
               Núcleo bd_core_financiero
```

**Rol del estudiante:**  
Actúa en **dos roles** sobre el mismo expediente:

1. **Cliente**: Registra la solicitud desde su app.
2. **Asesor de negocios**: Recibe la solicitud en su cartera, la evalúa en campo y la lleva hasta el desembolso.

---

## 💰 Tarifario Aplicado

- **Producto:** Crédito Empresarial — Microempresa.
- **TEA:** **40.92%** (con seguro de desgravamen) o **43.92%** (sin seguro de desgravamen).
- **Tipo de cuota:** Cuota fija (amortización francesa).
- **Fórmula de cálculo:**
  - **TEM (Tasa Efectiva Mensual)** = `(1 + TEA)^(1/12) – 1`
  - **Cuota mensual** = `Monto × TEM / (1 - (1 + TEM)^(-Plazo en meses))`

---

## 📌 Flujo a Seguir en Cada Caso

1. **App Clientes — Registrar la solicitud**
  - Inicia sesión como cliente (documento + clave).
  - Registra la solicitud de crédito con los datos del caso (monto, plazo, destino, garantía).
  - El canal de la solicitud queda como **cliente** y nace en estado **enviado**.
  - El sistema devuelve un **número de expediente**.
2. **Core — Recepción**
  - La solicitud llega al core y se encola para promoverse al núcleo.
  - Queda visible para la agencia y se asigna al **asesor responsable**.
3. **App Fuerza de Ventas — Cartera del día**
  - Inicia sesión como asesor (código de empleado + clave).
  - La solicitud aparece en la **cartera del día** con tipo de gestión **NUEVA_SOLICITUD**.
  - Ubica al cliente y abre su **ficha**.
4. **Visita en campo**
  - Registra el resultado de la visita (**visitado**), con observación y coordenadas GPS del negocio.
5. **Pre-evaluación y buró**
  - Ejecuta la **pre-evaluación** por capacidad de pago.
  - Realiza la **consulta de buró y listas** (SBS + lista negra).
  - Verifica que el resultado coincida con el esperado del caso.
6. **Documentos y firma**
  - Adjunta los documentos indicados:
    - Documento de identidad (anverso y reverso).
    - Sustento del negocio.
    - Foto del negocio.
    - Foto de la visita.
  - Captura la **firma digital del cliente**.
7. **Envío al core y comité**
  - Promueve la solicitud al núcleo.
  - El expediente avanza por los estados:
  **recibido_comite → en_evaluacion → decisión**.
8. **Decisión y desembolso**
  - Según la decisión del comité:
    - **Aprobado/Condicionado:** Registra el desembolso y genera el **cronograma de pagos**.
    - **Rechazado:** Registra el motivo y cierra el expediente.

**Estados del expediente:**  
`borrador → enviado → recibido_comite → en_evaluacion → aprobado / condicionado / rechazado → desembolsado`

---

## 🔍 Nota sobre el Buró Simulado

- La **calificación SBS** depende del **último dígito del documento del cliente** (determinista).
- Si el cliente está en **lista de inhabilitados**, la solicitud se **bloquea en el paso 5** (consulta de buró).

---

---

## 📂 Casos

---

### **Caso 1: Anaximandro Quispe**

**Solicitante:** Anaximandro Quispe  
**Documento:** 40118120 | **Teléfono:** 964110201  
**Negocio:** Bodega «Bodega Don Anaxi» (El Tambo)  
**Antigüedad:** 48 meses  
**Ingresos:** S/ 2,200.00 | **Gastos:** S/ 900.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 1,000.00 | **Plazo:** 12 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Capital de trabajo (compra de mercadería)
- **Cuota de referencia:** S/ 100.95

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Normal
- **Visita:** Visitado
- **Ubicación:** lat -12.0581, lng -75.2027

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 4,500.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 1,000.00
- **Desembolso:** 02/02/2026
- **Cuotas:** Día 03 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 100.95

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo  |
| -------- | ------------- | ------ | ------- | ------- | ------ |
| 1        | 03/03/2026    | 100.95 | 70.14   | 30.81   | 929.86 |
| 2        | 03/04/2026    | 100.95 | 72.31   | 28.64   | 857.55 |
| 3        | 03/05/2026    | 100.95 | 74.53   | 26.42   | 783.02 |
| ...      | ...           | ...    | ...     | ...     | ...    |
| 12       | 03/02/2027    | 100.95 | 97.87   | 3.01    | 0.00   |


---

### **Caso 2: Eulalia Mamani**

**Solicitante:** Eulalia Mamani  
**Documento:** 41223341 | **Teléfono:** 964110202  
**Negocio:** Restaurante «Picantería La Eulalia» (Chilca)  
**Antigüedad:** 36 meses  
**Ingresos:** S/ 3,000.00 | **Gastos:** S/ 1,400.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 3,000.00 | **Plazo:** 12 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Compra de cocina industrial
- **Cuota de referencia:** S/ 299.59

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0921, lng -75.2105

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 12,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 3,000.00
- **Desembolso:** 05/02/2026
- **Cuotas:** Día 05 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 299.59

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 05/03/2026    | 299.59 | 212.60  | 86.99   | 2,787.40 |
| 2        | 05/04/2026    | 299.59 | 218.76  | 80.83   | 2,568.64 |
| 3        | 05/05/2026    | 299.59 | 225.11  | 74.48   | 2,343.53 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 12       | 05/02/2027    | 299.59 | 291.10  | 8.44    | 0.00     |


---

### **Caso 3: Teófilo Huamán**

**Solicitante:** Teófilo Huamán  
**Documento:** 42330336 | **Teléfono:** 964110203  
**Negocio:** Carpintería «Maderas Huamán» (Pilcomayo)  
**Antigüedad:** 60 meses  
**Ingresos:** S/ 4,200.00 | **Gastos:** S/ 1,800.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 5,000.00 | **Plazo:** 18 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Maquinaria (sierra y cepillo)
- **Cuota de referencia:** S/ 366.02

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0496, lng -75.2486

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 6,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 5,000.00
- **Desembolso:** 10/02/2026
- **Cuotas:** Día 10 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 366.02

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 10/03/2026    | 366.02 | 211.99  | 154.03  | 4,788.01 |
| 2        | 10/04/2026    | 366.02 | 218.52  | 147.50  | 4,569.49 |
| 3        | 10/05/2026    | 366.02 | 225.25  | 140.77  | 4,344.24 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 18       | 10/08/2027    | 366.02 | 355.18  | 10.94   | 0.00     |


---

### **Caso 4: Casandra Flores**

**Solicitante:** Casandra Flores  
**Documento:** 43440349 | **Teléfono:** 964110204  
**Negocio:** Abarrotes «Distribuidora Casandra» (Huancayo)  
**Antigüedad:** 84 meses  
**Ingresos:** S/ 7,000.00 | **Gastos:** S/ 2,600.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 8,000.00 | **Plazo:** 6 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Reposición de stock por campaña
- **Cuota de referencia:** S/ 1,480.73

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.0651, lng -75.2049

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 14,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 8,000.00
- **Desembolso:** 15/02/2026
- **Cuotas:** Día 15 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,480.73

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital  | Interés | Saldo    |
| -------- | ------------- | -------- | -------- | ------- | -------- |
| 1        | 15/03/2026    | 1,480.73 | 1,234.29 | 246.44  | 6,765.71 |
| 2        | 15/04/2026    | 1,480.73 | 1,272.31 | 208.42  | 5,493.40 |
| 3        | 15/05/2026    | 1,480.73 | 1,311.50 | 169.23  | 4,181.90 |
| ...      | ...           | ...      | ...      | ...     | ...      |
| 6        | 15/08/2026    | 1,480.73 | 1,436.45 | 44.25   | 0.00     |


---

### **Caso 5: Demóstenes Rojas**

**Solicitante:** Demóstenes Rojas  
**Documento:** 40556071 | **Teléfono:** 964110205  
**Negocio:** Ferretería «Ferretería El Constructor» (San Agustín de Cajas)  
**Antigüedad:** 30 meses  
**Ingresos:** S/ 5,200.00 | **Gastos:** S/ 2,100.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 10,000.00 | **Plazo:** 12 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Ampliación de local
- **Cuota de referencia:** S/ 1,009.46

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.0188, lng -75.2271

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 12,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 10,000.00
- **Desembolso:** 01/03/2026
- **Cuotas:** Día 03 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,009.46

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital | Interés | Saldo    |
| -------- | ------------- | -------- | ------- | ------- | -------- |
| 1        | 03/04/2026    | 1,009.46 | 701.40  | 308.06  | 9,298.60 |
| 2        | 03/05/2026    | 1,009.46 | 723.01  | 286.45  | 8,575.59 |
| 3        | 03/06/2026    | 1,009.46 | 745.28  | 264.18  | 7,830.31 |
| ...      | ...           | ...      | ...     | ...     | ...      |
| 12       | 03/03/2027    | 1,009.46 | 979.29  | 30.17   | 0.00     |


---

### **Caso 6: Hipatia Condori**

**Solicitante:** Hipatia Condori  
**Documento:** 41669066 | **Teléfono:** 964110206  
**Negocio:** Textil «Confecciones Hipatia» (El Tambo)  
**Antigüedad:** 54 meses  
**Ingresos:** S/ 6,800.00 | **Gastos:** S/ 2,900.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 12,000.00 | **Plazo:** 24 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Compra de máquinas remalladoras
- **Cuota de referencia:** S/ 700.94

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0612, lng -75.2118

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 6,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 12,000.00
- **Desembolso:** 05/03/2026
- **Cuotas:** Día 05 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 700.94

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo     |
| -------- | ------------- | ------ | ------- | ------- | --------- |
| 1        | 05/04/2026    | 700.94 | 352.97  | 347.97  | 11,647.03 |
| 2        | 05/05/2026    | 700.94 | 363.20  | 337.74  | 11,283.83 |
| 3        | 05/06/2026    | 700.94 | 373.74  | 327.20  | 10,910.09 |
| ...      | ...           | ...    | ...     | ...     | ...       |
| 24       | 05/03/2028    | 700.94 | 681.16  | 19.75   | 0.00      |


---

### **Caso 7: Aníbal Vargas**

**Solicitante:** Aníbal Vargas  
**Documento:** 43773379 | **Teléfono:** 964110207  
**Negocio:** Transporte «Transportes Aníbal» (Concepción)  
**Antigüedad:** 42 meses  
**Ingresos:** S/ 9,500.00 | **Gastos:** S/ 4,200.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 15,000.00 | **Plazo:** 18 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Vehicular
- **Destino:** Cuota inicial de vehículo de carga
- **Cuota de referencia:** S/ 1,098.07

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -11.9182, lng -75.3142

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 14,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 15,000.00
- **Desembolso:** 10/03/2026
- **Cuotas:** Día 10 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,098.07

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital  | Interés | Saldo     |
| -------- | ------------- | -------- | -------- | ------- | --------- |
| 1        | 10/04/2026    | 1,098.07 | 635.99   | 462.08  | 14,364.01 |
| 2        | 10/05/2026    | 1,098.07 | 655.58   | 442.49  | 13,708.43 |
| 3        | 10/06/2026    | 1,098.07 | 675.77   | 422.30  | 13,032.66 |
| ...      | ...           | ...      | ...      | ...     | ...       |
| 18       | 10/09/2027    | 1,098.07 | 1,065.30 | 32.82   | 0.00      |


---

### **Caso 8: Penélope Apaza**

**Solicitante:** Penélope Apaza  
**Documento:** 40886086 | **Teléfono:** 964110208  
**Negocio:** Avícola «Granja Penélope» (Sapallanga)  
**Antigüedad:** 72 meses  
**Ingresos:** S/ 8,800.00 | **Gastos:** S/ 3,600.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 18,000.00 | **Plazo:** 24 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Ampliación de galpón
- **Cuota de referencia:** S/ 1,072.10

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.1581, lng -75.1762

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 6,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 18,000.00
- **Desembolso:** 15/03/2026
- **Cuotas:** Día 15 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,072.10

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital  | Interés | Saldo     |
| -------- | ------------- | -------- | -------- | ------- | --------- |
| 1        | 15/04/2026    | 1,072.10 | 517.60   | 554.50  | 17,482.40 |
| 2        | 15/05/2026    | 1,072.10 | 533.54   | 538.56  | 16,948.86 |
| 3        | 15/06/2026    | 1,072.10 | 549.98   | 522.12  | 16,398.88 |
| ...      | ...           | ...      | ...      | ...     | ...       |
| 24       | 15/03/2028    | 1,072.10 | 1,039.97 | 32.04   | 0.00      |


---

### **Caso 9: Heráclito Ccahua**

**Solicitante:** Heráclito Ccahua  
**Documento:** 41990091 | **Teléfono:** 964110209  
**Negocio:** Comercio «Importaciones Heráclito» (Huancayo)  
**Antigüedad:** 96 meses  
**Ingresos:** S/ 12,000.00 | **Gastos:** S/ 5,000.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 20,000.00 | **Plazo:** 36 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Capital para nueva sucursal
- **Cuota de referencia:** S/ 927.12

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.0668, lng -75.2103

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 12,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 20,000.00
- **Desembolso:** 02/04/2026
- **Cuotas:** Día 03 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 927.12

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo     |
| -------- | ------------- | ------ | ------- | ------- | --------- |
| 1        | 03/05/2026    | 927.12 | 311.01  | 616.11  | 19,688.99 |
| 2        | 03/06/2026    | 927.12 | 320.59  | 606.53  | 19,368.40 |
| 3        | 03/07/2026    | 927.12 | 330.47  | 596.65  | 19,037.93 |
| ...      | ...           | ...    | ...     | ...     | ...       |
| 36       | 03/04/2029    | 927.12 | 899.39  | 27.71   | 0.00      |


---

### **Caso 10: Cleopatra Soto**

**Solicitante:** Cleopatra Soto  
**Documento:** 43003039 | **Teléfono:** 964110210  
**Negocio:** Farmacia «Botica Cleopatra» (Chupaca)  
**Antigüedad:** 66 meses  
**Ingresos:** S/ 11,000.00 | **Gastos:** S/ 4,400.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 25,000.00 | **Plazo:** 24 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Equipamiento y stock farmacéutico
- **Cuota de referencia:** S/ 1,460.29

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.056, lng -75.287

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 14,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 25,000.00
- **Desembolso:** 05/04/2026
- **Cuotas:** Día 05 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,460.29

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital  | Interés | Saldo     |
| -------- | ------------- | -------- | -------- | ------- | --------- |
| 1        | 05/05/2026    | 1,460.29 | 735.35   | 724.94  | 24,264.65 |
| 2        | 05/06/2026    | 1,460.29 | 756.67   | 703.62  | 23,507.98 |
| 3        | 05/07/2026    | 1,460.29 | 778.61   | 681.68  | 22,729.37 |
| ...      | ...           | ...      | ...      | ...     | ...       |
| 24       | 05/04/2028    | 1,460.29 | 1,419.24 | 41.15   | 0.00      |


---

### **Caso 11: Esquilo Ramos**

**Solicitante:** Esquilo Ramos  
**Documento:** 40110010 | **Teléfono:** 964110211  
**Negocio:** Bodega «Minimarket Esquilo» (Huayucachi)  
**Antigüedad:** 24 meses  
**Ingresos:** S/ 1,900.00 | **Gastos:** S/ 800.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 2,000.00 | **Plazo:** 12 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Compra de congeladora
- **Cuota de referencia:** S/ 201.89

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Normal
- **Visita:** Visitado
- **Ubicación:** lat -12.1339, lng -75.209

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 4,500.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 2,000.00
- **Desembolso:** 10/04/2026
- **Cuotas:** Día 10 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 201.89

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 10/05/2026    | 201.89 | 140.28  | 61.61   | 1,859.72 |
| 2        | 10/06/2026    | 201.89 | 144.60  | 57.29   | 1,715.12 |
| 3        | 10/07/2026    | 201.89 | 149.05  | 52.84   | 1,566.07 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 12       | 10/04/2027    | 201.89 | 195.88  | 6.03    | 0.00     |


---

### **Caso 12: Ariadna Quispe**

**Solicitante:** Ariadna Quispe  
**Documento:** 41226021 | **Teléfono:** 964110212  
**Negocio:** Peluquería «Estilos Ariadna» (El Tambo)  
**Antigüedad:** 40 meses  
**Ingresos:** S/ 3,300.00 | **Gastos:** S/ 1,300.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 4,000.00 | **Plazo:** 18 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Mobiliario y equipos de salón
- **Cuota de referencia:** S/ 292.82

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0573, lng -75.2161

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 12,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 4,000.00
- **Desembolso:** 15/04/2026
- **Cuotas:** Día 15 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 292.82

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 15/05/2026    | 292.82 | 169.60  | 123.22  | 3,830.40 |
| 2        | 15/06/2026    | 292.82 | 174.82  | 118.00  | 3,655.58 |
| 3        | 15/07/2026    | 292.82 | 180.21  | 112.61  | 3,475.37 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 18       | 15/10/2027    | 292.82 | 284.07  | 8.75    | 0.00     |


---

### **Caso 13: Sócrates Huanca**

**Solicitante:** Sócrates Huanca  
**Documento:** 43336033 | **Teléfono:** 964110213  
**Negocio:** Panadería «Panadería Sócrates» (Sicaya)  
**Antigüedad:** 58 meses  
**Ingresos:** S/ 5,600.00 | **Gastos:** S/ 2,300.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 6,000.00 | **Plazo:** 12 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Horno rotativo
- **Cuota de referencia:** S/ 599.17

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0228, lng -75.3134

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 0 entidades con deuda, deuda total S/ 0.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 6,000.00
- **Desembolso:** 02/05/2026
- **Cuotas:** Día 03 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 599.17

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 03/06/2026    | 599.17 | 425.18  | 173.99  | 5,574.82 |
| 2        | 03/07/2026    | 599.17 | 437.51  | 161.66  | 5,137.31 |
| 3        | 03/08/2026    | 599.17 | 450.20  | 148.97  | 4,687.11 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 12       | 03/05/2027    | 599.17 | 582.33  | 16.89   | 0.00     |


---

### **Caso 14: Casiopea Torres**

**Solicitante:** Casiopea Torres  
**Documento:** 40550055 | **Teléfono:** 964110214  
**Negocio:** Mecánica «Taller Casiopea» (Pilcomayo)  
**Antigüedad:** 50 meses  
**Ingresos:** S/ 7,400.00 | **Gastos:** S/ 3,000.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 7,500.00 | **Plazo:** 6 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Herramienta neumática
- **Cuota de referencia:** S/ 1,388.18

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0512, lng -75.2451

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** DEFICIENTE, 2 entidades con deuda, deuda total S/ 16,000.00, 45 días de mayor mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 7,500.00
- **Desembolso:** 05/05/2026
- **Cuotas:** Día 05 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,388.18

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital  | Interés | Saldo    |
| -------- | ------------- | -------- | -------- | ------- | -------- |
| 1        | 05/06/2026    | 1,388.18 | 1,157.14 | 231.04  | 6,342.86 |
| 2        | 05/07/2026    | 1,388.18 | 1,192.78 | 195.40  | 5,150.08 |
| 3        | 05/08/2026    | 1,388.18 | 1,229.53 | 158.65  | 3,920.55 |
| ...      | ...           | ...      | ...      | ...     | ...      |
| 6        | 05/11/2026    | 1,388.18 | 1,346.69 | 41.49   | 0.00     |


---

### **Caso 15: Aristófanes Cruz**

**Solicitante:** Aristófanes Cruz  
**Documento:** 41669166 | **Teléfono:** 964110215  
**Negocio:** Agropecuario «Insumos Aristófanes» (Orcotuna)  
**Antigüedad:** 78 meses  
**Ingresos:** S/ 8,200.00 | **Gastos:** S/ 3,300.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 9,000.00 | **Plazo:** 24 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Capital para campaña agrícola
- **Cuota de referencia:** S/ 536.05

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -11.976, lng -75.3361

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 6,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 9,000.00
- **Desembolso:** 10/05/2026
- **Cuotas:** Día 10 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 536.05

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 10/06/2026    | 536.05 | 258.80  | 277.25  | 8,741.20 |
| 2        | 10/07/2026    | 536.05 | 266.77  | 269.28  | 8,474.43 |
| 3        | 10/08/2026    | 536.05 | 274.99  | 261.06  | 8,199.44 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 24       | 10/05/2028    | 536.05 | 520.02  | 16.02   | 0.00     |


---

### **Caso 16: Calipso Mendoza**

**Solicitante:** Calipso Mendoza  
**Documento:** 43880088 | **Teléfono:** 964110216  
**Negocio:** Calzado «Calzados Calipso» (Huancayo)  
**Antigüedad:** 62 meses  
**Ingresos:** S/ 7,900.00 | **Gastos:** S/ 3,100.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 11,000.00 | **Plazo:** 18 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Compra de cuero y maquinaria
- **Cuota de referencia:** S/ 793.03

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0689, lng -75.2055

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** CPP, 1 entidad con deuda, deuda total S/ 9,000.00, 20 días de mayor mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 11,000.00
- **Desembolso:** 15/05/2026
- **Cuotas:** Día 15 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 793.03

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo     |
| -------- | ------------- | ------ | ------- | ------- | --------- |
| 1        | 15/06/2026    | 793.03 | 474.06  | 318.97  | 10,525.94 |
| 2        | 15/07/2026    | 793.03 | 487.80  | 305.23  | 10,038.14 |
| 3        | 15/08/2026    | 793.03 | 501.95  | 291.08  | 9,536.19  |
| ...      | ...           | ...    | ...     | ...     | ...       |
| 18       | 15/11/2027    | 793.03 | 770.76  | 22.35   | 0.00      |


---

### **Caso 17: Demetrio Quispe**

**Solicitante:** Demetrio Quispe  
**Documento:** 40119019 | **Teléfono:** 964110217  
**Negocio:** Comercio «Mayorista Demetrio» (Jauja)  
**Antigüedad:** 90 meses  
**Ingresos:** S/ 11,500.00 | **Gastos:** S/ 4,700.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 13,500.00 | **Plazo:** 12 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Reposición de inventario mayorista
- **Cuota de referencia:** S/ 1,362.77

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -11.7752, lng -75.4995

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 14,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 13,500.00
- **Desembolso:** 02/06/2026
- **Cuotas:** Día 03 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,362.77

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital  | Interés | Saldo     |
| -------- | ------------- | -------- | -------- | ------- | --------- |
| 1        | 03/07/2026    | 1,362.77 | 946.89   | 415.88  | 12,553.11 |
| 2        | 03/08/2026    | 1,362.77 | 976.06   | 386.71  | 11,577.05 |
| 3        | 03/09/2026    | 1,362.77 | 1,006.13 | 356.64  | 10,570.92 |
| ...      | ...           | ...      | ...      | ...     | ...       |
| 12       | 03/06/2027    | 1,362.77 | 1,322.02 | 40.73   | 0.00      |


---

### **Caso 18: Antígona Flores**

**Solicitante:** Antígona Flores  
**Documento:** 41226126 | **Teléfono:** 964110218  
**Negocio:** Restaurante «Recreo Antígona» (Concepción)  
**Antigüedad:** 70 meses  
**Ingresos:** S/ 9,200.00 | **Gastos:** S/ 3,900.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 16,000.00 | **Plazo:** 36 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Ampliación y remodelación
- **Cuota de referencia:** S/ 741.70

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -11.9201, lng -75.311

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 6,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 16,000.00
- **Desembolso:** 05/06/2026
- **Cuotas:** Día 05 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 741.70

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo     |
| -------- | ------------- | ------ | ------- | ------- | --------- |
| 1        | 05/07/2026    | 741.70 | 248.81  | 492.89  | 15,751.19 |
| 2        | 05/08/2026    | 741.70 | 256.48  | 485.22  | 15,494.71 |
| 3        | 05/09/2026    | 741.70 | 264.38  | 477.32  | 15,230.33 |
| ...      | ...           | ...    | ...     | ...     | ...       |
| 36       | 05/06/2029    | 741.70 | 719.29  | 22.16   | 0.00      |


---

### **Caso 19: Pitágoras Rojas**

**Solicitante:** Pitágoras Rojas  
**Documento:** 43339033 | **Teléfono:** 964110219  
**Negocio:** Ferretería «Ferretería Pitágoras» (El Tambo)  
**Antigüedad:** 100 meses  
**Ingresos:** S/ 13,000.00 | **Gastos:** S/ 5,200.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 17,000.00 | **Plazo:** 24 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Compra de stock estructural
- **Cuota de referencia:** S/ 993.00

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.0599, lng -75.2143

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 0 entidades con deuda, deuda total S/ 0.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 17,000.00
- **Desembolso:** 10/06/2026
- **Cuotas:** Día 10 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 993.00

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo     |
| -------- | ------------- | ------ | ------- | ------- | --------- |
| 1        | 10/07/2026    | 993.00 | 500.04  | 492.96  | 16,499.96 |
| 2        | 10/08/2026    | 993.00 | 514.54  | 478.46  | 15,985.42 |
| 3        | 10/09/2026    | 993.00 | 529.46  | 463.54  | 15,455.96 |
| ...      | ...           | ...    | ...     | ...     | ...       |
| 24       | 10/06/2028    | 993.00 | 964.96  | 27.98   | 0.00      |


---

### **Caso 20: Berenice Apaza**

**Solicitante:** Berenice Apaza  
**Documento:** 40556056 | **Teléfono:** 964110220  
**Negocio:** Textil «Tejidos Berenice» (San Jerónimo de Tunán)  
**Antigüedad:** 46 meses  
**Ingresos:** S/ 8,600.00 | **Gastos:** S/ 3,500.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 19,000.00 | **Plazo:** 18 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Maquinaria de tejido plano
- **Cuota de referencia:** S/ 1,390.89

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -11.9871, lng -75.2899

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 6,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 19,000.00
- **Desembolso:** 15/06/2026
- **Cuotas:** Día 15 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,390.89

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital  | Interés | Saldo     |
| -------- | ------------- | -------- | -------- | ------- | --------- |
| 1        | 15/07/2026    | 1,390.89 | 805.58   | 585.31  | 18,194.42 |
| 2        | 15/08/2026    | 1,390.89 | 830.40   | 560.49  | 17,364.02 |
| 3        | 15/09/2026    | 1,390.89 | 855.98   | 534.91  | 16,508.04 |
| ...      | ...           | ...      | ...      | ...     | ...       |
| 18       | 15/12/2027    | 1,390.89 | 1,349.36 | 41.57   | 0.00      |


---

### **Caso 21: Anaxágoras Huamán**

**Solicitante:** Anaxágoras Huamán  
**Documento:** 43889089 | **Teléfono:** 964110221  
**Negocio:** Transporte «Carga Anaxágoras» (Huancayo)  
**Antigüedad:** 84 meses  
**Ingresos:** S/ 14,000.00 | **Gastos:** S/ 5,800.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 22,000.00 | **Plazo:** 36 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Vehicular
- **Destino:** Cuota inicial de camión
- **Cuota de referencia:** S/ 1,019.83

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.0644, lng -75.2088

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 14,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 22,000.00
- **Desembolso:** 02/07/2026
- **Cuotas:** Día 03 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,019.83

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital | Interés | Saldo     |
| -------- | ------------- | -------- | ------- | ------- | --------- |
| 1        | 03/08/2026    | 1,019.83 | 342.11  | 677.72  | 21,657.89 |
| 2        | 03/09/2026    | 1,019.83 | 352.65  | 667.18  | 21,305.24 |
| 3        | 03/10/2026    | 1,019.83 | 363.51  | 656.32  | 20,941.73 |
| ...      | ...           | ...      | ...     | ...     | ...       |
| 36       | 03/07/2029    | 1,019.83 | 989.49  | 30.48   | 0.00      |


---

### **Caso 22: Climene Vargas**

**Solicitante:** Climene Vargas  
**Documento:** 41003001 | **Teléfono:** 964110222  
**Negocio:** Avícola «Avícola Climene» (Sapallanga)  
**Antigüedad:** 76 meses  
**Ingresos:** S/ 13,500.00 | **Gastos:** S/ 5,500.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 24,000.00 | **Plazo:** 24 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Equipamiento de planta
- **Cuota de referencia:** S/ 1,401.88

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.156, lng -75.179

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 12,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 24,000.00
- **Desembolso:** 05/07/2026
- **Cuotas:** Día 05 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 1,401.88

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota    | Capital  | Interés | Saldo     |
| -------- | ------------- | -------- | -------- | ------- | --------- |
| 1        | 05/08/2026    | 1,401.88 | 705.94   | 695.94  | 23,294.06 |
| 2        | 05/09/2026    | 1,401.88 | 726.41   | 675.47  | 22,567.65 |
| 3        | 05/10/2026    | 1,401.88 | 747.47   | 654.41  | 21,820.18 |
| ...      | ...           | ...      | ...      | ...     | ...       |
| 24       | 05/07/2028    | 1,401.88 | 1,362.36 | 39.51   | 0.00      |


---

### **Caso 23: Epaminondas Soto**

**Solicitante:** Epaminondas Soto  
**Documento:** 40115011 | **Teléfono:** 964110223  
**Negocio:** Bodega «Bodega Epaminondas» (Pucará)  
**Antigüedad:** 28 meses  
**Ingresos:** S/ 2,600.00 | **Gastos:** S/ 1,000.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 1,500.00 | **Plazo:** 6 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Compra de vitrinas
- **Cuota de referencia:** S/ 277.64

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Normal
- **Visita:** Visitado
- **Ubicación:** lat -12.1701, lng -75.1611

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 2 entidades con deuda, deuda total S/ 12,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 1,500.00
- **Desembolso:** 10/07/2026
- **Cuotas:** Día 10 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 277.64

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 10/08/2026    | 277.64 | 231.43  | 46.21   | 1,268.57 |
| 2        | 10/09/2026    | 277.64 | 238.56  | 39.08   | 1,030.01 |
| 3        | 10/10/2026    | 277.64 | 245.91  | 31.73   | 784.10   |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 6        | 10/01/2027    | 277.64 | 269.32  | 8.30    | 0.00     |


---

### **Caso 24: Lisístrata Ramos**

**Solicitante:** Lisístrata Ramos  
**Documento:** 41336036 | **Teléfono:** 964110224  
**Negocio:** Comercio «Variedades Lisístrata» (Huancayo)  
**Antigüedad:** 52 meses  
**Ingresos:** S/ 4,100.00 | **Gastos:** S/ 1,700.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 3,500.00 | **Plazo:** 12 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Capital de trabajo
- **Cuota de referencia:** S/ 353.31

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0633, lng -75.2071

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** NORMAL, 1 entidad con deuda, deuda total S/ 6,000.00, 0 días de mora

**Decisión del comité:** **APROBADO**

- **Monto aprobado:** S/ 3,500.00
- **Desembolso:** 15/07/2026
- **Cuotas:** Día 15 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 353.31

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 15/08/2026    | 353.31 | 245.49  | 107.82  | 3,254.51 |
| 2        | 15/09/2026    | 353.31 | 253.05  | 100.26  | 3,001.46 |
| 3        | 15/10/2026    | 353.31 | 260.85  | 92.46   | 2,740.61 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 12       | 15/07/2027    | 353.31 | 342.75  | 10.56   | 0.00     |


---

## ⚠️ Casos con Decisiones Alternativas

---

### **Caso 25: Filoctetes Cruz** *(Condicionado)*

**Solicitante:** Filoctetes Cruz  
**Documento:** 41552052 | **Teléfono:** 964110225  
**Negocio:** Restaurante «Cevichería Filoctetes» (Chilca)  
**Antigüedad:** 18 meses  
**Ingresos:** S/ 3,800.00 | **Gastos:** S/ 2,200.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 11,000.00 | **Plazo:** 18 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Ampliación de local nuevo
- **Cuota de referencia:** S/ 793.03

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.093, lng -75.209

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** CPP, 2 entidades con deuda, deuda total S/ 18,000.00, 15 días de mayor mora

**Decisión del comité:** **CONDICIONADO**

- **Motivo:** Antigüedad del negocio menor a 24 meses y carga de gastos alta.
- **Monto aprobado:** S/ 7,000.00 (sobre el plazo y la TEA solicitados)
- **Desembolso:** 02/08/2026
- **Cuotas:** Día 03 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 504.66

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 03/09/2026    | 504.66 | 301.68  | 202.98  | 6,698.32 |
| 2        | 03/10/2026    | 504.66 | 310.42  | 194.24  | 6,387.90 |
| 3        | 03/11/2026    | 504.66 | 319.43  | 185.23  | 6,068.47 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 18       | 03/02/2028    | 504.66 | 490.37  | 14.22   | 0.00     |


---

### **Caso 26: Calirroe Mendoza** *(Condicionado)*

**Solicitante:** Calirroe Mendoza  
**Documento:** 41888088 | **Teléfono:** 964110226  
**Negocio:** Calzado «Calzados Calirroe» (El Tambo)  
**Antigüedad:** 34 meses  
**Ingresos:** S/ 5,000.00 | **Gastos:** S/ 2,600.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 16,000.00 | **Plazo:** 24 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Maquinaria de mayor capacidad
- **Cuota de referencia:** S/ 952.98

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0588, lng -75.2129

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** CPP, 1 entidad con deuda, deuda total S/ 9,000.00, 20 días de mayor mora

**Decisión del comité:** **CONDICIONADO**

- **Motivo:** Calificación CPP con 20 días de mora reciente.
- **Monto aprobado:** S/ 10,000.00 (sobre el plazo y la TEA solicitados)
- **Desembolso:** 05/08/2026
- **Cuotas:** Día 05 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 595.61

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo    |
| -------- | ------------- | ------ | ------- | ------- | -------- |
| 1        | 05/09/2026    | 595.61 | 287.55  | 308.06  | 9,712.45 |
| 2        | 05/10/2026    | 595.61 | 296.41  | 299.20  | 9,416.04 |
| 3        | 05/11/2026    | 595.61 | 305.54  | 290.07  | 9,110.50 |
| ...      | ...           | ...    | ...     | ...     | ...      |
| 24       | 05/08/2028    | 595.61 | 577.82  | 17.80   | 0.00     |


---

### **Caso 27: Tucídides Quispe** *(Condicionado)*

**Solicitante:** Tucídides Quispe  
**Documento:** 42220022 | **Teléfono:** 964110227  
**Negocio:** Ferretería «Ferretería Tucídides» (Concepción)  
**Antigüedad:** 40 meses  
**Ingresos:** S/ 6,200.00 | **Gastos:** S/ 2,900.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 20,000.00 | **Plazo:** 24 meses
- **TEA:** 40.92% (con seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Compra de stock y montacarga
- **Cuota de referencia:** S/ 1,168.23

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -11.9176, lng -75.3155

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** CPP, 2 entidades con deuda, deuda total S/ 18,000.00, 15 días de mayor mora

**Decisión del comité:** **CONDICIONADO**

- **Motivo:** Endeudamiento externo en 2 entidades y relación monto/ingreso ajustada.
- **Monto aprobado:** S/ 14,000.00 (sobre el plazo y la TEA solicitados)
- **Desembolso:** 10/08/2026
- **Cuotas:** Día 10 de cada mes (a partir del mes siguiente)
- **Cuota mensual:** S/ 817.76

**Cronograma (primeras 3 cuotas):**


| N° Cuota | Fecha de pago | Cuota  | Capital | Interés | Saldo     |
| -------- | ------------- | ------ | ------- | ------- | --------- |
| 1        | 10/09/2026    | 817.76 | 411.79  | 405.97  | 13,588.21 |
| 2        | 10/10/2026    | 817.76 | 423.73  | 394.03  | 13,164.48 |
| 3        | 10/11/2026    | 817.76 | 436.02  | 381.74  | 12,728.46 |
| ...      | ...           | ...    | ...     | ...     | ...       |
| 24       | 10/08/2028    | 817.76 | 794.86  | 23.05   | 0.00      |


---

### **Caso 28: Aquiles Mamani** *(Rechazado - Lista de Inhabilitados)*

**Solicitante:** Aquiles Mamani  
**Documento:** 43337037 | **Teléfono:** 964110228  
**Negocio:** Comercio «Comercial Aquiles» (Huancayo)  
**Antigüedad:** 60 meses  
**Ingresos:** S/ 9,000.00 | **Gastos:** S/ 3,600.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 15,000.00 | **Plazo:** 24 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Hipotecaria
- **Destino:** Capital de trabajo
- **Cuota de referencia:** S/ 893.42

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -12.0657, lng -75.2099

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** **PERDIDA**, 4 entidades con deuda, deuda total S/ 40,000.00, 210 días de mayor mora, **en lista de inhabilitados**

**Decisión del comité:** **RECHAZADO**

- **Motivo:** Registrado en lista de inhabilitados del sistema financiero.
- **Acción:** La solicitud se bloquea en la consulta de buró. **No se genera cronograma**.
- **Estado final:** Rechazado

---

### **Caso 29: Medea Apaza** *(Rechazado - Capacidad de Pago Insuficiente)*

**Solicitante:** Medea Apaza  
**Documento:** 41884084 | **Teléfono:** 964110229  
**Negocio:** Bodega «Bodega Medea» (Pilcomayo)  
**Antigüedad:** 22 meses  
**Ingresos:** S/ 1,800.00 | **Gastos:** S/ 1,100.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 14,000.00 | **Plazo:** 18 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Sin garantía
- **Destino:** Compra de camioneta para reparto
- **Cuota de referencia:** S/ 1,024.87

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Media
- **Visita:** Visitado
- **Ubicación:** lat -12.0489, lng -75.247

**Evaluación:**

- **Pre-evaluación:** **REVISAR** (puntaje 60)
- **Buró:** DUDOSO, 3 entidades con deuda, deuda total S/ 25,000.00, 95 días de mayor mora

**Decisión del comité:** **RECHAZADO**

- **Motivo:** El monto solicitado supera ampliamente la capacidad de pago estimada (pre-evaluación **NO_PROCEDE**).
- **Acción:** **No se genera cronograma**.
- **Estado final:** Rechazado

---

### **Caso 30: Esquines Rojas** *(Rechazado - Calificación DUDOSA)*

**Solicitante:** Esquines Rojas  
**Documento:** 43334034 | **Teléfono:** 964110230  
**Negocio:** Transporte «Fletes Esquines» (Jauja)  
**Antigüedad:** 30 meses  
**Ingresos:** S/ 7,000.00 | **Gastos:** S/ 3,200.00

**Solicitud:**

- **Producto:** Crédito Empresarial - Microempresa
- **Monto:** S/ 30,000.00 | **Plazo:** 24 meses
- **TEA:** 43.92% (sin seguro de desgravamen)
- **Garantía:** Vehicular
- **Destino:** Compra de unidad de transporte
- **Cuota de referencia:** S/ 1,786.83

**Asesor:**

- **Tipo de gestión:** NUEVA_SOLICITUD | **Prioridad:** Alta
- **Visita:** Visitado
- **Ubicación:** lat -11.774, lng -75.501

**Evaluación:**

- **Pre-evaluación:** APTO (puntaje 85)
- **Buró:** DUDOSO, 3 entidades con deuda, deuda total S/ 25,000.00, 95 días de mayor mora

**Decisión del comité:** **RECHAZADO**

- **Motivo:** Calificación SBS **DUDOSO** con 95 días de mora vigente en 3 entidades: **no procede el otorgamiento**.
- **Acción:** **No se genera cronograma**.
- **Estado final:** Rechazado

---

## 📊 Resumen de Decisiones


| Tipo de Decisión  | Cantidad | Casos                                                              |
| ----------------- | -------- | ------------------------------------------------------------------ |
| **Aprobados**     | 24       | 1-24, 28-30 (excepto 25-27, 28-30)                                 |
| **Condicionados** | 3        | 25 (Filoctetes Cruz), 26 (Calirroe Mendoza), 27 (Tucídides Quispe) |
| **Rechazados**    | 3        | 28 (Aquiles Mamani), 29 (Medea Apaza), 30 (Esquines Rojas)         |


---

## 🔍 Notas Clave para el Docente

- **Casos diseñados para practicar ramas alternativas del flujo:**
  - **Caso 28 (Aquiles Mamani):** Bloqueado en consulta de buró por estar en **lista de inhabilitados**.
  - **Caso 29 (Medea Apaza):** Pre-evaluación **NO_PROCEDE** por capacidad de pago insuficiente.
  - **Caso 30 (Esquines Rojas):** Rechazado en comité por calificación **DUDOSO** con mora vigente.
  - **Casos 25-27:** **Condicionados** (monto reducido). Requiere recalcular la cuota sobre el **monto aprobado**, no sobre el solicitado.

---

## 📌 Instrucciones para el Estudiante

1. **Registrar la solicitud como cliente** en la **App Clientes** con los datos del caso.
2. **Verificar la recepción en el Core** y su asignación al asesor.
3. **Gestionar la cartera en la App Fuerza de Ventas** (visita, pre-evaluación, buró, documentos, firma).
4. **Enviar al comité** y registrar la decisión según el caso.
5. **Generar el cronograma** (si es aprobado/condicionado) o **cerrar el expediente** (si es rechazado).

---

**Documento original:** ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL  
**Adaptado a Markdown por Vibe**