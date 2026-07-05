# ESPECIFICACIÓN TÉCNICA DE SOFTWARE (BLUEPRINT): TAXCAL APP V2

## 1. Resumen de Negocio, Objetivos y Público Destino

El sistema "TaxCal App v2" es una aplicación móvil diseñada exclusivamente para contribuyentes mexicanos bajo el Régimen de Personas Físicas con Actividad Empresarial y Servicios Profesionales (Régimen 612 del SAT). Su objetivo es funcionar como una "interfaz espejo" contable, reproduciendo la lógica y campos del portal oficial de declaraciones del gobierno.
La herramienta opera bajo un estricto paradigma *Standalone* y *Local-First*. Al carecer de backend, elimina los riesgos de vulneración de credenciales sensibles (como la contraseña CIEC o archivos de e.firma) , devolviendo al usuario el control absoluto de sus proyecciones impositivas y el cálculo de sus flujos de efectivo antes de capturarlos manualmente en la plataforma del gobierno.

## 2. Arquitectura de Software de la App Móvil

El sistema será construido utilizando el framework multiplataforma Flutter, generando instaladores binarios nativos para iOS y Android.

* **Motor de Persistencia Local:** Se exige el uso del motor NoSQL **Isar Database** para un rendimiento óptimo de consultas en el dispositivo.

* **Esquema de Datos:** Las colecciones de Isar deben estar fuertemente tipadas, utilizando anotaciones `@Index(unique: true, replace: true)` en campos críticos como el UUID para evitar duplicidad de registros.

* **Gestión de Estado e Inyección de Dependencias:** Implementación estricta de **Riverpod** para la reactividad bidireccional entre la base de datos local y la interfaz de usuario.

* **Navegación:** Enrutamiento declarativo y tipado utilizando el paquete `go_router`.

* **Seguridad:** Aislamiento total de red. Prohibición explícita de integración de APIs externas o servicios en la nube para la sincronización de datos fiscales.

## 3. Pipeline Técnico de Entrada de Datos

El sistema debe ingerir Comprobantes Fiscales Digitales por Internet (CFDI XML v4.0) de forma local. Para evitar bloqueos del hilo principal (UI Thread) durante la importación masiva, el parseo de cadenas XML debe ejecutarse en procesos paralelos utilizando *Isolates* mediante la API `compute` de Dart.

* **Módulo de Selección de Archivos:** Integración de los paquetes `file_picker` para exploración de directorios y `receive_sharing_intent` para recibir archivos compartidos desde otras aplicaciones móviles.

* **Parseo XML:** Uso del paquete nativo `xml` en Dart.

* **Mapeo de Campos Obligatorios:** Extracción de Subtotal, Total, Fecha, MetodoPago, FormaPago, RFC del Emisor/Receptor, y el nodo de Impuestos (Traslados y Retenciones).

* **Extracción del Folio Fiscal:** Recuperación estricta del UUID ubicado en `Complemento.TimbreFiscalDigital.UUID`.

* **CRM Automático:** Al detectar un RFC en un XML que no exista en la colección local de "contribuyentes", el sistema ejecutará una inserción automática (*INSERT*) registrando al nuevo cliente o proveedor.

* **Clasificación de Flujo de Efectivo:** Si el XML posee el método "PUE", se asignará el estatus como "COBRADO" o "PAGADO" con la fecha de emisión. Si es "PPD", se catalogará como "PENDIENTE" a la espera de conciliación.

## 4. Especificación Detallada de Módulos y Pantallas (UI/UX)

La interfaz replicará la jerarquía visual del portal del SAT para minimizar la curva de aprendizaje, organizando el flujo en tres etapas: Configuración, Determinación y Pago.

* **Código de Colores SAT:** Los campos de captura obligatoria manual tendrán bordes en color rojo brillante. Los campos auto-calculados por el sistema tendrán fondo gris y estarán inhabilitados para edición.

* **Tablero Reactivo (Dashboard):** Selector de periodo mensual, indicadores clave de Ingresos Cobrados y Gastos Pagados, y una vista de previsualización dual para los cálculos provisionales de ISR e IVA.

* **Interruptor Dinámico de Deducibilidad:** Cada registro de egreso mostrará un control deslizante (*switch*). Al modificar su estado, la base de datos actualizará el valor de `es_deducible` y el motor de cálculo refrescará inmediatamente el ISR e IVA en pantalla.

* **Conciliación Manual de PPD:** Las facturas pendientes de cobro/pago presentarán un botón interactivo que desplegará un selector de fecha para asignar la fecha de pago efectivo, introduciendo la operación al cálculo del mes correspondiente.

* **Modo *Copy-Paste*:** Botón contextual flotante en los totales calculados para copiar valores al portapapeles del sistema operativo.

* **Generador de Papeles de Trabajo:** Integración del paquete `pdf` para dibujar reportes estructurados de la liquidación de impuestos, almacenándolos directamente en la carpeta de descargas del dispositivo local.


## 5. Motor de Cálculos y Reglas de Negocio Fiscales

Todos los cálculos operarán bajo el principio normativo de flujo de efectivo.

* **Acumulación de ISR:**

$$\text{Base Gravable Acumulada} = \text{Ingresos Cobrados Acumulados} - \text{Deducciones Autorizadas Acumuladas}$$

* **Tarifa Progresiva de ISR:** El sistema embeberá en formato JSON las tablas oficiales de límite inferior, porcentaje de excedente y cuota fija.

$$\text{ISR Bruto} = ((\text{Base Gravable Acumulada} - \text{Límite Inferior}) \times \text{\% Excedente}) + \text{Cuota Fija}$$

* **Determinación Definitiva de IVA:**


$$\text{IVA Causado (Cobrado)} = \sum \text{IVA en facturas de Ingreso con estatus\_pago = 'COBRADO'}$$


$$\text{IVA Acreditable (Pagado)} = \sum \text{IVA en facturas de Egreso con es\_deducible = 1 y estatus\_pago = 'PAGADO'}$$


* **Vencimientos Inteligentes:** El calendario de la aplicación calculará los límites de pago sumando días hábiles a partir del día 17 del mes posterior, basándose en el sexto dígito numérico del RFC del usuario (Ej. Dígitos 1 y 2 otorgan 1 día hábil extra), omitiendo fines de semana y días festivos de México.

## 6. Casos de Prueba, Gestión de Errores Críticos y Criterios de Aceptación Técnicos

* **Alerta de Bancarización:** Si el algoritmo detecta un CFDI de egreso superior a $2,000.00 MXN con la FormaPago "01 Efectivo", se detonará una advertencia visual de color amarillo indicando la invalidez de la deducción.

* **Protección de Duplicados:** La base de datos Isar debe rechazar o actualizar silenciosamente registros de CFDI importados más de una vez utilizando el UUID como llave primaria inmutable.

* **Requerimiento del Subsidio:** Los campos emulados del SAT en la sección de Subsidio al Empleo permitirán enviarse vacíos, evitando validaciones numéricas estrictas de "0" para replicar y sortear los *bugs* conocidos del portal gubernamental.


## 7. Declaraciones de Limitación y Exención de Responsabilidad Legal

La pantalla de *Onboarding* y el pie de página de los documentos PDF generados deberán incluir, sin excepción, la siguiente cláusula bloqueante:

> "Esta aplicación constituye únicamente una bitácora contable de uso privado y un simulador interactivo diseñado para facilitar la preparación visual de los datos fiscales. La herramienta carece de conexión, API o autorización formal por parte del Servicio de Administración Tributaria (SAT) o la Secretaría de Hacienda y Crédito Público. El cálculo de los impuestos simulados se realiza de forma indicativa basada en la interpretación de las guías de llenado del SAT. La presentación legal de las declaraciones y el cumplimiento de las obligaciones tributarias recaen bajo la estricta responsabilidad personal del contribuyente, quien deberá ingresar, validar y transmitir manualmente sus datos directamente en el sitio web oficial del SAT para la obtención del acuse de recibo y la línea de captura válidos."