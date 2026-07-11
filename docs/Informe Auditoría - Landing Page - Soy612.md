# Informe de Auditoría — Landing Page soy612
**URL evaluada:** https://soy612.click/
**Fecha:** 11 de julio de 2026
**Metodología:** Revisión del contenido completo renderizado (recuperado vía fetch de servidor) contra checklist de conversión para landing pages de Micro SaaS.

---

## 1. Resumen ejecutivo

De las cuatro landings auditadas (Meserito, Notar, VigiPass, soy612), esta es la que mejor resuelve el "momento wow": no solo muestra un mockup del dashboard real en el hero (claramente etiquetado como "Datos ficticios de ejemplo — así se ve la app real"), sino que incluye un **simulador fiscal interactivo funcional** que recalcula el ISR en tiempo real según lo que el usuario captura, y una **calculadora de vencimiento por RFC** también interactiva. Es el ejemplo más fuerte de demo visual de todo el portafolio auditado hasta ahora.

También destaca positivamente el manejo del riesgo legal/regulatorio: la página incluye un **disclaimer extenso y bien redactado** dejando explícito que soy612 no tiene afiliación ni autorización del SAT y que el usuario es responsable de la presentación oficial — esto es directamente relevante al tema de rechazo de Google Play Store por disclaimers de no afiliación al SAT que se ha trabajado en conversaciones previas, y vale la pena revisar si este texto ya está alineado con la ficha de la tienda o si conviene homologarlo.

El hallazgo principal a corregir es, de nuevo, la **ausencia de prueba social** — el mismo patrón detectado en Meserito, Notar y VigiPass. Con esta landing se completa 4 de 4 productos del portafolio sin testimonios, calificaciones ni cifras de adopción visibles, lo cual sugiere que este no es un problema aislado de una landing, sino un patrón sistemático a nivel de portafolio.

También se detectó un posible **campo de formulario mal adaptado** ("Empresa") en el formulario de lista de espera de soy612 Pro, que no encaja con el perfil de usuario objetivo (profesionista independiente persona física, no una empresa) — posible señal de un componente de formulario reutilizado de otro producto del portafolio (como VigiPass) sin ajustar completamente al contexto de este.

---

## 2. Hallazgos técnicos

**H0.1 — Contenido recuperable vía fetch de servidor (positivo)**
- Igual que VigiPass, y a diferencia de Meserito y Notar, el HTML de soy612 devolvió el contenido completo renderizado sin necesitar ejecución de JavaScript en cliente.
- **Implicación:** buena señal para indexación orgánica. Con esto, 2 de 4 productos del portafolio (VigiPass y soy612) tienen este comportamiento correcto y 2 de 4 (Meserito y Notar) no. Vale la pena unificar la configuración de renderizado en todo el portafolio.

**H0.2 — Enlaces de la sección "Leyes Fiscales" del footer apuntan a anclas vacías (#)**
- **Observación:** los enlaces "Régimen 612 SAT", "Artículo 151 LISR", "Artículo 69-B CFF" y "Guías de llenado CFDI" en el footer apuntan a `#` en lugar de una página o sección real.
- **Impacto:** para un producto que basa su confianza en el rigor fiscal/legal, tener enlaces de "placeholder" sin destino real en una sección que promete profundizar en las leyes que sustentan el producto puede notarse como incompleto, especialmente si un usuario cauteloso hace clic para verificar antes de confiar sus datos fiscales.
- **Recomendación:** completar estos destinos con contenido real (aunque sea una página simple por cada tema) antes de lanzamiento, o remover temporalmente los enlaces mientras no tengan destino, para evitar la señal de "página sin terminar".

**H0.3 — Posible campo de formulario ("Empresa") no adaptado al contexto B2C de soy612**
- **Observación:** el formulario de lista de espera de soy612 Pro incluye un campo o etiqueta "Empresa" junto a "soy612 Estándar" / "soy612 Pro" / "Avísame", lo cual no encaja con el perfil declarado de usuario (persona física, profesionista independiente) — un campo "Empresa" es propio de un formulario B2B como el de VigiPass.
- **Impacto:** si es un campo real visible en el formulario, puede confundir al usuario (¿por qué me piden el nombre de mi empresa si soy freelancer?); si es una etiqueta de desarrollo/testing que quedó visible por error, es un bug de UI a corregir.
- **Recomendación para desarrollo:** revisar el componente de formulario de captura de lista de espera — si es un componente compartido entre productos del portafolio, confirmar que los campos mostrados se configuran por producto y no se están heredando campos de otro contexto (ej. VigiPass) por defecto.

---

## 3. Hallazgos de contenido y UX (por prioridad)

### P0 — Crítico, corregir de inmediato

**P0.1 — Ausencia total de prueba social**
- **Observación:** no hay testimonios, calificaciones de tienda de apps, cifras de descargas/usuarios activos, ni menciones de prensa en ningún punto de la página.
- **Impacto:** para un producto que maneja datos fiscales sensibles (ingresos, CFDIs, cálculos de impuestos), la confianza es el activo más importante a transmitir antes de que alguien descargue la app y empiece a cargar sus documentos. La ausencia de evidencia externa de que otros usuarios ya confían en la herramienta es un vacío significativo, sobre todo cuando el disclaimer legal ya establece explícitamente que "el simulador no es oficial" — el usuario necesita una razón adicional para confiar en la precisión del cálculo.
- **Recomendación funcional:** en cuanto existan las primeras calificaciones en App Store/Google Play, mostrarlas de forma destacada cerca del CTA de descarga. Mientras tanto, considerar un testimonio de beta tester real (aunque sea uno solo) sobre la experiencia de privacidad/tranquilidad que ofrece la app.
- **Nota de portafolio:** este es el cuarto de cuatro productos auditados con el mismo vacío — ver síntesis final de portafolio al cierre de este informe.

### P1 — Alto impacto, planificar en el próximo ciclo

**P1.1 — Corregir enlaces de footer sin destino (ver H0.2)**
- Repetido aquí como ítem de backlog priorizable, dado su impacto directo en percepción de rigor/confianza para un producto fiscal.

**P1.2 — Verificar y corregir el campo "Empresa" en el formulario de lista de espera Pro (ver H0.3)**
- Repetido aquí como ítem de backlog priorizable.

**P1.3 — Confirmar presencia de badges de tienda (App Store / Google Play) junto al CTA de descarga**
- **Observación:** el contenido extraído no muestra explícitamente los badges oficiales de descarga (imagen del App Store / Google Play) junto al botón "Descargar soy612 Gratis" — es posible que existan como imágenes no capturadas en la extracción de texto, por lo que este hallazgo requiere verificación visual directa, no es una afirmación definitiva.
- **Impacto:** si no están presentes, un botón de texto genérico "Descargar Gratis" sin el badge oficial de la tienda reduce la señal de legitimidad inmediata que dan esos badges reconocibles.
- **Acción sugerida:** confirmar visualmente en el sitio si los badges están presentes y enlazan correctamente a las fichas de tienda correspondientes (relevante dado el proceso de publicación en Google Play ya en curso).

**P1.4 — Sin canal de contacto inmediato antes de la descarga**
- **Observación:** solo existe un link "Soporte Técnico" en el footer, sin chat en vivo ni WhatsApp visible en el cuerpo de la página.
- **Impacto:** dado que el producto toca un tema sensible (impuestos, privacidad de datos fiscales), un usuario dudoso podría beneficiarse de poder preguntar algo puntual ("¿de verdad nadie ve mis XMLs?", "¿esto sirve si tengo actividad empresarial y arrendamiento a la vez?") antes de comprometerse a instalar la app.
- **Recomendación funcional:** considerar un canal de contacto directo (WhatsApp o chat) visible antes del footer, especialmente cerca de la sección de precios/descarga.

### P2 — Mejoras incrementales

**P2.1 — Herramientas interactivas gratuitas sin ninguna captura de contacto opcional**
- **Observación:** tanto el simulador de ISR/IVA como la calculadora de vencimiento por RFC son completamente gratuitos y sin ningún tipo de captura de contacto, ni siquiera opcional.
- **Impacto:** esto es coherente con la filosofía "privacidad absoluta" del producto y probablemente sea una decisión intencional — no se recomienda forzar un registro para acceder a estas herramientas, ya que contradiría el mensaje central de privacidad. Sin embargo, sí existe una oportunidad de bajo costo: ofrecer de forma completamente opcional (nunca obligatoria) un recordatorio por correo del vencimiento calculado, para quienes lo deseen.
- **Recomendación funcional:** evaluar un CTA opcional tipo "¿Quieres que te lo recordemos por correo? (opcional)" junto al resultado de la calculadora de vencimientos, sin bloquear el uso de la herramienta si el usuario no lo acepta.

**P2.2 — Precio de soy612 Pro visible antes de estar disponible**
- **Observación:** el plan Pro muestra el precio "$149 MXN/mes" de forma prominente, aunque el CTA indica "Próximamente · Avisarme" — es decir, aún no está disponible para compra.
- **Impacto:** esto es honesto y está bien etiquetado como "Próximamente", por lo que no es un problema de transparencia. Sin embargo, ancla una expectativa de precio antes de validar demanda o reunir feedback de los primeros usuarios Pro.
- **Recomendación funcional:** si el precio final aún puede ajustarse, considerar un mensaje como "Precio estimado de lanzamiento" en lugar de presentarlo como definitivo, para mantener flexibilidad de pricing sin perder la transparencia ya lograda.

**P2.3 — Toggle mensual/anual sin mostrar el desglose de ahorro en pesos**
- **Observación:** el toggle indica "Anual (Ahorra 20%)" como porcentaje, pero no se observa el monto exacto ahorrado en pesos junto al precio anual.
- **Recomendación funcional:** mostrar el equivalente en pesos (ej. "$1,430 MXN/año — ahorras $358 MXN") suele aumentar la conversión hacia el plan anual más que solo el porcentaje.

---

## 4. Puntos a preservar (no cambiar)

- **Simulador fiscal interactivo con recálculo en tiempo real** — el mejor "momento wow" de todo el portafolio auditado; debe usarse como referencia de buena práctica para otros productos.
- **Etiquetado explícito de datos de ejemplo** ("Datos ficticios de ejemplo — así se ve la app real", "Simulador no oficial. No es el portal del SAT.") — exactamente la práctica de transparencia que se recomendó reforzar en el informe de VigiPass; aquí ya está bien implementada.
- **Disclaimer legal extenso y específico sobre la falta de afiliación al SAT** — directamente relevante al contexto de aprobación en tiendas de aplicaciones; buena base para homologar el lenguaje en la ficha de tienda si aún no se ha hecho.
- **Plan gratuito real, sin tarjeta ni registro forzado** — el mejor manejo de fricción de entrada de las cuatro landings auditadas.
- **Copy que respeta el vocabulario técnico-fiscal del usuario objetivo** (CIEC, e.firma, Borrador, CFDI) sin sobre-explicarlo — a diferencia del error detectado en Notar (uso de "API" fuera de contexto), aquí la terminología es apropiada porque coincide con el vocabulario que el usuario objetivo ya usa a diario.
- **Renderizado indexable (SSR/SSG aparente)** — igual que VigiPass, contenido recuperable directamente.

---

## 5. Backlog sugerido para planificación

| ID | Hallazgo | Prioridad | Tipo de cambio | Áreas de código probablemente involucradas |
|---|---|---|---|---|
| P0.1 | Incorporar prueba social (calificaciones de tienda / testimonio) | Crítica | Contenido/diseño | Sección cerca del CTA de descarga |
| P1.1 | Completar o remover enlaces de footer sin destino ("Leyes Fiscales") | Alta | Contenido/navegación | Componente de footer |
| P1.2 | Corregir campo "Empresa" en formulario de lista de espera Pro | Alta | Bug de UI / configuración de componente | Formulario de waitlist, posible componente compartido con VigiPass |
| P1.3 | Confirmar y, si falta, agregar badges oficiales de tienda | Alta | Contenido/diseño | Componente de hero o sección de precios |
| P1.4 | Agregar canal de contacto inmediato (WhatsApp/chat) | Alta | Feature nueva | Componente global o widget flotante |
| P2.1 | CTA opcional de recordatorio por correo en calculadora de vencimientos | Media | Feature opcional | Componente de la calculadora de RFC |
| P2.2 | Reetiquetar precio de Pro como "estimado" mientras no esté disponible | Media | Copy | Componente de sección de precios |
| P2.3 | Mostrar ahorro anual en pesos, no solo en porcentaje | Media | Copy/lógica de precios | Componente de toggle de precios |

---

## 6. Próximos pasos sugeridos

1. Resolver P0.1 en cuanto existan las primeras calificaciones de tienda o testimonios reales — es el hallazgo más recurrente de todo el portafolio.
2. Revisar H0.2/P1.1 y H0.3/P1.2 antes de cualquier campaña de descarga, ya que ambos son fáciles de corregir y afectan percepción de calidad/rigor.
3. Confirmar visualmente P1.3 (badges de tienda) dado que coincide con el proceso de publicación en Google Play ya en curso.
4. Planificar P1.4 y evaluar P2.x de forma oportunista.
5. Revisar si el disclaimer legal ya presente en esta landing está alineado con el texto de la ficha de Google Play, dado el contexto de rechazo por disclaimers de no afiliación al SAT.

---

## 7. Síntesis de portafolio (Meserito, Notar, VigiPass, soy612)

Con las cuatro landings ya auditadas, se repiten algunos patrones que probablemente convenga resolver a nivel de portafolio en lugar de producto por producto:

- **Prueba social ausente en 4 de 4 productos.** Es el hallazgo más consistente de todas las auditorías. Sugiere priorizar una iniciativa conjunta de recolección de testimonios/casos de uso/calificaciones tempranas en los cuatro productos a la vez.
- **Renderizado inconsistente:** VigiPass y soy612 son indexables directamente (SSR/SSG); Meserito y Notar no lo son. Vale la pena unificar la configuración técnica.
- **Posible reutilización de componentes de formulario entre productos sin adaptar completamente el contexto** (el campo "Empresa" en soy612, heredado aparentemente del patrón B2B de VigiPass) — sugiere revisar si hay un sistema de componentes compartido entre los micro-SaaS del portafolio y, de ser así, auditar qué otros campos podrían estar mal configurados por producto.
- **Manejo de moneda inconsistente:** Notar y soy612 usan MXN de forma clara; VigiPass usa USD sin justificación aparente para un mercado mexicano. Vale la pena homologar.
- **El mejor ejemplo de "momento wow" del portafolio es soy612** (simulador interactivo real) y **el mejor ejemplo de transparencia sobre datos de ejemplo también es soy612** — ambos son buenas prácticas replicables en Meserito y Notar, que aún no tienen ningún elemento de demo visual real del producto.

Si te sirve, puedo preparar un documento adicional que consolide únicamente esta síntesis transversal de portafolio como plan de acción conjunto, separado de los cuatro informes individuales.


==========================================================================

# Informe de Optimización de Producto y Software: Landing Page `soy612.click`

**Para:** Equipo de Desarrollo de Producto y Software

**De:** Arquitectura de Producto & Estrategia Micro-SaaS

**Fecha:** 11 de julio de 2026

**Estatus:** Crítico / Próximo Lanzamiento

---

## 1. Resumen Ejecutivo

El análisis técnico y de conversión de la landing page actual (`https://soy612.click/`) confirma que el producto cuenta con una base sólida alineada a la filosofía *Local-First* y al modelo *Micro-SaaS*. La interfaz en modo oscuro (*Digital Electric Blue*) y los módulos interactivos en el navegador demuestran el valor técnico de inmediato.

Sin embargo, para garantizar una tasa de conversión óptima, blindar el producto ante las estrictas políticas de las tiendas de aplicaciones (Google Play / App Store) y asegurar la coherencia con los planos de ingeniería de la capa **soy612 Pro**, se detallan las siguientes tareas técnicas y de UI prioritarias.

---

## 2. Bloque de Cumplimiento Político y Legal (Prioridad Alta)

### 2.1 Activación y Enrutamiento de Enlaces Gubernamentales

* **Problema:** En la sección "Leyes Fiscales" del footer, las referencias al *Régimen 612 SAT*, *Artículo 151 LISR* y *Artículo 69-B CFF* apuntan a placeholders internos (`url0`). Google Play rechaza aplicaciones de forma fulminante bajo la **Política de Afirmaciones Engañosas** si se provee información fiscal/gubernamental sin fuentes verificables directas.
* **Acción Técnica Requerida:** Actualizar los hipervínculos del HTML para que apunten estrictamente a dominios gubernamentales oficiales con certificados válidos (`.gob.mx` o `.gob`).
* *Régimen 612 SAT:* Enlace directo al portal oficial de orientación del SAT para Personas Físicas con Actividad Empresarial.
* *Artículo 151 y 152 LISR:* Enlace al PDF de la Ley del Impuesto Sobre la Renta en el portal de la Cámara de Diputados.
* *Artículo 69-B CFF:* Enlace al Diario Oficial de la Federación (DOF) o al listado oficial de EFOS del SAT.



### 2.2 Sincronización del Disclaimer (Exención de Responsabilidad)

* **Problema:** El *SAT Disclaimer* incluido en el footer es impecable y protege legalmente la naturaleza *standalone* de la app. No obstante, el revisor humano de las tiendas auditará si este mensaje está replicado en el aplicativo móvil.
* **Acción Técnica Requerida:** Validar que el mismo bloque de texto exacto del footer esté integrado en el flujo de **Onboarding (primer inicio)** de la app de Flutter y en el pie de página de los reportes PDF generados localmente por el "Botón del Contador".

---

## 3. Optimización del Widget de Demostración (Código Frontend)

### 3.1 Sanitización de Inputs Numéricos en Tiempo Real

* **Problema:** En el simulador reactivo del Borrador (JavaScript local), los campos editables como *PTU pagada* y *Pérdidas fiscales anteriores* permiten la libre entrada de caracteres. Si un usuario introduce texto o símbolos especiales, el motor matemático arrojará un error `NaN` o romperá la persistencia visual del pixel en la UI.
* **Acción Técnica Requerida:** Implementar una máscara y limpieza de inputs por medio de expresiones regulares en el evento `input` o `keyup`. Fuerza que el campo admita únicamente números enteros o decimales con dos posiciones, convirtiendo strings vacíos en `0` internamente para el cálculo, pero permitiendo que visualmente se mantenga vacío si el usuario borra el contenido (evitando el molesto bug de "cero fijo" que tiene el propio portal del SAT).

### 3.2 Refuerzo Visual de Seguridad *Zero-Knowledge*

* **Problema:** La frase *"Toda la matemática ocurre a nivel de pixel en tu navegador (sin enviar datos al servidor)"* es excelente, pero carece de un anclaje visual que detenga la ansiedad del usuario de aportar datos financieros en una web.
* **Acción Técnica Requerida:** Diseñar e incorporar un micro-badge responsivo (ej. un escudo con un candado en color cian digital `#00D2FF`) inmediatamente al lado o debajo del texto descriptivo del simulador.

---

## 4. Control de Datos en Módulo de Vencimientos (RFC)

### 4.1 Restricción de Longitud y Auto-Uppercase

* **Problema:** El buscador del Plazo Límite de Declaración procesa dinámicamente el sexto dígito para calcular la prórroga de días hábiles. Actualmente, el input no limita la cantidad de caracteres ni formatea el texto nativamente.
* **Acción Técnica Requerida:**
1. Añadir el atributo `maxlength="13"` al tag de entrada para acotarlo estrictamente al RFC de personas físicas.
2. Implementar una clase CSS o regla JS `input.value = input.value.toUpperCase()` para mitigar errores de coincidencia de índices en el string si el usuario escribe en minúsculas.
3. Agregar un validador RegEx básico en el *listener* para que si la estructura de los primeros 4 caracteres no es alfabética, despliegue un *tooltip* suave de advertencia sin interrumpir la experiencia.



---

## 5. Alineación de Infraestructura y Estrategia Micro-SaaS

### 5.1 Homologación del Dominio de Ingesta Pro

* **Problema:** En la sección "La filosofía detrás de soy612", el texto promocional expone el buzón automatizado como `tu_rfc@soy612.click`. Sin embargo, las especificaciones técnicas del backend híbrido y el pipeline de parseo efímero de correos están diseñados bajo la arquitectura del dominio corporativo de infraestructura cloud `tu_rfc@soy612.cloud`.
* **Acción Técnica Requerida:** Modificar el texto del HTML para reflejar el uso de `.cloud` si esta será la compuerta de enlace definitiva para los servidores de correo (MX), o en su defecto, instruir al equipo DevOps para que configure los registros DNS del dominio `.click` para soportar la recepción masiva de correos entrantes de CFDIs 4.0.

### 5.2 Optimización de la Tabla de Precios (Gatillos Mentales de Captura)

* **Problema:** La visualización del plan Pro como "Próximamente" ofrece un botón plano de "Avisarme". Para una operación *Solopreneur* con metodología *Building in Public*, se está perdiendo una ventana crítica de captación de leads cualificados.
* **Acción Técnica Requerida en UI/Copy:**
* **Price Anchoring:** En la pestaña "Anual (Ahorra 20%)", colocar el precio prorrateado tachado (ej. `~~$149 MXN~~`) y destacar en azul cobalto brillante (`#0052FF`) el costo mensual equivalente cobrado anualmente.
* **Beta-Testing Hook:** Reemplazar el genérico "Avisarme" por un bloque que impulse el registro inmediato a cambio de un incentivo técnico. Ejemplo: *"Lanzamiento Pro estimado: Q3 2026. Déjanos tu correo y asegura una tarifa fija vitalicia (Founder Member) y acceso preferente a la Beta"* con un input de correo directo unificado a una base de datos de Firebase o servicio de automatización.



---

## 6. Lista de Control de Despliegue (Checklist para QA)

* [ ] Reemplazar todos los placeholders `url0` de la sección legal por enlaces reales externos `.gob.mx` o `.gob`.
* [ ] Aplicar máscara `maxlength="13"` y `text-transform: uppercase` al campo del calculador de RFC.
* [ ] Validar funciones del simulador JS con payloads destructivos (strings, emojis, caracteres especiales) para asegurar que no devuelva `NaN`.
* [ ] Cambiar la referencia del dominio del buzón Pro a `.cloud` o confirmar que el pipeline de DevOps operará sobre `.click`.
* [ ] Desplegar campos de captura de emails en la sección Pro para iniciar la preventa ciega y el *early-access tracking*.

==========================================================

# Evaluación de la landing page de soy612

## Diagnóstico ejecutivo

soy612 presenta una propuesta de valor claramente especializada:

> Una bitácora fiscal privada para personas físicas del Régimen 612 que organiza CFDI, proyecta ISR e IVA y prepara la información en un orden semejante al portal del SAT, sin solicitar la Contraseña del SAT ni la e.firma.

La especialización es una fortaleza importante. El código 612 corresponde oficialmente al **Régimen de las Personas Físicas con Actividades Empresariales y Profesionales**, por lo que el nombre de la marca está bien alineado con el nicho elegido.

La landing supera varios problemas frecuentes de un Micro SaaS en fase inicial:

* Explica para quién es.
* Muestra visualmente el producto.
* Incluye un simulador interactivo.
* Presenta precios.
* Expone claramente que no es una herramienta oficial del SAT.
* Tiene páginas de privacidad, términos y soporte.
* Diferencia un plan gratuito local de un futuro plan Pro.

Sin embargo, existen cinco riesgos prioritarios:

1. **La página invita a descargar una aplicación que simultáneamente aparece como “próximamente”.**
2. **“100 % privado y local” no describe correctamente el futuro plan Pro.**
3. **El buzón Email-to-App parece incompatible con una promesa estricta de Zero-Knowledge.**
4. **La confianza depende casi totalmente de afirmaciones propias; no existe prueba social, revisión fiscal o auditoría independiente visible.**
5. **Algunas expresiones técnicas y fiscales son demasiado absolutas para un producto que procesa información tributaria.**

## Evaluación general

| Área                        | Evaluación |
| --------------------------- | ---------: |
| Claridad del nicho          |      4.5/5 |
| Claridad del beneficio      |        4/5 |
| Diferenciación              |      4.5/5 |
| Demostración visual         |        4/5 |
| CTA y coherencia del embudo |      2.5/5 |
| Reducción de fricción       |        4/5 |
| Confianza fiscal            |        3/5 |
| Confianza técnica           |        3/5 |
| Prueba social               |        1/5 |
| Precios y oferta            |      3.5/5 |
| Captación de prospectos     |      3.5/5 |
| Preparación legal           |        3/5 |
| SEO y contenido             |        4/5 |

---

# 1. Evaluación de la regla de los cinco segundos

## Situación actual

El primer bloque presenta:

> Tu escudo de tranquilidad fiscal

> Tus impuestos bajo tu control.

> 100 % privado y local.

El subtítulo explica que soy612 procesa los XML localmente, organiza un borrador en el mismo orden que el SAT y no solicita archivos de e.firma ni credenciales. También muestra una representación del tablero con ingresos, deducciones, utilidad e impuestos proyectados.

## Fortalezas

El visitante puede comprender rápidamente:

* Que se trata de una herramienta fiscal.
* Que está orientada a contribuyentes mexicanos.
* Que procesa CFDI.
* Que la privacidad es un diferenciador.
* Que ayuda a preparar declaraciones mensuales.
* Que no pretende presentar la declaración automáticamente.

La captura del producto refuerza correctamente el mensaje: no es una landing abstracta, sino una herramienta que muestra ingresos cobrados, gastos deducibles, utilidad e impuestos proyectados.

## Problemas

### “Tus impuestos bajo tu control” sigue siendo algo genérico

Podría corresponder a:

* Una calculadora fiscal.
* Un despacho contable.
* Un sistema de facturación.
* Una aplicación para declaraciones.
* Un gestor de gastos.
* Un servicio para empresas.

La explicación posterior resuelve la ambigüedad, pero el titular podría comunicar mejor el resultado principal.

### “100 % privado y local” es demasiado absoluto

Describe razonablemente al plan Estándar, pero no al plan Pro, que contempla sincronización en la nube, buzón de correo y procesamiento automatizado. La propia landing y los términos distinguen ambos modelos.

### No aparece inmediatamente el nombre completo del régimen

“612” será reconocible por algunos contribuyentes y contadores, pero no por todos. El SAT denomina actualmente al régimen como Personas Físicas con Actividades Empresariales y Profesionales.

## Hero recomendado

**Etiqueta**

> Para personas físicas con actividad empresarial o profesional — Régimen 612

**Titular**

> Prepara tu declaración mensual sin entregar tus claves del SAT.

**Subtítulo**

> Importa tus CFDI, conoce tus ingresos y deducciones y obtén un borrador organizado para capturarlo directamente en el portal del SAT. Tus datos permanecen en tu dispositivo con soy612 Estándar.

**CTA principal durante la preventa**

> Probar el simulador

**CTA secundario**

> Unirme a la beta gratuita

**Microcopy**

> No solicitamos tu Contraseña del SAT ni tu e.firma · Simulador independiente y no oficial

Una variante orientada al resultado económico sería:

> # Conoce cuánto podrías pagar antes de abrir el portal del SAT.

---

# 2. Corregir inmediatamente la contradicción del CTA

La navegación y el hero utilizan expresiones como:

* “Descargar App”.
* “Descargar soy612 Gratis”.
* “Comenzar Gratis”.

Sin embargo, la sección de planes muestra:

> Próximamente · Avisarme

y explica que soy612 Pro continúa en construcción. El centro de soporte afirma además que la aplicación “está disponible” para Android e iOS, mientras la landing sigue tratándola como próxima.

Esta inconsistencia puede causar:

* Clics frustrados.
* Pérdida de confianza.
* Confusión sobre qué producto está disponible.
* Sensación de que la landing está adelantada respecto del producto.
* Menor conversión a la lista de espera.

## Recomendación según el estado real

### Si soy612 Estándar todavía no está publicado

Sustituir todos los CTA por:

> Probar simulador

> Solicitar acceso anticipado

> Avisarme cuando esté disponible

No utilizar “Descargar” hasta que exista un enlace funcional a Google Play, App Store o una descarga oficial.

### Si Estándar ya está publicado y solamente Pro está en construcción

Separar con absoluta claridad:

> **soy612 Estándar — Disponible gratis**

> **soy612 Pro — Próximamente**

Y mostrar botones reales de las tiendas.

### Si existe una beta cerrada

Utilizar:

> Solicitar acceso a la beta

> Participar como usuario piloto

La acción principal debe representar exactamente lo que ocurrirá después del clic.

---

# 3. El diferenciador principal debe expresarse en lenguaje del cliente

La landing utiliza conceptos como:

* Local-First.
* Zero-Knowledge.
* E2EE.
* AES-GCM-256.
* BIP39.
* Anti-EFOS.
* Base de datos Isar.

Son términos útiles para una página técnica o documentación de seguridad, pero no deberían dominar la comunicación comercial.

El usuario no compra “Local-First”. Compra:

* No compartir su contraseña.
* No entregar su e.firma.
* No subir sus facturas a una plataforma desconocida.
* Saber cuánto podría pagar.
* Llegar preparado al portal del SAT.
* Tener ordenados sus comprobantes.
* Colaborar mejor con su contador.

## Traducción recomendada

| Expresión técnica | Expresión comercial                                         |
| ----------------- | ----------------------------------------------------------- |
| Local-First       | Tus datos permanecen en tu dispositivo                      |
| Zero-Knowledge    | Ni soy612 puede leer tu respaldo                            |
| E2EE              | El respaldo se cifra antes de salir del dispositivo         |
| Isar local        | Base de datos protegida en tu teléfono                      |
| Email-to-App      | Envía tus facturas a tu buzón y aparecen organizadas        |
| Anti-EFOS         | Recibe una alerta si un proveedor aparece en listas del SAT |
| Interfaz espejo   | Captura siguiendo un orden familiar al portal del SAT       |

La tecnología puede aparecer en una sección titulada:

> Cómo protegemos tu información

pero el hero debe vender tranquilidad y control.

---

# 4. Sustituir “CIEC” por la terminología actual del SAT

La página habla de “contraseñas CIEC”. Aunque el término todavía es reconocido coloquialmente, el SAT utiliza actualmente **Contraseña**, y algunos de sus propios sistemas la describen como “Contraseña, antes CIEC”.

## Redacción recomendada

> Nunca te pediremos tu Contraseña del SAT —antes conocida como CIEC— ni los archivos `.key` y `.cer` de tu e.firma.

Esto mejora:

* Precisión.
* Comprensión de usuarios nuevos.
* Coincidencia con las interfaces actuales del SAT.
* Posicionamiento en búsquedas.

---

# 5. Precisar mejor quién puede utilizar soy612

La landing habla de “profesionistas independientes y empresarios”, una categoría comercial demasiado amplia. No todos pertenecen al Régimen 612.

El régimen está dirigido a personas físicas que realizan actividades profesionales, comerciales, industriales y otras actividades empresariales comprendidas por el SAT.

## Ejemplos que pueden ayudar

Cuando sean fiscalmente adecuados:

* Consultores.
* Desarrolladores independientes.
* Diseñadores.
* Médicos y otros profesionistas.
* Comerciantes.
* Prestadores de servicios.
* Personas físicas con pequeños negocios.
* Profesionales que emiten facturas por honorarios.

## Añadir una sección de elegibilidad

> ### ¿soy612 es para mí?
>
> soy612 está diseñado para personas físicas inscritas en el Régimen de Actividades Empresariales y Profesionales —clave 612— que presentan pagos provisionales de ISR y definitivos de IVA.
>
> Revisa tu Constancia de Situación Fiscal o consulta a tu contador para confirmar tu régimen y obligaciones.

## Indicar también para quién no es

Por ejemplo:

* Personas morales.
* Contribuyentes exclusivamente en RESICO.
* Sueldos y salarios.
* Arrendamiento exclusivamente.
* Régimen de plataformas tecnológicas.
* Situaciones fiscales complejas no soportadas.
* Contribuyentes con múltiples regímenes, salvo compatibilidad expresamente validada.

Esto reduce registros incorrectos y riesgo reputacional.

---

# 6. El problema debe mostrarse antes que la arquitectura

La landing explica bien la solución, pero puede hacer más visible la situación que genera el estrés.

## Sección recomendada

### ¿Cada mes vuelves a empezar desde cero?

* Buscas XML en distintas carpetas y correos.
* No sabes cuáles ingresos ya fueron cobrados.
* No tienes claro qué gastos cumplen las condiciones de deducibilidad.
* Abres el portal del SAT sin una estimación previa.
* Copias cantidades entre hojas de cálculo y pantallas.
* Dependías de enviar documentos dispersos a tu contador.
* Te preocupa entregar tu Contraseña o e.firma a otra plataforma.

Después:

> soy612 organiza tus comprobantes, proyecta tus impuestos y prepara un borrador para que llegues al SAT con mayor claridad.

Esto crea urgencia sin utilizar miedo excesivo a multas o auditorías.

---

# 7. Convertir la privacidad en una demostración verificable

La privacidad es el eje de la propuesta, pero actualmente depende de afirmaciones como:

* “Privacidad absoluta”.
* “100 % privado”.
* “Jamás”.
* “Ni nosotros ni nadie más”.
* “Esto garantizará”.

En seguridad informática, estas expresiones son difíciles de sostener porque siempre existen riesgos como:

* Dispositivo comprometido.
* Malware.
* Copias de seguridad del sistema operativo.
* Capturas de pantalla.
* Acceso físico.
* Errores de implementación.
* Pérdida de la frase de recuperación.
* Dependencias de terceros.

## Redacción más sólida

En lugar de:

> Privacidad absoluta.

Utilizar:

> Diseñado para minimizar la exposición de tus datos fiscales.

En lugar de:

> 100 % privado y local.

Utilizar:

> En el plan Estándar, tus CFDI y cálculos se procesan y almacenan localmente en tu dispositivo.

En lugar de:

> Nadie podrá verlos.

Utilizar:

> El respaldo Pro está diseñado para que el servidor no disponga de la clave necesaria para descifrar su contenido.

## Pruebas recomendadas

* Diagrama simplificado del flujo de datos.
* Tabla que indique qué sale y qué no sale del dispositivo.
* Código de seguridad o componentes críticos auditables.
* Auditoría independiente.
* Política de divulgación de vulnerabilidades.
* Historial de incidentes.
* Versión y fecha de la arquitectura revisada.
* Lista de proveedores y función de cada uno.

---

# 8. Resolver la incompatibilidad entre Email-to-App y Zero-Knowledge

Este es el riesgo técnico-comercial más importante.

La landing promete que el usuario Pro podrá enviar CFDI a una dirección como:

> `tu_rfc@soy612.click`

Al mismo tiempo, afirma que ni soy612 puede visualizar los registros y que operará bajo un modelo Zero-Knowledge.

Un correo electrónico convencional llega al servidor en una forma que normalmente puede ser procesada por:

* El proveedor de correo.
* El backend receptor.
* El servicio que extrae el archivo adjunto.
* El proceso que interpreta el XML.

Aunque el archivo se cifre inmediatamente después, existió un punto previo en el que el sistema pudo acceder al contenido.

## Alternativas

### Opción A: cambiar la promesa

Explicar honestamente:

> El buzón recibe y procesa temporalmente el CFDI para enviarlo cifrado a tu cuenta. El archivo original se elimina después del procesamiento conforme a nuestra política de retención.

En este escenario no debe denominarse Zero-Knowledge de extremo a extremo.

### Opción B: cifrado previo por el cliente

El usuario cifra el XML antes de enviarlo. Esto preserva mejor el modelo Zero-Knowledge, pero elimina gran parte de la simplicidad del correo.

### Opción C: importación desde la aplicación

La aplicación descarga o recibe el CFDI y lo cifra localmente antes de sincronizarlo. Es más compatible con la promesa, aunque requiere otra integración.

### Opción D: separar los modelos

* Respaldo: Zero-Knowledge.
* Buzón automatizado: procesamiento confidencial, pero no Zero-Knowledge.

La landing y los documentos legales deben distinguirlos sin ambigüedad.

---

# 9. Simplificar la sección criptográfica

La landing expone AES-GCM-256 y BIP39 como garantías futuras.

Esto puede producir tres efectos negativos:

1. Abruma al usuario no técnico.
2. Presenta como definitiva una implementación que todavía está en construcción.
3. Convierte cualquier error arquitectónico futuro en una contradicción pública.

## Recomendación

En la landing:

> Tus respaldos se cifran en tu dispositivo con una clave que solo tú controlas.

En una página técnica:

* Algoritmos.
* Derivación de claves.
* Gestión de nonce.
* Rotación.
* Recuperación.
* Formato del respaldo.
* Amenazas cubiertas.
* Amenazas no cubiertas.
* Auditoría.
* Dependencias.

No utilizar BIP39 únicamente como elemento de marketing. La frase de recuperación introduce además un riesgo de pérdida irreversible que debe comunicarse antes de activar la función.

---

# 10. Mejorar el “momento wow”

La landing ya contiene un simulador de borrador que permite introducir PTU o pérdidas fiscales y observar cómo cambia el ISR. También aclara que se utilizan datos ficticios y que el simulador no es el portal del SAT.

Esta es una buena demostración, pero el verdadero valor del producto no es solamente recalcular una cantidad. Es transformar CFDI dispersos en un borrador útil.

## Demo ideal

1. Arrastrar tres CFDI ficticios.
2. Mostrar cómo se clasifican.
3. Identificar ingresos cobrados y gastos pagados.
4. Mostrar alertas o datos incompletos.
5. Construir el borrador.
6. Compararlo visualmente con el orden del SAT.
7. Copiar una cantidad.
8. Exportar un paquete para el contador.

## CTA

> Ver cómo tres CFDI se convierten en tu borrador mensual

Este recorrido explica más valor que una calculadora aislada.

---

# 11. Reemplazar “a nivel de pixel”

La página afirma:

> Toda la matemática ocurre a nivel de pixel en tu navegador.

“A nivel de pixel” no explica ejecución local y puede sonar técnicamente incorrecto.

## Redacción recomendada

> Todos los cálculos del simulador se ejecutan directamente en tu navegador. Los datos que captures no se envían al servidor.

Añadir, cuando sea verdadero:

> Puedes comprobarlo utilizando el simulador sin iniciar sesión.

---

# 12. Mostrar claramente qué hace y qué no hace el producto

La landing incluye un disclaimer, pero la diferencia debería aparecer antes del footer.

## soy612 sí hace

* Importa y organiza CFDI.
* Ayuda a clasificar ingresos y gastos.
* Proyecta ISR e IVA.
* Prepara un borrador.
* Calcula fechas estimadas de vencimiento.
* Exporta información para revisión.
* Ayuda a colaborar con un contador.

## soy612 no hace

* No es el portal del SAT.
* No presenta declaraciones.
* No genera acuses ni líneas de captura.
* No sustituye asesoría fiscal.
* No garantiza que todos los gastos sean deducibles.
* No decide la materialidad de una operación.
* No sustituye la revisión del contribuyente o contador.
* No solicita credenciales para entrar al SAT.

El centro de soporte ya explica que el producto no sustituye al contador y que el usuario debe presentar directamente en el portal oficial. Ese mensaje debería aparecer en la landing antes de la sección de precios.

---

# 13. Añadir confianza fiscal verificable

En un producto tributario, una interfaz profesional no es suficiente. El usuario necesita conocer:

* Quién diseñó las reglas.
* Quién revisó los cálculos.
* Qué versión fiscal se utiliza.
* Cuándo fue actualizado el motor.
* Qué ocurre si cambia el SAT.
* Qué supuestos están soportados.
* Qué casos no están cubiertos.

## Elementos recomendados

### Fecha de validación

> Motor fiscal revisado para declaraciones del ejercicio 2026. Última actualización: ___.

### Fuentes

> Cálculos basados en disposiciones fiscales y guías públicas del SAT identificadas en la documentación.

### Revisión profesional

Cuando sea verdadero:

> Reglas revisadas por contador público o especialista fiscal.

### Historial de cambios

* Ajustes de tarifas.
* Cambios en formularios.
* Nuevos campos.
* Correcciones de cálculo.
* Casos especiales añadidos.

### Pruebas fiscales

Publicar escenarios anónimos:

* Profesionista con IVA.
* Actividad empresarial.
* Retenciones.
* Pérdidas fiscales.
* Ingresos cobrados posteriormente.
* Gastos pagados con distintos métodos.

La página puede decir “mismo orden que el SAT”, pero el portal y sus formularios cambian. Conviene indicar la versión o periodo de vigencia de la interfaz replicada.

---

# 14. Revisar la promesa “evita errores”

La landing afirma que seguir el orden del SAT permite copiar y pegar y “evitar errores”.

La herramienta puede reducir errores de transcripción u omisión, pero no puede garantizar la ausencia de errores fiscales.

## Alternativas

> Reduce errores de captura.

> Disminuye la necesidad de copiar cantidades entre hojas y pantallas.

> Sigue un orden familiar para revisar cada dato antes de declararlo.

---

# 15. Mejorar el calculador de vencimientos

La herramienta de vencimientos es un excelente lead magnet. El SAT mantiene como referencia general el día 17 del mes siguiente y contempla días hábiles adicionales según el sexto dígito numérico del RFC.

## Problema de privacidad y fricción

La landing pide introducir un RFC completo de 13 caracteres, aunque para el cálculo descrito solamente necesita el sexto dígito numérico.

Pedir el RFC completo:

* Parece innecesario.
* Puede generar desconfianza.
* Contradice psicológicamente el mensaje de mínima recopilación.
* Aumenta el riesgo de errores.
* Obliga a explicar si se almacena.

## Mejor alternativa

> Selecciona el sexto dígito numérico de tu RFC.

Con opciones del 0 al 9.

También puede ofrecer:

> No sé cuál es → Ayúdame a localizarlo

Si se conserva la entrada del RFC completo, añadir inmediatamente:

> Este dato se procesa únicamente en tu navegador y no se guarda ni se transmite.

## Precauciones fiscales

El resultado debe aclarar:

* Que corresponde a pagos provisionales o definitivos aplicables.
* Que considera días hábiles.
* Que puede haber disposiciones especiales o prórrogas extraordinarias.
* Que el usuario debe confirmar la fecha en fuentes oficiales.
* La fecha exacta calculada, no solo “vence en tres días”.
* La fuente y fecha de actualización de la regla.

---

# 16. Convertir el simulador de vencimientos en captación de prospectos

Actualmente el calculador ofrece valor sin exigir correo, lo cual es positivo.

Después de mostrar el resultado puede añadirse:

> Recibe un recordatorio antes de tu próxima fecha límite.

Solicitar únicamente:

* Correo.
* Día calculado.
* Consentimiento específico.

No pedir RFC ni información fiscal.

Otra opción:

> Añadir mis próximos vencimientos al calendario

Esto convierte una utilidad gratuita en una entrada natural al producto.

---

# 17. Replantear el módulo Anti-EFOS

El plan Pro menciona monitoreo Anti-EFOS con base en el artículo 69-B. El SAT publica listados diferenciados de contribuyentes:

* Presuntos.
* Definitivos.
* Desvirtuados.
* Con sentencia favorable.

La información oficial se actualiza periódicamente.

## Riesgo

Presentar un resultado binario como:

> Proveedor EFOS

puede ser incorrecto o perjudicial, porque los estados tienen significados jurídicos distintos.

## Mensaje recomendado

> Recibe una alerta si el RFC de un proveedor aparece en alguno de los listados oficiales relacionados con el artículo 69-B.

La alerta debe mostrar:

* Estatus.
* Fecha de publicación.
* Fuente oficial.
* Fecha de última consulta.
* Enlace al SAT.
* Explicación no jurídica.
* Recomendación de consultar a un profesional.

No decir:

> Este proveedor comete fraude.

Ni:

> Esta factura no es deducible.

El módulo debe presentarse como señal informativa, no como dictamen legal.

---

# 18. Mejorar la estructura de precios

La oferta actual muestra:

### soy612 Estándar

* Gratuito.
* Procesamiento local.
* Importación manual.
* Simulación.
* Borrador.

### soy612 Pro

* $149 MXN mensuales.
* Sincronización.
* Buzón inteligente.
* Monitoreo Anti-EFOS.

También aparece un selector mensual/anual con un ahorro anunciado del 20 %.

## Fortalezas

* Precio bajo y comprensible.
* Plan gratuito útil, no solamente una prueba.
* Diferenciación clara por automatización.
* Moneda local.
* Posicionamiento accesible para independientes.

## Mejoras

La tabla debe aclarar:

* Precio anual exacto.
* Si el IVA está incluido.
* Número de dispositivos.
* Límites de CFDI.
* Espacio de respaldo.
* Frecuencia de monitoreo 69-B.
* Periodo de retención.
* Exportación.
* Soporte.
* Recuperación de datos.
* Cancelación.
* Qué sucede al regresar al plan gratuito.
* Si el buzón procesa XML, PDF o ambos.
* Qué funcionalidades siguen disponibles sin conexión.

## Mensaje de oferta recomendado

> Empieza gratis y conserva el control manual. Actualiza a Pro cuando quieras automatizar la recepción y el respaldo de tus CFDI.

---

# 19. Diseñar mejor el “trial to value”

Para soy612, el momento de activación no es crear una cuenta. Es obtener un primer borrador útil.

## Secuencia recomendada

1. Confirmar que pertenece al régimen compatible.
2. Elegir periodo.
3. Importar entre tres y cinco CFDI.
4. Revisar clasificación.
5. Corregir posibles inconsistencias.
6. Ver ingresos y deducciones.
7. Obtener una proyección.
8. Abrir el borrador.
9. Exportar o copiar información.
10. Guardar el siguiente vencimiento.

## Indicador de activación

> Usuario que importó CFDI y generó su primer borrador mensual.

No medir éxito solamente por:

* Instalaciones.
* Correos en waitlist.
* Apertura del simulador.

---

# 20. Prevenir el dashboard vacío

Después de descargar una aplicación fiscal, un tablero sin información puede generar abandono.

## Recomendaciones

* Modo demostración con contribuyente ficticio.
* Tres CFDI de ejemplo.
* Recorrido guiado.
* Lista de tareas.
* Explicación de cada concepto.
* Botón “Importar mis primeros XML”.
* Indicador de progreso.
* Posibilidad de reiniciar el ejemplo.

## Checklist dentro de la app

> 1. Elige el periodo
> 2. Importa tus CFDI
> 3. Revisa ingresos cobrados
> 4. Revisa gastos pagados
> 5. Completa datos manuales
> 6. Genera tu borrador

---

# 21. Explicar mejor los conceptos fiscales de la interfaz

Expresiones como:

* Ingresos cobrados.
* Gastos deducibles.
* Bancarizados.
* ISR propio.
* IVA definitivo.
* PTU pagada.
* Pérdidas fiscales.

pueden ser claras para un contador, pero no para todos los profesionistas.

## Recomendación

Incorporar microexplicaciones:

> **Ingresos cobrados**
> Facturas cuyo pago fue efectivamente recibido durante el periodo, según la información disponible.

> **Gastos potencialmente deducibles**
> CFDI que cumplen los criterios automáticos revisados por soy612. Debes validar su relación con tu actividad y demás requisitos fiscales.

> **Pagados mediante medios bancarios**
> Gastos registrados con formas de pago distintas al efectivo cuando la regla aplicable lo requiere.

Evitar que una etiqueta de interfaz parezca una resolución fiscal definitiva.

---

# 22. Incorporar prueba social

No se observan testimonios, usuarios piloto, contadores colaboradores, métricas de uso o validaciones independientes visibles en la landing.

Esta es una debilidad importante porque el producto maneja información fiscal y presenta cálculos tributarios.

## Prueba social recomendada

### Profesionista

> “Antes reunía mis facturas el día de la declaración. Ahora tengo una proyección y un borrador antes de entrar al SAT.”

### Contador

> “Recibo los CFDI y el resumen del periodo organizados, lo que reduce el tiempo de preparación y las preguntas de último momento.”

### Usuario preocupado por privacidad

> “Pude revisar mis CFDI sin entregar mi Contraseña del SAT ni subir mi e.firma.”

## Evidencia adicional

* Número de borradores generados.
* Usuarios beta.
* CFDI procesados localmente.
* Meses de operación.
* Porcentaje que completa el primer borrador.
* Resultados de pruebas de cálculo.
* Opinión de contadores revisores.
* Auditoría de seguridad.

Solo deben mostrarse datos reales y verificables.

---

# 23. Evitar notificaciones invasivas de prueba social

Para una aplicación basada en privacidad, ventanas como:

> “José acaba de importar 35 facturas”

serían contraproducentes.

No conviene mostrar:

* Nombres.
* RFC.
* Ciudades.
* Actividad reciente.
* Cantidades.
* Información sobre declaraciones.

Una alternativa respetuosa sería:

> Más de ___ borradores generados localmente.

o:

> ___ usuarios participaron en la beta.

Siempre con datos agregados.

---

# 24. Utilizar un lead magnet alineado con el nicho

La calculadora de vencimientos ya funciona como herramienta gratuita. Puede complementarse con:

* Checklist mensual del Régimen 612.
* Plantilla para organizar CFDI cobrados y pagados.
* Guía para preparar información antes de abrir el SAT.
* Calendario fiscal personalizable.
* Checklist para trabajar con un contador sin compartir credenciales.
* Guía para revisar proveedores en listados del artículo 69-B.
* Formato de cierre fiscal mensual.
* Checklist de respaldo seguro de CFDI.

## Mejor opción

> Checklist mensual para preparar tu declaración del Régimen 612

La captación debe solicitar únicamente correo y consentimiento.

---

# 25. Presentar el “Botón del Contador”

El centro de soporte menciona un “Botón del Contador” que exporta comprobantes y cálculos organizados, pero esa función no aparece claramente en la landing ni en los planes.

Puede ser uno de los beneficios más atractivos porque evita posicionar soy612 como competidor del contador.

## Mensaje recomendado

> ### Tú mantienes el control. Tu contador recibe todo organizado.
>
> Exporta un paquete del periodo con tus CFDI, clasificación, cálculos y datos pendientes para revisión.

Esto abre además un segundo canal de adquisición:

* Contadores que recomiendan soy612.
* Despachos que lo utilizan con clientes.
* Programas de referidos profesionales.
* Licencias para cartera de contribuyentes.

---

# 26. Crear una estrategia para contadores

Aunque el producto se dirige al contribuyente, los contadores pueden convertirse en aliados o detractores.

## Objeciones previsibles

* “El cálculo podría estar equivocado”.
* “El cliente puede clasificar mal una factura”.
* “Voy a recibir información incompleta”.
* “Parece que pretende sustituirme”.
* “No sé qué versión fiscal utiliza”.
* “No puedo revisar cómo llegó al resultado”.

## Sección recomendada

> ### Diseñado para complementar, no sustituir, el trabajo contable
>
> soy612 ayuda al contribuyente a mantener su información ordenada durante el mes. El contador conserva la revisión profesional y la decisión final.

## Recursos para contadores

* Informe de cálculo.
* Fuente de cada cantidad.
* Exportación estructurada.
* Historial de ajustes.
* Notas del contribuyente.
* Casos no resueltos.
* PDF de revisión.
* CSV o Excel.
* Paquete de CFDI.

---

# 27. Añadir trazabilidad y explicabilidad

Cada cantidad proyectada debería permitir responder:

> ¿De dónde salió este número?

## Para cada total

Mostrar:

* CFDI incluidos.
* CFDI excluidos.
* Fecha de pago.
* Método de pago.
* Impuesto trasladado.
* Retenciones.
* Ajustes manuales.
* Regla aplicada.
* Advertencias.
* Fuente fiscal de referencia.

Esto es especialmente importante para generar confianza en el ISR o IVA proyectado.

---

# 28. Explicar el riesgo de pérdida local

Almacenar los datos únicamente en el dispositivo protege frente a exposición en la nube, pero genera otro riesgo:

> La pérdida, daño o cambio del dispositivo.

La landing enfatiza el beneficio local, pero no hace visible este intercambio.

## Recomendaciones para Estándar

* Exportación manual cifrada.
* Recordatorios de respaldo.
* Copia local elegida por el usuario.
* Advertencia antes de desinstalar.
* Procedimiento para migrar a otro dispositivo.
* Explicación de qué elimina la desinstalación.
* Bloqueo biométrico.
* Cifrado protegido por el sistema operativo.

Mensaje:

> Tus datos permanecen en tu dispositivo. Por ello, te recomendamos realizar respaldos periódicos desde la aplicación.

---

# 29. Mejorar la página de soporte

El centro de soporte es una buena señal de madurez. Explica:

* Que soy612 no es oficial.
* Diferencias entre planes.
* Cancelaciones.
* Reembolsos.
* Privacidad.
* Frase de recuperación.
* Relación con el contador.
* Credenciales.
* Dispositivos.

## Mejoras prioritarias

* Corregir la afirmación de disponibilidad en Android e iOS si todavía no está publicado.
* Añadir guías de importación.
* Publicar errores conocidos.
* Mostrar estado del servicio Pro.
* Añadir versión actual.
* Explicar compatibilidad de CFDI.
* Añadir procedimiento de respaldo.
* Añadir reporte de vulnerabilidades.
* Separar soporte técnico de consultas fiscales.
* No brindar asesoría fiscal personalizada sin el perfil profesional correspondiente.
* Crear una categoría “Antes de declarar”.

El tiempo de respuesta de uno a dos días hábiles es razonable para soporte general, pero puede resultar insuficiente cerca de un vencimiento. Podría ofrecerse:

> soy612 no garantiza atención inmediata para decisiones o fechas fiscales. Confirma siempre tus obligaciones con tu contador y fuentes oficiales.

---

# 30. Corregir los documentos legales antes del lanzamiento

## Fecha ausente en términos

La página de términos muestra:

> Última actualización:

sin fecha visible.

Debe corregirse.

## Inconsistencia de disponibilidad

Los términos describen contratación mediante Stripe, Apple y Google, y el soporte trata la app como disponible, mientras la landing indica que el producto está próximo.

Los documentos deberían distinguir:

* Funcionalidad actualmente disponible.
* Funcionalidad beta.
* Funcionalidad futura.
* Condiciones que entrarán en vigor al lanzar Pro.

## Aviso de privacidad futuro

El aviso actual describe principalmente:

* Procesamiento local de Estándar.
* Correo de lista de espera.
* Firebase para almacenar la lista.

Antes de lanzar Pro deberá explicar con precisión:

* Qué datos llegan al buzón.
* Procesamiento temporal.
* Proveedor de correo.
* Metadatos.
* Retención.
* Eliminación.
* Respaldos.
* Telemetría.
* Pagos.
* Tiendas de aplicaciones.
* Proveedores encargados.
* Transferencias.
* Recuperación de cuenta.
* Incidentes.

México publicó una nueva Ley Federal de Protección de Datos Personales en Posesión de los Particulares en marzo de 2025, por lo que conviene someter el aviso y los términos a revisión jurídica actualizada antes de activar los flujos Pro.

## Domicilio personal

El aviso publica un domicilio exacto asociado al responsable. Cuando se trate de un domicilio particular, conviene evaluar jurídicamente la posibilidad de utilizar un domicilio profesional o medio válido alternativo para reducir exposición personal, sin incumplir las obligaciones del aviso.

---

# 31. Mejorar el formulario de lista de espera

La lista solicita correo, plan y aparentemente un campo relacionado con empresa.

Para un profesionista independiente, “Empresa” puede resultar innecesario.

## Formulario recomendado

* Correo electrónico.
* Soy:

  * Profesionista independiente.
  * Persona con actividad empresarial.
  * Contador.
  * Otro.
* Plan de interés:

  * Gratis.
  * Pro.
  * Aún no lo sé.

CTA:

> Avisarme cuando esté disponible

Microcopy:

> Solo utilizaremos tu correo para informarte del lanzamiento. Puedes darte de baja en cualquier momento.

---

# 32. Utilizar analítica compatible con la promesa de privacidad

El aviso indica que actualmente no se emplean cookies publicitarias ni rastreadores de terceros.

No obstante, optimizar una landing requiere medir:

* Clics.
* Interacción con el simulador.
* Abandono.
* Registro en waitlist.
* Interés por plan.
* Dispositivo.
* Fuente de adquisición.

## Alternativas

* Analítica sin cookies.
* Datos agregados.
* Herramienta autoalojada.
* Eventos sin RFC, XML ni información fiscal.
* IP anonimizada o no conservada.
* Consentimiento cuando sea necesario.
* Documentación clara.

## Embudo recomendado

1. Visita.
2. Inicio del simulador.
3. Simulación completada.
4. Consulta de vencimiento.
5. Clic en beta.
6. Registro en waitlist.
7. Instalación.
8. Primer XML importado.
9. Primer borrador generado.
10. Regreso el mes siguiente.
11. Activación Pro.

---

# 33. Reforzar SEO y descubrimiento

El título actual prioriza:

> Tu escudo de tranquilidad fiscal.

Es memorable, pero no captura completamente la categoría.

## Título recomendado

> soy612 | Organiza CFDI y prepara tu declaración del Régimen 612

## Descripción recomendada

> Importa tus CFDI, proyecta ISR e IVA y prepara un borrador para el portal del SAT sin compartir tu Contraseña ni tu e.firma. Aplicación privada para personas físicas del Régimen 612.

## Contenido potencial

* Qué es el Régimen 612.
* Cómo preparar una declaración mensual.
* Diferencia entre factura emitida e ingreso cobrado.
* Cómo organizar CFDI.
* Fecha límite según sexto dígito del RFC.
* Contraseña del SAT vs. e.firma.
* Cómo trabajar con un contador sin compartir claves.
* Qué significan los listados 69-B.
* Cómo respaldar documentos fiscales de forma segura.
* Comparación entre hoja de cálculo y bitácora fiscal.

Todo contenido fiscal debe incluir:

* Fecha de actualización.
* Fuente oficial.
* Alcance.
* Disclaimer.
* Revisión periódica.

---

# 34. Mejorar el posicionamiento de marca

“soy612” es una marca eficaz para un producto vertical porque:

* Identifica un nicho preciso.
* Es corta.
* Puede generar comunidad.
* Se relaciona con la constancia fiscal.
* Permite extensiones especializadas.

Su principal limitación es que muchas personas no conocen el código de su régimen.

## Taglines recomendados

> **soy612**
> Tu bitácora fiscal privada.

> **soy612**
> Tus CFDI organizados. Tu declaración más clara.

> **soy612**
> Prepárate para declarar sin entregar tus claves.

> **soy612**
> Control fiscal para profesionistas independientes.

> **soy612**
> Organiza, proyecta y declara con mayor claridad.

“Tu escudo de tranquilidad fiscal” puede mantenerse como eslogan emocional secundario.

---

# 35. Estructura recomendada de la landing

## 1. Hero

* Régimen compatible.
* Resultado concreto.
* Privacidad.
* CTA coherente con el estado del producto.

## 2. Demostración inmediata

* Importar CFDI.
* Ver clasificación.
* Generar borrador.

## 3. Problema

* Desorden.
* Incertidumbre.
* Copiar cantidades.
* Compartir credenciales.

## 4. Cómo funciona

1. Importa.
2. Revisa.
3. Proyecta.
4. Captura en el SAT.

## 5. Qué permanece privado

Tabla de datos locales, datos sincronizados y datos nunca solicitados.

## 6. Beneficios

* Orden mensual.
* Proyección.
* Menos captura.
* Colaboración con contador.
* Recordatorios.

## 7. Simulador

Con explicación de que los datos no se transmiten.

## 8. Caso real o testimonio

Profesionista y contador.

## 9. Comparación de planes

Disponible vs. próximo.

## 10. Seguridad

Resumen no técnico y enlace al documento detallado.

## 11. Compatibilidad y limitaciones

Quién puede utilizarlo y casos no cubiertos.

## 12. Preguntas frecuentes

* Oficialidad.
* Precisión.
* Contador.
* Credenciales.
* Datos.
* Respaldo.
* Dispositivos.
* Cancelación.

## 13. CTA final

> Probar simulador
> Unirme a la beta

---

# 36. Propuesta condensada del primer bloque

> **Para personas físicas con actividad empresarial o profesional — Régimen 612**
>
> # Prepara tu declaración mensual sin entregar tus claves del SAT.
>
> Importa tus CFDI, conoce tus ingresos y deducciones y obtén un borrador organizado para capturarlo directamente en el portal del SAT. Con soy612 Estándar, tus datos permanecen en tu dispositivo.
>
> **[Probar el simulador]** [Unirme a la beta gratuita]
>
> No solicitamos tu Contraseña del SAT ni tu e.firma · Herramienta independiente y no oficial
>
> **Tus CFDI organizados. Tu declaración más clara.**

---

# 37. Prioridades recomendadas

## Prioridad crítica

1. Corregir la contradicción entre “Descargar” y “Próximamente”.
2. Definir claramente si Estándar está disponible y Pro continúa en desarrollo.
3. Limitar “100 % privado y local” al plan Estándar.
4. Resolver la incompatibilidad entre Email-to-App y Zero-Knowledge.
5. Sustituir promesas absolutas de privacidad y exactitud.
6. Corregir la fecha ausente de los términos.
7. Sincronizar landing, soporte, privacidad y términos.
8. Indicar con claridad qué hace y qué no hace el producto.
9. Mostrar versión y vigencia del motor fiscal.
10. Solicitar solamente el sexto dígito para calcular vencimientos.

## Prioridad alta

11. Convertir el hero en una promesa más concreta.
12. Escribir el nombre completo del Régimen 612.
13. Sustituir “CIEC” por “Contraseña del SAT —antes CIEC—”.
14. Explicar conceptos técnicos en lenguaje del usuario.
15. Mostrar un flujo completo desde CFDI hasta borrador.
16. Incorporar prueba social real.
17. Añadir revisión profesional fiscal.
18. Publicar un diagrama de flujo de datos.
19. Explicar respaldo y pérdida del dispositivo.
20. Presentar el Botón del Contador.
21. Diferenciar estados del artículo 69-B.
22. Actualizar el aviso de privacidad antes de lanzar Pro.

## Prioridad media

23. Crear contenido para contadores.
24. Añadir un checklist gratuito del Régimen 612.
25. Permitir agregar vencimientos al calendario.
26. Incorporar analítica respetuosa con la privacidad.
27. Crear modo demostración con CFDI ficticios.
28. Publicar un historial de actualizaciones fiscales.
29. Crear páginas SEO por problema.
30. Mostrar costo anual exacto.
31. Explicar límites y compatibilidad de cada plan.
32. Crear una política de reporte de vulnerabilidades.

---

# Conclusión

soy612 tiene una propuesta mejor delimitada que muchos Micro SaaS fiscales: conoce a su público, evita solicitar credenciales sensibles, muestra el producto y permite experimentar parte del valor antes del registro.

Su oportunidad comercial puede resumirse así:

> **No vender únicamente una calculadora de impuestos, sino un proceso mensual privado y ordenado que lleva al contribuyente desde sus CFDI hasta un borrador revisable.**

El principal trabajo pendiente no es agregar más funcionalidades. Es construir confianza demostrable alrededor de tres preguntas:

1. ¿Los cálculos son trazables y están actualizados?
2. ¿Mis datos realmente permanecen bajo mi control?
3. ¿Qué puedo utilizar hoy y qué sigue todavía en desarrollo?

Cuando la landing responda estas tres preguntas sin contradicciones, soy612 podrá posicionarse como una herramienta especializada, cercana y creíble para contribuyentes del Régimen 612.
