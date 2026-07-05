# Handoff: TaxCal App v2 — Prototipo móvil

## Overview
Prototipo interactivo (HTML) de TaxCal App v2, una app móvil local-first para Personas Físicas del Régimen 612 (Actividad Empresarial y Servicios Profesionales) en México. Traduce el flujo de declaraciones del SAT a un lenguaje simple para profesionistas independientes no técnicos. Cubre 5 pantallas: Tablero, Facturas, Espejo SAT, Anual y Configuración, más flujos de importación de XML, recordatorios de conciliación PPD y onboarding legal.

## About the Design Files
Los archivos de este paquete son **referencias de diseño construidas en HTML/React** (un prototipo funcional, no código de producción). El objetivo es **recrear este diseño en Flutter** (con Riverpod, según indica la especificación técnica adjunta), replicando layout, estados, copy y lógica de negocio — no portar el HTML/JS literalmente. Usa los widgets y patrones nativos de Flutter para lograr el mismo resultado visual y funcional.

## Fidelity
**Alta fidelidad (hifi).** Colores, tipografía, espaciados y copy están definidos y deben respetarse tal como aparecen en el prototipo y en el Manual de Branding adjunto. Los montos y nombres de contribuyentes son datos ficticios de ejemplo — la fuente real vendrá del parseo de CFDIs en producción.

## Documentos de referencia (fuente de verdad)
Incluidos en `docs/`:
- `ESPECIFICACIÓN FUNCIONAL Y DE DISEÑO DE DATOS.md` — arquitectura de navegación, modelo de datos (`facturas`, `contribuyentes`, `inversiones`), pipeline de ingesta XML CFDI 4.0, motor de cálculo de ISR/IVA, reglas de bancarización y vencimientos.
- `Manual de Branding y Sistema de Identidad Visual.md` — paleta de colores, tipografía, tono de voz, especificaciones de theming Flutter.
- `ESPECIFICACIÓN TÉCNICA DE SOFTWARE.md` — arquitectura técnica.

El prototipo HTML es una interpretación visual/interactiva de estos documentos; ante cualquier duda de cálculo fiscal o modelo de datos, estos documentos son la autoridad.

## Screens / Views

### 1. Onboarding
- **Purpose:** Bloquea el uso de la app hasta que el usuario acepte el aviso legal (sección 6.4 de la especificación funcional).
- **Layout:** Pantalla completa dentro del frame del teléfono, 2 pasos secuenciales (Intro → Aviso legal), fondo `#1A1A1A`.
- **Paso 1 — Intro:** ícono de marca (80×80, `#2A2A2A`, radio 20px), título "TaxCal" (26px/700, blanco), descripción (15px, blanco 55% opacidad), botón "Siguiente" (verde `#00CC44`, texto `#0d1a10`, radio 13px).
- **Paso 2 — Aviso legal:** título "Antes de empezar" (22px/700), tarjeta con el texto legal completo (13px/1.6, `#2A2A2A`), checkbox obligatorio "He leído y entiendo…", botón "Aceptar y continuar" deshabilitado (`#3A3A3A`) hasta marcar el checkbox, luego verde.
- **Persistencia:** la aceptación se guarda en `localStorage` (equivalente: SharedPreferences/Hive en Flutter) para no repetirse en sesiones futuras.

### 2. Tablero (Dashboard)
- **Purpose:** Radiografía rápida de la salud fiscal del mes activo.
- **Layout:** Header con selector de mes (chip + chevron, abre bottom sheet) y campanita de recordatorios con badge; scroll vertical de tarjetas.
- **Componentes:**
  - 2 KPIs lado a lado: "Ingresos cobrados" (verde `#3DDC7A`) y "Gastos deducibles" (blanco), cada uno con contador de comprobantes.
  - Tarjeta "Utilidad del mes" (auto-calculada, ingresos − gastos).
  - Tarjeta "Impuestos proyectados": ISR provisional (naranja `#FF9142`) e IVA definitivo (naranja si a cargo, verde si a favor).
  - Estado vacío: mensaje centrado si no hay facturas en el mes.
  - Disclaimer inferior: "Cálculo simplificado para este prototipo…"

### 3. Facturas
- **Purpose:** Libro diario de CFDIs (ingresos y egresos) con control de deducibilidad y conciliación de flujo de efectivo.
- **Layout:** Header + campanita, segmented control Ingresos/Gastos, buscador (RFC/nombre/folio), resumen de total del filtro activo, lista de tarjetas, FAB verde circular (+) fijo abajo-derecha para importar XML.
- **Tarjeta de factura:**
  - Fila superior: razón social (15.5px/600) + RFC/folio en mono (12px) — total en mono (17px/700) + fecha.
  - Badge de estatus: verde "✓ Cobrado/Pagado" (PUE o PPD ya conciliado), naranja "Pendiente de cobro/pago ›" (PPD sin conciliar, tappable → abre modal).
  - Switch "Deducible" (solo egresos): pista `#3A3A3A`→`#00CC44`, transición **200ms lineal** (regla obligatoria del Manual de Branding, sección 6).
  - Alerta de bancarización: banner naranja si `forma_pago = 01` (efectivo) y `subtotal > $2,000` — copy exacto: "Pagaste en efectivo más de $2,000 pesos. El SAT lo va a rechazar…"
- **Modal de conciliación PPD:** bottom sheet con nombre/monto de la factura, date picker nativo, botón verde "Sumar al mes correspondiente".

### 4. Espejo SAT
- **Purpose:** Formulario que replica el orden exacto de campos del portal oficial del SAT (Configuración → Determinación → Pago), en la estética oscura de TaxCal.
- **Layout:** Stepper de 3 pasos (segmented control), dentro de Determinación un sub-tab ISR Propio / IVA Definitivo.
- **Paso 1 — Configuración:** periodo (solo lectura), tipo de declaración Normal/Complementaria (segmented), pregunta de copropiedad (switch), tal como la formula el SAT.
- **Paso 2 — Determinación:** cada campo es una tarjeta `#2A2A2A`:
  - **Auto-calculado:** fondo `#1A1A1A`, texto blanco 60% opacidad, con botón "Detalle" que abre un bottom sheet listando las facturas que integran la suma.
  - **Manual (captura obligatoria):** input con **borde rojo `#FF3333`, 1.5px** (regla del Manual de Branding).
  - **Campo especial "Subsidio al empleo":** se muestra intencionalmente vacío, con el copy exacto del bypass documentado en la sección 6.3 de la especificación funcional.
  - **Campo final (ISR a cargo / IVA neto):** tipografía grande mono, color según signo, botón "Copiar" (clipboard) con feedback "¡Copiado!" — implementa el botón flotante Copy-Paste del módulo Espejo SAT.
- **Paso 3 — Pago:** resumen de ISR + IVA, total a pagar, fecha límite estimada, aviso legal colapsable.

### 5. Anual
- **Purpose:** Simulador de cierre del ejercicio fiscal.
- **Componentes:**
  - KPIs de ingresos/gastos del año.
  - Gráfico de barras mensual (Ingresos verde `#00CC44` vs. Gastos naranja `#FF6600`), 12 columnas.
  - Alerta de bancarización anual: tarjeta naranja resumiendo los gastos del año que no cumplieron la regla de efectivo >$2,000 (o confirmación verde si todos cumplen).
  - Bolsa de deducciones personales: lista editable (agregar/eliminar), tope global = mín(15% de ingresos anuales, 5 UMA anual — estimado), barra de progreso, badge verde/rojo "Deducible" / "No deducible · pagado en efectivo" (con excepción de gastos funerarios vía checkbox).
  - Simulador de saldo a favor/cargo anual con desglose.

### 6. Configuración
- **Purpose:** Perfil fiscal y mantenimiento de la base de datos local.
- **Componentes:** Nombre y RFC del contribuyente (con validación de longitud 12/13 y helper de tipo de persona), tarjeta de plazo límite de pago (calculado por el 6° dígito del RFC, según algoritmo de la sección 6.2 de la especificación funcional — este prototipo omite el ajuste de fines de semana/feriados, que sí debe implementarse en producción), contadores de la base local (contribuyentes/ingresos/gastos), aviso legal colapsable, botón "Borrar todos los datos" con modal de confirmación.

### Flujo de importación XML (accesible desde el FAB en Facturas)
- Bottom sheet con 2 opciones: seleccionar archivos `.xml` reales (el prototipo los lee y parsea con `DOMParser` en el navegador, extrayendo `SubTotal`, `Total`, `Fecha`, `MetodoPago`, `FormaPago`, `Folio`, `Emisor`/`Receptor`, `UUID` del Timbre Fiscal Digital) o "usar 3 facturas de ejemplo" para probar sin archivos reales.
- Clasificación: compara el RFC emisor/receptor del CFDI contra el RFC del contribuyente (Configuración) para determinar Ingreso vs. Egreso.
- Estados por archivo: "Leyendo…" → "✓ Listo" / "No se pudo leer".
- Pantalla de resumen: contadores de ingresos/gastos/nuevos contribuyentes importados, con manejo de errores si algún XML no es un CFDI válido.

### Recordatorios de conciliación PPD
- Campanita con badge (contador) en Tablero y Facturas.
- Bottom sheet listando todas las facturas PPD pendientes, ordenadas por antigüedad, con color de urgencia (blanco → naranja → rojo según días de espera) y botón "Conciliar ahora" que abre directamente el modal de conciliación de la factura correspondiente.

## Interactions & Behavior
- Navegación por bottom nav de 5 íconos (Tablero, Facturas, Espejo SAT, Anual, Configuración) — persistente, no hay stack de navegación tradicional (arquitectura SPA descrita en la especificación funcional).
- El selector de mes/año es compartido entre Tablero y Facturas; cambiar de mes recalcula reactivamente ambas pantallas (patrón a replicar con Riverpod providers).
- Todas las transiciones de switches/toggles: **200ms, easing lineal** (regla mandatoria del Manual de Branding).
- Copiar al portapapeles: feedback textual temporal (~1.5s) en el botón, luego vuelve a su estado normal.
- Modales y bottom sheets: fondo oscuro semitransparente (`rgba(0,0,0,0.55–0.6)`), tap fuera para cerrar, radio superior 22px.
- No hay estados de error de red (la app es local-first, sin llamadas a servidor).

## State Management
Variables de estado principales a replicar como providers/notifiers en Riverpod:
- `activeTab`, `monthIndex` (0–11, año fijo 2026 en el prototipo — en producción debe permitir cambiar de año).
- `invoices`: colección reactiva de facturas (equivalente a la tabla `facturas` de la especificación de datos).
- `filter` (Ingresos/Gastos), `search` (texto libre).
- `modalId` / `pendingDate`: estado del modal de conciliación PPD.
- `espejoStep`, `espejoSubtab`, más los campos manuales de captura (PTU, pérdidas fiscales, pagos provisionales, saldo a favor IVA anterior).
- `personalDeductions`: colección de deducciones personales del ejercicio.
- `onboardingActive` / aceptación persistida localmente.
- `uploadStage` (idle/processing/summary) para el flujo de importación XML.

## Design Tokens
**Colores** (ver Manual de Branding para el detalle completo):
- Fondo primario: `#1A1A1A` — Superficies/tarjetas: `#2A2A2A` — Superficie elevada/inputs: `#1A1A1A` con borde `rgba(255,255,255,0.12)`
- Texto principal: `#FFFFFF` — Texto secundario: `rgba(255,255,255,0.4–0.55)`
- Acento primario (positivo): `#00CC44` (con variante de texto `#3DDC7A` sobre fondo oscuro)
- Acento secundario (alertas/interacción): `#FF6600` (variante de texto `#FF9142` / `#FFB27A`)
- Alerta/captura obligatoria: `#FF3333` (bordes de campos manuales)
- Error/no deducible: `#FF6B6B`

**Tipografía:** Geist (prosa/navegación) y Geist Mono (cifras, folios, RFC) — ver sección 3 del Manual de Branding. Tamaños usados: 30px/700 (títulos de pantalla), 17–22px/700 (montos destacados), 13–15.5px/500–700 (cuerpo/controles), 10.5–12.5px (labels/ayuda).

**Radios:** tarjetas 14–16px, inputs/botones 9–13px, bottom sheets 22px (esquinas superiores), badges/pills 7–12px, FAB 26px (circular), toggles 12–13px (pill).

**Espaciado:** padding de pantalla 20px horizontal, gap entre tarjetas 10–14px, padding interno de tarjeta 13–16px.

## Assets
- Ícono de app: preservar el ícono original v1 (factura + calculadora) tal como indica la sección 2.1 del Manual de Branding — no se debe rediseñar. Ubicado en `assets/icon.png` de este paquete.
- No hay ilustraciones ni fotografías; toda la UI es tipografía + color + iconografía SVG lineal simple (íconos de bottom nav, búsqueda, campana, importación, etc. — recrear con el set de íconos que uses en Flutter, p. ej. Material Symbols o un set custom con el mismo peso de línea ~2px).

## Files
- `TaxCal_Prototipo.html` — prototipo interactivo completo, autocontenido (ábrelo directamente en un navegador). Contiene las 6 pantallas/flujos descritos arriba con datos de ejemplo. **No copiar este código a Flutter** — es la referencia visual e interactiva a recrear.
- `docs/` — especificaciones funcional, técnica y de branding originales (fuente de verdad para reglas de negocio y cálculo fiscal).
- `assets/icon.png` — ícono de marca original a preservar.
