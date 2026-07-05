# Manual de Branding y Sistema de Identidad Visual: TaxCal App v2

Este documento constituye la **fuente de verdad absoluta** para la identidad de marca, el tono de voz y el sistema de diseño adaptado de **TaxCal App v2**. Su propósito es guiar de forma estricta tanto el desarrollo de la interfaz en Flutter como los esfuerzos de comunicación, asegurando consistencia y un fuerte impacto empático en el profesionista independiente.

## 1. Esencia de Marca y Posicionamiento

### 1.1 Declaración de Propósito

TaxCal v2 no es una herramienta contable corporativa ni un portal de fiscalización secundario. Su propósito es actuar como un **escudo de tranquilidad fiscal y un traductor financiero local** para las Personas Físicas bajo el **Régimen 612 (Actividad Empresarial y Servicios Profesionales)** en México. Transforma la ansiedad y confusión que genera el portal del SAT en un proceso guiado, privado y libre de estrés.

### 1.2 Atributos Clave de la Marca

- **Empatía Radical:** Entiende la frustración del usuario ante los tecnicismos hacendarios y se comunica en su idioma.
    
- **Privacidad Absoluta (_Local-First_):** La marca proyecta máxima seguridad. El usuario es dueño total de sus datos; nada sale de su dispositivo.
    
- **Simplicidad Minimalista:** Cada pantalla debe reducir la carga cognitiva. El usuario prioriza su profesión, no el aprendizaje de una plataforma compleja.
    
- **Certeza Predictiva:** Ofrece una simulación fidedigna que elimina el factor sorpresa antes de interactuar con la autoridad fiscal.
    

## 2. Identidad Visual y Paleta Cromática

### 2.1 Preservación del Icono v1

El icono original de la v1 (composición en perspectiva de una factura en escala de grises con la leyenda "TAX" y el símbolo "$", superpuesta a una calculadora gris oscuro con pantalla verde brillante y teclas naranjas) se mantiene de forma **íntegra e inmutable** como el identificador principal de la aplicación en las tiendas de distribución (App Store y Google Play). Toda la paleta expandida de la v2 nace de este elemento conceptual.

### 2.2 Sistema Cromático de la Interfaz (v2)

Para el sistema de diseño en modo oscuro (altamente apreciado en la v1), la paleta de colores se estructura a partir de los pigmentos extraídos del icono, adicionando un color de acento secundario para la optimización de los flujos de deducibilidad.

```
                      [ PALETA DE COLORES PRINCIPALES ]
      
      Fondo Primario          Superficies/Tarjetas       Texto Principal
      (Charcoal Icono)          (Gris Intermedio)         (Blanco Puro)
         #1A1A1A                    #2A2A2A                  #FFFFFF
            │                          │                        │
            ▼                          ▼                        ▼
      ██████████████             ██████████████           ██████████████
      ██████████████             ██████████████           ██████████████
      
      Acento Primario           Acento Secundario         Alerta / Captura
      (Verde Pantalla)           (Naranja Teclas)         (Estándar SAT)
         #00CC44                    #FF6600                  #FF3333
            │                          │                        │
            ▼                          ▼                        ▼
      ██████████████             ██████████████           ██████████████
      ██████████████             ██████████████           ██████████████
```

- **Fondo Primario (`#1A1A1A`):** Negro grafito profundo derivado del cuerpo de la calculadora del icono. Controla el fondo base de la aplicación.
    
- **Superficies y Tarjetas (`#2A2A2A`):** Gris intermedio de los contenedores para generar volumen y separar bloques de información analítica.
    
- **Acento Primario (`#00CC44`):** Verde brillante tomado de la pantalla digital del icono. Se utiliza exclusivamente para flujos positivos (Saldos a favor, ingresos efectivamente cobrados, estatus "Deducible").
    
- **Acento Secundario (`#FF6600`):** Naranja vibrante extraído de las teclas operativas del icono. Se introduce para destacar acciones de interacción crítica, alertas de plazos límite de pago y fechas de vencimiento basadas en el RFC.
    
- **Semántica de Advertencia SAT (`#FF3333`):** Rojo brillante reglamentario. Destaca de forma estricta los campos que requieren captura manual y los bordes obligatorios del asistente espejo.
    

## 3. Tipografía y Sistema Jerárquico

Para garantizar legibilidad extrema ante una alta densidad de datos fiscales sin saturar la vista, se define un sistema tipográfico híbrido:

### 3.1 Tipografía Prosa y Navegación: **Geist Sans**

- **Uso:** Encabezados, nombres de secciones, textos introductorios, etiquetas de configuración y onboarding.
    
- **Estilo:** Sans-serif geométrica, moderna y ultra-limpia que proyecta minimalismo y contemporaneidad.
    

### 3.2 Tipografía Financiera y Numérica: **Geist Mono** (o fuente tabular equivalente)

- **Uso:** Desgloses de CFDIs, tablas de ISR acumulado, importes de IVA, montos de subtotal, retenciones y folios fiscales (UUID).
    
- **Razón de Negocio:** Al ser monoespaciada, evita que los números "bailen" visualmente u oscilen de tamaño al cambiar de mes o actualizar montos con los interruptores dinámicos, manteniendo las columnas de centavos alineadas perfectamente a nivel de pixel.
    

## 4. UI/UX: El Criterio Híbrido "Espejo SAT"

El módulo **Espejo SAT** debe resolver un dilema de usabilidad crítico: mantener la consistencia estética de TaxCal v2 sin perder la correspondencia lógica del portal gubernamental.

- **Estilo y ADN Visual:** El módulo se renderiza estrictamente bajo los colores corporativos de TaxCal (Modo oscuro, fondos `#1A1A1A` y tipografía Geist). No emula el diseño web antiguo ni el esquema claro del SAT.
    
- **Estructura y Mapeo Lógico:** Conserva de forma fiel y rigurosa la secuencia de navegación oficial (_Configuración ➔ Determinación ➔ Pago_). Las etiquetas de los campos (ej. _“¿Tus ingresos fueron obtenidos en copropiedad...?”_ o _“Ingresos de periodos anteriores”_) se colocan en el mismo orden exacto que solicita la autoridad hacendaria.
    
- **Identificación Inmediata:** Esto permite que la curva de aprendizaje para el copiado manual de datos (apoyado por el botón flotante _Copy-Paste_) sea nula, reduciendo la ansiedad del vaciado fiscal.
    

## 5. Tono de Voz y Comunicación Verbal

El lenguaje dentro de la aplicación se aleja del frío formalismo contable tradicional. TaxCal v2 habla como un colega experto que te cuida las espaldas.

### 5.1 Principios Editoriales

- **Cercano y Empático:** Reconoce el esfuerzo del profesionista. Utiliza frases de validación ante el entorno fiscal.
    
- **Ultra-Simplificado:** Traduce términos complejos. En lugar de forzar al usuario a entender qué es un "CFDI de traslado con impuesto diferido", la app dice: _"Factura a crédito que aún no te pagan"_.
    
- **Preventivo, No Punitivo:** Las alertas no regañan al usuario. Explican de forma clara la causa y la solución legal.
    

### 5.2 Matriz de Comunicación (Ejemplos Prácticos)

|**Escenario de la App**|**Lenguaje Técnico Tradicional (A Evitar)**|**Tono TaxCal v2 (Permitido)**|
|---|---|---|
|**Alerta de Bancarización**|_"Erogación rechazada por incumplimiento del Art. 27 Fracc. III de la LISR debido a método de pago no bancarizado superior a tope nominal."_|_"⚠️ Tu gasto supera los $2,000.00 pesos y fue pagado en efectivo. El SAT lo va a rechazar. Procura pagar con transferencia o tarjeta la próxima vez."_|
|**Bypass de Subsidio**|_"Error de validación lógica: El campo Subsidio al Empleo requiere un valor nulo para procesar el timbrado de la declaración provisional."_|_"Dejamos este espacio en blanco a propósito. Es un truco para evitar un fallo conocido del portal del SAT si no tienes empleados a tu cargo."_|
|**Estado PPD Sin Conciliar**|_"Comprobante fiscal con método de pago diferido sin la emisión asociada del respectivo complemento de recepción de pagos."_|_"Esta factura está guardada a la espera de que el dinero entre a tu banco. Cuando te paguen, presiona el botón para sumarlo a este mes."_|
|**Exención de Responsabilidad**|_"La presente solución de software no se constituye de forma solidaria ante las determinaciones o créditos fiscales fincados..."_|_"Esta app es tu bitácora privada y un simulador interactivo para que veas tus números antes de ir al SAT. No tenemos nexos oficiales con el gobierno..."_|

## 6. Directrices para Desarrolladores (Flutter Implementation)

Al programar los widgets de UI y configurar los temas con Riverpod, se deben seguir estas reglas de diseño de forma mandatoria:

- **`ThemeData` Configuration:** Configurar el `ThemeData(brightness: Brightness.dark)` usando `#1A1A1A` como `scaffoldBackgroundColor`.
    
- **Campos de Entrada Espejo:** Los campos de solo lectura (auto-calculados) deben usar un contenedor deshabilitado con fondo `#2A2A2A` y opacidad de texto reducida al **60%**. Los campos que requieren interacción manual obligatoria deben usar un borde activo `Border.all(color: Color(0xFFFF3333), width: 1.5)`.
    
- **Micro-interacciones Reactivas:** Al apagar el interruptor de deducibilidad en la lista de gastos, el cambio cromático en la tarjeta de gasto (transición de verde de acento primario a gris inactivo) debe ejecutarse con una animación lineal suave de máximo **200ms**, actualizando inmediatamente las proyecciones globales del tablero.