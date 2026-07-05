# ESPECIFICACIÓN FUNCIONAL Y DE DISEÑO DE DATOS: TAXCAL APP V2

Este documento técnico describe las especificaciones lógicas, la arquitectura de datos, el flujo de navegación, los módulos de pantalla y el motor de cálculos fiscales del prototipo **TaxCal App v2**, diseñado específicamente para Personas Físicas con Actividad Empresarial y Servicios Profesionales (Régimen 612 del SAT en México).

## 1. Arquitectura de Navegación General

La aplicación está diseñada bajo el paradigma de una sola página (SPA) con navegación persistente a través de una barra inferior (_Bottom Navigation Bar_). No requiere autenticación en la nube al operar bajo una arquitectura _Local-First_ con base de datos descentralizada.

### 1.1 Barra de Navegación Principal (Nodos de Destino)

1. **Tablero (Dashboard):** Vista consolidada de la salud financiera del mes activo y proyecciones rápidas de impuestos de flujo de efectivo.
    
2. **Facturas:** Gestor reactivo de comprobantes fiscales (Ingresos y Egresos) con controles de deducibilidad y conciliación.
    
3. **Espejo SAT:** Formulario interactivo estructurado idénticamente a las declaraciones provisionales de pago del portal oficial del SAT.
    
4. **Anual:** Simulador acumulativo del ejercicio fiscal para la determinación del ISR anual y aplicación de deducciones personales.
    
5. **Configuración (Config):** Gestión de variables informativas del perfil fiscal y utilitarios de la base de datos persistente.
    

### 1.2 Flujo Secuencial de Declaración (Sub-Navegación Espejo)

Dentro de la pantalla de **Espejo SAT**, el usuario transiciona de manera horizontal y secuencial por las tres fases requeridas por el flujo de presentación del portal oficial:

1. **Configuración:** Validación del periodo y tipo de declaración (Normal/Complementaria).
    
2. **Determinación:** Sección de cálculo aritmético donde se subdivide en dos sub-pestañas:
    
    - **ISR Propio:** Liquidación acumulada del Impuesto Sobre la Renta.
        
    - **IVA Definitivo:** Determinación mensual neta del Impuesto al Valor Agregado.
        
3. **Pago / Línea:** Resumen final de importes a liquidar y compensaciones.
    

## 2. Definición Detallada de Pantallas (Módulos de la UI)

### 2.1 Módulo 1: Tablero Principal (Dashboard)

El Tablero provee una radiografía inmediata de la situación fiscal del contribuyente basada exclusivamente en las facturas conciliadas y cobradas dentro del mes seleccionado en el encabezado global.

#### Elementos y Componentes Operativos:

- **Selector de Periodo Activo:** Menú desplegable con los 12 meses del ejercicio fiscal 2026. Al cambiar el periodo, se emite un evento que recalcula de manera reactiva toda la base de datos para actualizar las métricas del tablero.
    
- **Tarjeta KPI de Ingresos Cobrados:** Muestra el acumulado de ingresos del mes que ya han sido efectivamente cobrados (Facturas PUE o PPD con pago asociado). Muestra un contador secundario con el número de comprobantes XML procesados que integran la suma.
    
- **Tarjeta KPI de Gastos Deducibles:** Muestra la suma de erogaciones que han sido marcadas como deducibles por el usuario y que ya fueron efectivamente pagadas. Muestra un contador de comprobantes válidos.
    
- **Tarjeta de Utilidad Operativa del Mes:** Campo autocalculado que resta el total de gastos deducibles a los ingresos efectivamente cobrados.
    
- **Sección de Impuestos Proyectados:** Presenta dos renglones de pre-cálculo rápido:
    
    - **Proyección de ISR Provisional:** Muestra la estimación del pago provisional del mes aplicando la base gravable acumulada anual contra la tarifa progresiva de la LISR.
        
    - **Proyección de IVA Definitivo:** Muestra el neto de IVA a cargo o saldo a favor, restando el IVA acreditable y retenido al IVA cobrado en el periodo.
        

### 2.2 Módulo 2: Registro de Facturas (Ingresos y Gastos)

Este módulo se comporta como un libro diario digital reactivo. Permite auditar y modificar el comportamiento fiscal de los XMLs parseados localmente.

#### Componentes de la Interfaz:

- **Filtro de Tipo de Comprobante:** Selector binario para alternar la vista entre el listado de _Ingresos Cobrados_ y _Gastos Deducibles_.
    
- **Buscador de Texto Completo:** Barra de búsqueda que filtra en tiempo real por coincidencia parcial de texto en los campos de: RFC del emisor, RFC del receptor, Nombre/Razón Social, Folio Interno o UUID.
    
- **Tarjetas de Comprobante Dinámicas:** Despliegan la información individual del XML estructurada de la siguiente manera:
    
    - _Cabecera:_ Razón social y RFC del tercero. Monto del subtotal e IVA desglosado.
        
    - _Pie:_ Folio de la factura, fecha de emisión (AAAA-MM-DD).
        
    - _Control de Deducibilidad (Exclusivo de Gastos):_ Un switch interactivo que altera el estado `es_deducible` del registro de la base de datos. Si se desactiva, la factura se excluye automáticamente de la suma de deducciones mensuales del tablero y del Espejo SAT, disparando un recálculo en segundo plano.
        
    - _Etiquetas de Conciliación de Flujo de Efectivo:_ * Si la factura es de método **PUE**, muestra de manera inmutable la etiqueta "PUE" y asume el flujo de efectivo el mismo día de su emisión.
        
        - Si la factura es de método **PPD**, muestra el estado de cobro/pago. Si está pendiente, habilita un botón para abrir el modal de conciliación de pago.
            
- **Modal de Conciliación PPD:** Solicita al usuario ingresar la fecha real de cobro/pago efectivo (`fecha_pago_efectivo`) mediante un selector de fecha del sistema operativo. Al confirmar, el comprobante se acumula para los cálculos del mes correspondiente a dicha fecha, resolviendo el desfase del prellenado del SAT.
    

### 2.3 Módulo 3: Directorio Fiscal (CRM)

Directorio offline que almacena la información fiscal de clientes y proveedores identificados en los CFDIs cargados en el sistema.

#### Funcionalidades:

- **Lista de Terceros:** Muestra de manera ordenada el nombre del contribuyente, su RFC y su tipo de persona (Física o Moral de acuerdo a la longitud de caracteres de su RFC: 13 para física, 12 para moral).
    
- **Filtro de Búsqueda:** Búsqueda rápida por nombre o RFC.
    
- **Creación Automática:** No requiere captura manual; el procesador XML asume la tarea de poblar este catálogo al detectar nuevos RFCs emisores o receptores en el flujo de entrada.
    

### 2.4 Módulo 4: Espejo SAT (Formulario de Determinación)

Esta pantalla reproduce de manera exacta los campos obligatorios y la lógica aritmética del portal oficial de declaraciones provisionales del SAT.

#### Código Lógico de Campos por Colores (Sin implicaciones visuales):

- **Campos Requeridos (Borde Rojo):** Inputs habilitados para edición manual donde el contribuyente debe ingresar información que no reside típicamente en los CFDIs (por ejemplo, pérdidas fiscales de ejercicios anteriores o PTU pagada).
    
- **Campos Auto-calculados (Fondo Gris Deshabilitado):** Inputs de lectura obligatoria bloqueados por el sistema, cuyo valor es el resultado exacto de las agregaciones de la base de datos local o las fórmulas fiscales.
    

#### Características de UX Fiscal:

- **Botones "Detalle" (Modales de Origen):** Ubicados junto a los campos de _Ingresos del periodo_ y _Compras y gastos del periodo_. Al ser presionados, despliegan un modal emergente que lista únicamente las facturas (folio, emisor, subtotal) que componen la suma exacta del campo, permitiendo auditar el prellenado.
    
- **Botón Flotante "Copy-Paste":** Al colocarse sobre cualquier total autocalculado, se habilita un control para copiar el valor numérico con dos decimales directamente al portapapeles, facilitando el vaciado manual de datos hacia el portal del SAT abierto en el navegador.
    

### 2.5 Módulo 5: Cierre y Declaración Anual

Simulador preventivo anual que ayuda al contribuyente a calcular su impuesto consolidado del ejercicio y optimizar su saldo a favor mediante la aplicación de deducciones personales.

#### Componentes:

- **Bolsa de Deducciones Personales:** Listado de gastos del contribuyente clasificados bajo el Artículo 151 de la LISR (gastos médicos, dentales, seguros, colegiaturas).
    
- **Gráfico de Tendencia Fiscal:** Gráfico de barras mensualizado que compara visualmente los ingresos percibidos versus los gastos deducibles de los 12 meses del año.
    
- **Simulador de Saldo a Favor / Cargo (Anual):** Aplica la tarifa anual consolidada del artículo 152 de la LISR y determina de forma proyectada si el contribuyente obtendrá una devolución de impuestos o saldo a cargo al finalizar el año.
    

### 2.6 Módulo 6: Configuración del Perfil

Sección de administración del sistema y mantenimiento de la base de datos local.

#### Campos de Entrada Informativos:

- **Nombre del Contribuyente:** Nombre completo de la Persona Física.
    
- **RFC del Contribuyente:** Clave de Registro Federal de Contribuyentes (13 caracteres obligatorios para persona física). Este campo es el núcleo para el algoritmo de vencimientos y plazos de pago.
    
- **Visualizador del Estado de la Base de Datos:** Contadores que muestran en tiempo real el número de registros guardados físicamente en las colecciones locales de CRM, Ingresos y Egresos.
    
- **Botón "Borrar Todo":** Evento de purga completa que borra la base de datos local para inicializar el sistema desde cero.
    

## 3. Modelo y Estructura de la Base de Datos Local

La persistencia del sistema opera de manera offline-first. Los tipos de datos descritos a continuación representan la especificación estricta de base de datos relacional (o NoSQL estructurada con índices).

### 3.1 Colección / Tabla: `contribuyentes` (CRM)

Guarda la información de clientes, proveedores y terceros detectados.

|

| **Campo** | **Tipo de Datos** | **Restricciones / Índices** | **Descripción** |

| `rfc` | String (TEXT) | PRIMARY KEY, Único | RFC de 12 o 13 caracteres, sin guiones ni espacios. |

| `razon_social` | String (TEXT) | NOT NULL | Nombre o Razón Social oficial registrada ante el SAT. |

| `tipo_persona` | String (TEXT) | CHECK ('FISICA', 'MORAL') | Clasificación según la longitud del RFC. |

| `creado_en` | DateTime (TIMESTAMP) | Default: CURRENT_TIMESTAMP | Marca de tiempo de la inserción en la base de datos. |

### 3.2 Colección / Tabla: `facturas`

Almacena el desglose estructurado extraído de los archivos XML CFDI 4.0.

| **Campo** | **Tipo de Datos** | **Restricciones / Índices** | **Descripción** |

| `uuid` | String (TEXT) | PRIMARY KEY, Único | Folio Fiscal Universal SAT (Timbre Fiscal Digital). |

| `folio_interno` | String (TEXT) | Nullable | Serie o número interno de control de facturación. |

| `fecha_emision` | DateTime (DATETIME) | NOT NULL | Fecha y hora en que se timbró el CFDI. |

| `fecha_pago_efectivo` | DateTime (DATETIME) | Nullable, INDEX | Fecha en que ocurrió el flujo bancario real. |

| `rfc_emisor` | String (TEXT) | FOREIGN KEY ➔ `contribuyentes(rfc)` | RFC del emisor del comprobante. |

| ..._receptor | String (TEXT) | FOREIGN KEY ➔ `contribuyentes(rfc)` | RFC del receptor del comprobante. |

| `tipo_cfdi` | String | CHECK ('INGRESO', 'EGRESO', 'PAGO') | Tipo de comprobante. |

| `subtotal` | Double / Decimal | No Nulo, escala (18,2) | Base gravable para el cálculo del IVA e ISR. |

| `tasa_iva` | Double | Default: 16.00 (admite 0 o exento) | Tasa impositiva aplicada a la operación. |

| `iva_trasladado` | Double | Default: 0.00 | IVA calculado de la operación. |

| `iva_retenido` | Double | Default: 0.00 | Retención de IVA (2/3 partes para honorarios PM). |

| `isr_retenido` | Double | Default: 0.00 | Retención de ISR (10% en servicios profesionales). |

| `total` | Double / Decimal | No Nulo, escala (18,2) | Importe neto total de la factura. |

| `metodo_pago` | String | CHECK ('PUE', 'PPD') | Método de pago oficial SAT. |

| `forma_pago` | String (TEXT) | NOT NULL | Código numérico SAT de forma de pago (01, 03, 04, etc.) |

| `es_deducible` | Integer / Boolean | Default: 1 (CHECK 0 o 1) | Bit de control para el motor de cálculo de ISR. |

| `estatus_pago` | String | CHECK ('PENDIENTE', 'COBRADO', 'PAGADO') | Estado del flujo del efectivo para conciliación. |

### 3.3 Colección / Tabla: `inversiones` (Activos Fijos)

Permite gestionar la depreciación progresiva mensual de activos fijos.

| **Campo** | **Tipo de Datos** | **Restricciones / Índices** | **Descripción** |

| `id` | Integer | PRIMARY KEY, AUTOINCREMENT | Identificador único interno. |

| `uuid_factura` | String (TEXT) | UNIQUE, FOREIGN KEY | Enlace al registro original de la factura. |

| `tipo_activo` | String | CHECK ('COMPUTO', 'MOBILIARIO', 'AUTO_COMBUSTION', 'AUTO_HIBRIDO', 'PICKUP') | Determina la tasa de depreciación máxima anual. |

| `monto_original` | Double / Decimal | NOT NULL | Monto original de la inversión (Subtotal de la factura). |

| `pct_depreciacion` | Double | NOT NULL | Porcentaje de depreciación anual según la LISR. |

| `fecha_adquisicion` | DateTime | NOT NULL | Fecha de compra del activo. |

## 4. Pipeline Técnico de Ingesta y Clasificación de XML (CFDI 4.0)

Cuando el usuario carga o importa de manera local un lote de CFDIs XML v4.0, el procesador offline ejecuta de manera síncrona/concurrente los siguientes pasos en hilos independientes (_Isolates_):

1. **Parseo y Extracción de Nodos:**
    
    - Busca los atributos principales del nodo raíz `<cfdi:Comprobante>`: `SubTotal`, `Total`, `Fecha`, `MetodoPago`, `FormaPago`, `Folio`.
        
    - Extrae el RFC y Nombre de los nodos `<cfdi:Emisor>` y `<cfdi:Receptor>`.
        
    - Extrae el Folio Fiscal del nodo de firma `<tfd:TimbreFiscalDigital>` atributo `UUID`.
        
    - Extrae los importes de traslados y retenciones del nodo `<cfdi:Impuestos>`.
        
2. **Registro Automático de Contribuyentes (CRM Offline):**
    
    - El sistema verifica si el RFC de la contraparte (Receptor si la factura es de ingreso, Emisor si es de egreso) existe en la tabla `contribuyentes`.
        
    - Si no existe, realiza un `INSERT` en caliente guardando el RFC y la Razón Social de manera automática para poblar el directorio.
        
3. **Mapeo del Flujo de Efectivo:**
    
    - El sistema evalúa el atributo `MetodoPago`:
        
        - **PUE (Pago en una Sola Exhibición):** Asigna de manera automática el `estatus_pago = 'COBRADO'` (para ingresos) o `'PAGADO'` (para egresos) y establece la `fecha_pago_efectivo = fecha_emision`. El comprobante impacta de inmediato en los cálculos del mes de emisión.
            
        - **PPD (Pago en Parcialidades o Diferido):** Asigna el `estatus_pago = 'PENDIENTE'` y deja la `fecha_pago_efectivo = NULL`. La factura se aísla de los cálculos mensuales de impuestos hasta que el usuario realice la conciliación de flujo de efectivo registrando el pago correspondiente.
            
4. **Clasificación Inteligente de Gastos:**
    
    - El motor local audita el nodo de uso de comprobante (`UsoCFDI`) y la clave de producto y servicio (`ClaveProdServ`) para determinar si corresponde a un activo de inversión o gasto corriente. Si corresponde a un activo fijo, inserta un registro en la tabla `inversiones` para aplicar depreciación progresiva mensual automática.
        

## 5. Motor de Cálculos y Reglas de Negocio Fiscales

Todos los cálculos contables implementados operan de manera estricta bajo el **principio de flujo de efectivo** para el Régimen 612.

### 5.1 Algoritmo de Cálculo de ISR Provisional Mensual (Acumulado)

El cálculo del pago provisional de ISR es acumulativo a lo largo del ejercicio fiscal:

1. **Agregación de Ingresos Acumulados:**
    
    $$\text{Ingresos Cobrados Acumulados} = \sum \text{subtotal en ingresos del mes activo} + \sum \text{ingresos de meses anteriores del mismo ejercicio}$$
2. **Agregación de Gastos Acumulados:**
    
    $$\text{Deducciones Autorizadas Acumuladas} = \sum \text{subtotal en egresos marcados con es\_deducible = 1} + \sum \text{egresos deducibles de meses anteriores}$$
3. **Determinación de la Base Gravable:**
    
    $$\text{Base Gravable Acumulada} = \text{Ingresos Cobrados Acumulados} - \text{Deducciones Autorizadas Acumuladas} - \text{PTU Pagada} - \text{Pérdidas Fiscales de Ejercicios Anteriores}$$
4. **Aplicación de la Tarifa Progresiva (Art. 96 LISR):**
    
    - El sistema multiplica de manera dinámica los rangos del límite inferior, superior y la cuota fija de la tarifa de Enero de 2026 por el factor del mes activo (por ejemplo, si se simula Junio, las constantes de la tarifa base se multiplican por 6).
        
    - Se ubica el renglón correspondiente a la base gravable acumulada:
        
        $$\text{Excedente del Límite Inferior} = \text{Base Gravable Acumulada} - \text{Límite Inferior Escalado}$$$$\text{Impuesto Marginal} = \text{Excedente del Límite Inferior} \times \frac{\text{Porcentaje de Excedente}}{100}$$$$\text{ISR Causado} = \text{Impuesto Marginal} + \text{Cuota Fija Escalada}$$
5. **Determinación del Impuesto Neto a Cargo:**
    
    $$\text{ISR a Cargo} = \text{ISR Causado} - \text{Pagos Provisionales anteriores declarados} - \text{ISR Retenido acumulado}$$

### 5.2 Algoritmo de Determinación de IVA Mensual (Definitivo)

A diferencia de ISR, el IVA se liquida de forma definitiva mes con mes bajo flujo de efectivo no acumulativo:

1. **IVA Cobrado (Tasa 16%):**
    
    $$\text{IVA Cobrado} = \sum \text{iva\_trasladado de ingresos con estatus\_pago = 'COBRADO' y tasa\_iva = 16.00}$$
2. **IVA Acreditable (Pagado Tasa 16%):**
    
    $$\text{IVA Acreditable} = \sum \text{iva\_trasladado de egresos con es\_deducible = 1, estatus\_pago = 'PAGADO' y tasa\_iva = 16.00}$$
3. **Determinación de Impuesto Neto o Saldo a Favor:**
    
    $$\text{Impuesto Neto} = \text{IVA Cobrado} - \text{IVA Acreditable} - \text{IVA Retenido del Periodo} - \text{Saldo a Favor de Periodos Anteriores Acreditado}$$
    - Si el resultado es positivo: Se determina como **IVA a Cargo del Periodo**.
        
    - Si el resultado es negativo: Se determina como **Saldo a Favor de IVA del Periodo** y se registra localmente en el histórico del periodo para habilitar el acreditamiento subsecuente.
        

### 5.3 Bolsa de Deducciones Personales (Anual)

Para la simulación del cierre del ejercicio en la pestaña **Anual**, el sistema clasifica y valida los gastos personales bajo el Artículo 151 de la LISR:

- **Fórmula de Validación del Límite Global de Deducciones:**
    
    $$\text{Límite Global Anual} = \text{Mínimo}\left(15\% \text{ de los Ingresos Totales del Ejercicio}, \ 5 \text{ UMAS Anuales}\right)$$
- **Reglas de Medios de Pago:** El sistema audita el campo `forma_pago` de cada XML de deducción personal. Si la clave es `01` (Efectivo), el registro se marca de manera automática como **No Deducible** (excepto para gastos funerarios `D03`), ya que la Ley de ISR invalida las deducciones personales pagadas en efectivo.
    

## 6. Sistema de Alertas, Validaciones y Exención de Responsabilidad

Para asegurar el cumplimiento contable y la protección del contribuyente, la aplicación ejecuta validaciones lógicas pasivas basadas en la información local:

### 6.1 Alerta de Bancarización de Egresos en Efectivo

- **Condición de Disparo:** Se evalúa de manera automática cada comprobante de egreso (`tipo_cfdi = 'EGRESO'`). Si el campo `subtotal` es mayor a $\$2,000.00\text{ MXN}$ y el campo `forma_pago` es igual a `"01"` (Efectivo), el sistema marca el comprobante con una alerta de advertencia crítica de color amarillo indicando que el gasto carece de deducibilidad legal para ISR e IVA por incumplir las reglas de bancarización obligatoria del SAT.
    

### 6.2 Algoritmo de Vencimientos y Plazos de Pago Inteligente

El plazo límite oficial para el pago de declaraciones provisionales mensuales es el día 17 del mes posterior. Sin embargo, la aplicación calcula con precisión el plazo extendido sumando días hábiles adicionales según el sexto dígito numérico de la clave del RFC ingresada en el perfil del contribuyente:

- **Asignación de Días Adicionales:**
    
    - Dígito sexto es `1` o `2` ➔ $+1$ día hábil adicional (Plazo límite real: día 18 o siguiente día hábil).
        
    - Dígito sexto es `3` o `4` ➔ $+2$ días hábiles adicionales (Plazo límite real: día 19 o siguiente día hábil).
        
    - Dígito sexto es `5` o `6` ➔ $+3$ días hábiles adicionales (Plazo límite real: día 20 o siguiente día hábil).
        
    - Dígito sexto es `7` o `8` ➔ $+4$ días hábiles adicionales (Plazo límite real: día 21 o siguiente día hábil).
        
    - Dígito sexto es `9` o `0` ➔ $+5$ días hábiles adicionales (Plazo límite real: día 24 o siguiente día hábil).
        
- **Omisión de Fines de Semana y Feriados:** El algoritmo recorre de forma secuencial la fecha sumando los días adicionales. Si el día de vencimiento resultante coincide con un día del fin de semana (Sábado o Domingo) o con alguno de los días feriados oficiales de México (01 de enero, primer lunes de febrero, tercer lunes de marzo, 01 de mayo, 16 de septiembre, tercer lunes de noviembre o 25 de diciembre), se traslada de manera automática al siguiente día hábil disponible en el calendario financiero mexicano.
    

### 6.3 Requerimiento del Subsidio al Empleo (Bypass de Validación)

- **Condición de Entrada:** Para evitar errores lógicos de validación comunes en el portal del SAT cuando la persona física no cuenta con personal subordinado a su cargo, el formulario Espejo SAT para el Subsidio al Empleo permite enviar el campo de entrada completamente vacío. El sistema inhibe la asignación de un carácter `"0"`, enviando el campo en blanco y emitiendo un aviso preventivo para sortear los bugs del aplicativo de la plataforma oficial de la autoridad tributaria.
    

### 6.4 Cláusula Bloqueante de Exención de Responsabilidad Legal

La aplicación despliega de manera obligatoria en su primera pantalla de inicio y en la estructura de los reportes de trabajo generados en formato PDF el siguiente texto legal de descargo de responsabilidad para delimitar el alcance del software:

> "Esta aplicación constituye únicamente una bitácora contable de uso privado y un simulador interactivo diseñado para facilitar la preparación visual de los datos fiscales. La herramienta carece de conexión, API o autorización formal por parte del Servicio de Administración Tributaria (SAT) o la Secretaría de Hacienda y Crédito Público. El cálculo de los impuestos simulados se realiza de forma indicativa basada en la interpretación de las guías de llenado del SAT. La presentación legal de las declaraciones y el cumplimiento de las obligaciones tributarias recaen bajo la estricta responsabilidad personal del contribuyente, quien deberá ingresar, validar y transmitir manualmente sus datos directamente en el sitio web oficial del SAT para la obtención del acuse de recibo y la línea de captura válidos."