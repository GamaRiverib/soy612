# **ESPECIFICACIÓN TÉCNICA DE SOFTWARE (BLUEPRINT): soy612 PRO**

## **Arquitectura de Software Híbrida: Local-First con Servicios Cloud Pasivos**

## **1\. Resumen Ejecutivo y Modelo de Negocio**

### **1.1 Visión del Producto**

**soy612** es la evolución de TaxCal App v2, consolidada como una aplicación móvil diseñada específicamente para contribuyentes mexicanos bajo el **Régimen de Personas Físicas con Actividad Empresarial y Servicios Profesionales (Régimen 612 del SAT)**.

La versión **soy612 Pro** adopta un modelo híbrido freemium: mantiene el motor de cálculo fiscal, el parseo XML nativo y el almacenamiento en el dispositivo de forma gratuita y local (*Local-First*), pero añade una capa de suscripción Micro-SaaS enfocada en la automatización de la captura, resguardo ciego de datos y blindaje fiscal del contribuyente.

┌────────────────────────────────────────────────────────────────────────┐  
│                          soy612 ENGINE (Flutter)                       │  
├──────────────────────────────────────┬─────────────────────────────────┤  
│          PLAN GRATUITO               │          PLAN PRO (SaaS)        │  
│          (Local-First)               │          (Cloud-Assisted)       │  
├──────────────────────────────────────┼─────────────────────────────────┤  
│ • Base de datos Isar Local           │ • Todo lo del plan Gratuito.    │  
│ • Importación manual de XMLs locales │ • Sincronización Zero-Knowledge │  
│ • Espejo SAT Interactivo (ISR/IVA)   │ • Buzón Inbound Email-to-App    │  
│ • Simulación Anual Acumulativa       │ • Monitoreo Anti-EFOS en App    │  
│ • "Botón del Contador" Local         │ • Alertas Proactivas Cloud Push │  
└──────────────────────────────────────┴─────────────────────────────────┘

### **1.2 Principio de Simplicidad**

Se prohíbe de forma mandatoria la adición de menús de configuración complejos, tableros de control saturados o flujos de autenticación tradicionales que requieran passwords complejos expuestos en la nube. Toda la administración de la suscripción Pro se maneja mediante compras integradas (*In-App Purchases* para iOS/Android) vinculadas al identificador anónimo del dispositivo o la cuenta de la tienda de aplicaciones.

## **2\. Arquitectura del Sistema Híbrido**

Para preservar la velocidad, disponibilidad offline y privacidad, **soy612** implementa el patrón **Local-First con Sincronización Pasiva**. El backend en la nube no posee base de datos relacional de los registros financieros del usuario; actúa como un intermediario ciego de ingesta e intercambio de datos.

                               ┌────────────────────────────────┐  
                               │     Servidor Inbound Email     │  
                               │   (Extractor XML/PDF temporal) │  
                               └──────────────┬─────────────────┘  
                                              │ (Webhook HTTPS)  
                                              ▼  
┌─────────────────────────┐    ┌────────────────────────────────┐  
│   Dispositivo B (iPad)  │    │     soy612 API Cloud Gateway   │  
│   • Clave local K\_E2EE  │    │                                │  
└────────────┬────────────┘    │ • Almacén Temporal Blobs (S3)  │  
             │                 │ • API de Hash de EFOS Diario   │  
             │ (Sync E2EE)     │ • Auth Anónima Firebase / Keys │  
             │                 └──────────────┬─────────────────┘  
             │                                │  
             │                                │ (Notificación Push Silenciosa)  
             ▼                                ▼  
┌───────────────────────────────────────────────────────────────┐  
│                    Dispositivo A (Smartphone)                 │  
│                    APLICACIÓN FLUTTER CLIENTE                 │  
│                                                               │  
│   ┌───────────────────────┐       ┌───────────────────────┐   │  
│   │   Isar DB Local       │ ◄──── │ Descifrado local AES  │   │  
│   │   (Fuente de Verdad)  │       │ con llave K\_E2EE      │   │  
│   └───────────────────────┘       └───────────────────────┘   │  
└───────────────────────────────────────────────────────────────┘

### **2.1 Componentes de Infraestructura Cloud**

1. **soy612 Cloud Gateway (Backend API):** Escrito en Node.js/TypeScript o Go, desplegado sin estado (Serverless/Docker) para costos operativos mínimos.  
2. **Object Storage (S3 Compatible):** Almacenamiento ciego y cifrado para respaldos e ingesta temporal de XMLs.  
3. **Inbound Mail Processor (SendGrid Inbound Parse o AWS SES):** Recibe correos en tu\_rfc@soy612.cloud, extrae archivos XML y PDF, y los sube encriptados al almacenamiento temporal.  
4. **Firebase Cloud Messaging (FCM):** Canal de notificaciones push silenciosas para despertar la sincronización local en segundo plano.

## **3\. Criptografía y Sincronización Zero-Knowledge (Fase 1\)**

El usuario no confía sus datos financieros a la nube de soy612. El sistema garantiza seguridad absoluta mediante cifrado de extremo a extremo (E2EE).

### **3.1 Derivación de la Llave de Cifrado (![][image1])**

Cuando el usuario activa el plan Pro, el cliente Flutter genera una frase de recuperación local de 12 palabras (BIP39). A partir de esta frase y un *salt* único generado en el dispositivo, se deriva la clave de cifrado simétrico mediante el algoritmo PBKDF2:

![][image2]La llave ![][image1] se almacena exclusivamente en el almacenamiento seguro del dispositivo utilizando el paquete flutter\_secure\_storage (Keychain en iOS, Keystore en Android). **Bajo ninguna circunstancia la llave ![][image1] es transmitida al servidor de soy612.**

### **3.2 Protocolo de Sincronización de Respaldo**

#### **Proceso de Carga (Backup)**

1. La app cliente Flutter detecta cambios locales en la base de datos Isar.  
2. Transcurridos 5 minutos de inactividad, se ejecuta una tarea asíncrona local (*Isolate* de Dart) que exporta las colecciones relevantes de Isar a un archivo JSON comprimido en formato .tar.gz.  
3. El archivo comprimido se cifra localmente utilizando **AES-GCM-256** con la llave ![][image1] y un vector de inicialización (IV) de 96 bits generado aleatoriamente.  
4. Se calcula el código de autenticación de mensajes (MAC) para asegurar la integridad de los datos.  
5. El Blob cifrado resultante se envía al API Gateway de soy612 junto con un hash SHA-256 del ID del usuario (anónimo) para sobrescribir su respaldo en el Object Storage.

#### **Proceso de Descarga (Restore/Sync)**

1. Al iniciar la app en un nuevo dispositivo, el usuario ingresa sus 12 palabras de recuperación.  
2. El dispositivo calcula localmente la llave ![][image1].  
3. Solicita el último Blob cifrado desde el Object Storage del servidor.  
4. Descifra localmente los bytes recibidos utilizando ![][image1] y el IV incluido en la cabecera del payload.  
5. Reconstruye la base de datos local Isar a partir del JSON obtenido, actualizando la interfaz reactiva sin pérdidas de datos.

## **4\. Buzón Inteligente de Facturas (Email-to-App) (Fase 2\)**

Este módulo elimina la necesidad de descargar archivos XML del SAT o portales de proveedores y cargarlos manualmente en la aplicación.

Proveedor ──► Envía Email con XML/PDF a \[rfc\]@soy612.cloud ──► Inbound Parser SES/SendGrid  
                                                                       │  
                                                                       ▼  
App Cliente ◄── Descarga, Desencripta y Procesa Localmente ◄── Ingesta Temp en Cloud (E2EE)

### **4.1 Ciclo de Vida de la Ingestión de Comprobantes**

1. **Asignación del Buzón:** Al suscribirse, el usuario obtiene un alias de correo único estructurado de la siguiente forma: \[rfc\_normalizado\]@soy612.cloud.  
2. **Procesamiento Inbound:** El servicio de correo recibe los mensajes dirigidos a la dirección asignada.  
   * Si el correo no contiene archivos adjuntos con extensión .xml, el correo es descartado inmediatamente.  
   * Si contiene archivos .xml (y opcionalmente .pdf asociados), el servidor de correo extrae los metadatos básicos y los adjuntos.  
3. **Cifrado en Tránsito y Reposo Intermedio:**  
   * El servidor del buzón solicita la llave pública RSA de sesión del usuario (generada por la app Flutter al arrancar y subida al servidor de forma anónima).  
   * El backend cifra los archivos XML y PDF utilizando esta llave pública.  
   * Los almacena temporalmente en el Bucket S3 asignado a la cola de ingesta del usuario.  
   * El servidor emite una notificación push silenciosa (FCM) al dispositivo del usuario: {"action": "SYNC\_INBOX"}.  
4. **Procesamiento Local en el Dispositivo:**  
   * Al recibir la notificación, la app Flutter se despierta en segundo plano (o al abrirse la app).  
   * Descarga los paquetes cifrados de la cola de ingesta.  
   * Desencripta los XML/PDF localmente con su llave privada RSA guardada en el *Secure Storage*.  
   * Ejecuta el parser XML nativo en un *Isolate* de Dart para extraer el RFC emisor/receptor, conceptos, subtotal, IVA, retenciones y UUID.  
   * Inserta de forma atómica los nuevos CFDI en Isar.  
   * Solicita al API Gateway la eliminación inmediata de los archivos del Bucket temporal con una petición firmada. **Tiempo de permanencia máximo en la nube: 10 minutos.**

## **5\. Motor Anti-EFOS Local-First (Fase 2\)**

Protección proactiva contra el Artículo 69-B del Código Fiscal de la Federación (CFF) en México. Previene que el contribuyente deduzca facturas emitidas por empresas fantasma o simuladoras.

### **5.1 Pipeline de Datos EFOS**

Portal del SAT (Listas Oficiales 69-B)  
       │  
       ▼ (Scraper / Cron Job diario en el Backend)  
 soy612 Backend (Genera lista optimizada de hashes SHA-256)  
       │  
       ▼ (Descarga asíncrona ligera en la App)  
 App Cliente Flutter (Cotejo local contra RFCs de Proveedores en Isar)

### **5.2 Estructura del Payload de EFOS del Servidor**

Para evitar la transmisión de listas de texto plano pesadas e ineficientes que saturen el plan de datos móviles del usuario, el backend de soy612 procesa diariamente las listas oficiales del SAT y genera un archivo optimizado en formato Protocol Buffers (Protobuf) o JSON gzip conteniendo únicamente hashes SHA-256 truncados de los RFCs publicados en estado "Definitivo" o "Presunto".

{  
  "last\_update": "2026-07-04T00:00:00Z",  
  "efos": {  
    "presuntos": \[  
      "e3b0c44298fc1c149afbf4c8996fb924",  
      "f52fbd32b2b3b4b5b6b7b8b9b0b1b2b3"  
    \],  
    "definitivos": \[  
      "c3ab8ff13720e8ad9047dd39466b3c89",  
      "a8fd32b2b3b4b5b6b7b8b9b0b1b2b3b4"  
    \]  
  }  
}

### **5.3 Algoritmo de Cotejo Local en Flutter**

El proceso de validación se ejecuta completamente en el cliente para mantener la privacidad absoluta de los proveedores del usuario (el servidor nunca recibe la lista de RFCs con los que opera el usuario).

// Algoritmo ejecutado en Isolate de Flutter  
Future\<void\> verificarEfosLocales(List\<String\> efosDefinitivosHashes) async {  
  final isar \= Isar.getInstance();  
    
  // 1\. Obtener todos los RFCs de proveedores únicos en la base de datos Isar  
  final proveedores \= await isar.invoiceLocals  
      .where()  
      .filter()  
      .isExpenseEqualTo(true)  
      .distinctByIssuerRfc()  
      .findAll();

  for (var proveedor in proveedores) {  
    // 2\. Calcular hash local del RFC del proveedor (sin salt, en minúsculas)  
    final rfcHash \= calcularSha256Truncado(proveedor.issuerRfc.toLowerCase());  
      
    // 3\. Evaluar coincidencia  
    if (efosDefinitivosHashes.contains(rfcHash)) {  
      // 4\. Marcar en la base de datos local para activar la alerta en UI  
      proveedor.isEfosMatched \= true;  
      proveedor.efosStatus \= "Definitivo";  
      await isar.writeTxn(() \=\> isar.invoiceLocals.put(proveedor));  
    }  
  }  
}

## **6\. El "Botón del Contador" (Colaboración Híbrida \- Fase 1\)**

Facilita la interacción mensual entre el contribuyente de la Actividad Empresarial (Régimen 612\) y su contador externo, organizando y estructurando la información sin otorgar accesos directos que comprometan credenciales.

### **6.1 Estructura del Archivo de Exportación (.ZIP)**

Al presionar el "Botón del Contador" desde el Dashboard o la sección de Reportes, la app cliente Flutter empaqueta de forma local y en tiempo real un archivo comprimido denominado soy612\_Reporte\_\[RFC\]\_\[Mes\]\_\[Año\].zip con la siguiente estructura física:

soy612\_Reporte\_XAXX010101000\_Junio\_2026/  
├── 01\_Reportes/  
│   ├── Reporte\_Mensual\_soy612\_Junio\_2026.pdf (Papel de trabajo, ISR e IVA)  
│   └── Conciliaciones\_Bancarias\_Sugeridas.pdf (Listado de facturas pagadas vs diferidas)  
├── 02\_Ingresos/  
│   ├── PUE/  
│   │   ├── FAC\_001\_UUID1.xml  
│   │   └── FAC\_001\_UUID1.pdf  
│   └── PPD\_Cobrados/  
│       ├── FAC\_002\_UUID2.xml  
│       └── CRP\_002\_UUID2\_PAGO.xml (Complemento de Recepción de Pagos relacionado)  
├── 03\_Egresos/  
│   ├── Deducibles/  
│   │   ├── COMPRA\_01\_UUID3.xml  
│   │   └── COMPRA\_01\_UUID3.pdf  
│   └── No\_Deducibles/  
│       └── GASTO\_PERS\_UUID4.xml  
└── datos\_estructurados\_soy612.json (Volcado de datos en JSON para importación directa)

### **6.2 Estructura del JSON Estructurado para el Contador (datos\_estructurados\_soy612.json)**

Este archivo permite al despacho contable del contador importar directamente la información procesada por la app a sus sistemas corporativos (Contpaqi, COI, etc.) sin necesidad de recaptura manual.

{  
  "version\_app": "3.0.0-pro",  
  "rfc\_contribuyente": "XAXX010101000",  
  "regimen\_fiscal": "612",  
  "ejercicio": 2026,  
  "periodo\_mes": 6,  
  "resumen\_calculos": {  
    "ingresos\_percibidos": 85400.00,  
    "deducciones\_autorizadas": 32100.00,  
    "utilidad\_fiscal": 53300.00,  
    "isr\_causado": 8231.45,  
    "iva\_trasladado\_cobrado": 13664.00,  
    "iva\_acreditable\_pagado": 5136.00,  
    "iva\_a\_cargo": 8528.00  
  },  
  "transacciones": {  
    "ingresos": \[  
      {  
        "uuid": "e3b0c442-98fc-1c14-9afb-f4c8996fb924",  
        "folio": "A-154",  
        "rfc\_receptor": "CLI970101XX1",  
        "razon\_social": "Clientes de México S.A.",  
        "subtotal": 50000.00,  
        "iva\_trasladado": 8000.00,  
        "total": 58000.00,  
        "metodo\_pago": "PUE",  
        "fecha\_emision": "2026-06-15T10:30:00Z",  
        "fecha\_flujo\_efectivo": "2026-06-15T10:30:00Z"  
      }  
    \],  
    "egresos": \[  
      {  
        "uuid": "c3ab8ff1-3720-e8ad-9047-dd39466b3c89",  
        "folio": "7749",  
        "rfc\_emisor": "PRO890202TT5",  
        "razon\_social": "Proveedora de Insumos S.A.",  
        "subtotal": 20000.00,  
        "iva\_trasladado": 3200.00,  
        "total": 23200.00,  
        "metodo\_pago": "PUE",  
        "es\_deducible": true,  
        "fecha\_emision": "2026-06-18T14:22:00Z",  
        "fecha\_flujo\_efectivo": "2026-06-19T09:00:00Z"  
      }  
    \]  
  }  
}

## **7\. Esquema de Datos Isar Modificado (Modelos Locales)**

Para soportar las funciones de la versión **soy612 Pro**, se modifican los esquemas de Isar locales añadiendo decoradores e índices optimizados de sincronización.

import 'package:isar/isar.dart';

part 'invoice\_local.g.dart';

@collection  
class InvoiceLocal {  
  Id id \= Isar.autoIncrement;

  @Index(unique: true, replace: true)  
  late String uuid; // UUID del CFDI como llave primaria lógica

  late String folio;  
  late DateTime emissionDate;  
    
  // Control de Flujo de Efectivo  
  late DateTime? paymentEffectiveDate;   
  late bool isPaid;

  // Clasificación Fiscal  
  late String issuerRfc;  
  late String issuerName;  
  late String receiverRfc;  
  late String receiverName;  
    
  late double subtotal;  
  late double taxedIva;  
  late double total;  
    
  late bool isExpense; // true \= egreso, false \= ingreso  
  late bool isDeductible; // switch reactivo del usuario

  // \--- NUEVOS CAMPOS VERSIONES PRO (FASES 1 & 2\) \---  
    
  late bool isSynced; // Indicador de sincronización local \-\> Cloud  
  late DateTime? lastSyncedAt;

  // Datos Inbound (Email)  
  late bool isFromEmailInbound;  
  late String? inboundEmailSource; // Correo de procedencia

  // Validación EFOS (Art 69-B)  
  late bool isEfosMatched;   
  late String? efosStatus; // "Presunto", "Definitivo", "Desvirtuado"  
  late DateTime? lastEfosCheckedAt;  
}

## **8\. Seguridad y Cumplimiento de Privacidad Legal (México)**

### **8.1 Ley Federal de Protección de Datos Personales (LFPDPPP)**

Al migrar a un modelo SaaS híbrido, **soy612** se sujeta a la LFPDPPP en México como **Responsable** del tratamiento de datos. No obstante, al implementar criptografía **Zero-Knowledge**, se mitiga la responsabilidad legal sustancialmente:

1. El backend de la app procesa únicamente "Blobs cifrados" e inconexos de datos financieros.  
2. Al no poseer las claves de descifrado, **soy612** se encuentra materialmente imposibilitado para visualizar, explotar, comercializar o sufrir filtraciones ilegibles de la información fiscal de los contribuyentes.  
3. El Aviso de Privacidad incorporado en el Onboarding de la app detallará explícitamente el uso de criptografía local y la exención del almacenamiento de datos legibles por parte del proveedor de software.

### **8.2 Cláusula Obligatoria de Exención de Responsabilidad en soy612 Pro**

Tanto en la pantalla de suscripción Pro, el Onboarding y al pie de los reportes PDF enviados al contador se desplegará el siguiente aviso:

**"La aplicación soy612, incluyendo sus funciones de sincronización cifrada Pro, buzón automatizado de facturas y monitoreo de listas de EFOS, se constituye única y exclusivamente como una bitácora contable de uso privado y un simulador interactivo para facilitar la preparación visual y organización de datos del contribuyente ante el Régimen 612\. La herramienta carece de conexión, API o autorización formal por parte del Servicio de Administración Tributaria (SAT) o la Secretaría de Hacienda y Crédito Público (SHCP). soy612 no asume responsabilidad solidaria por discrepancias, omisiones o errores en las declaraciones finales, las cuales deben ser validadas y enviadas de forma manual por el contribuyente o su contador directamente a través del portal oficial del SAT."**

## **9\. Estrategia de Testing para el Backend del Micro-SaaS**

Para garantizar la estabilidad y el "mantenimiento cero" del backend ligero de **soy612 Pro**, se requiere la implementación obligatoria de las siguientes pruebas de integración:

1. **Test de Cifrado de Blobs (Zero-Knowledge Validation):** Verificar que el servidor rechaza cualquier intento de lectura del payload de respaldo enviado por la app de Flutter y que no se almacena ningún RFC en texto plano asociado a las bases de datos del backend.  
2. **Test de Parseo Inbound (Email-to-App):** Simular el envío de un correo electrónico con múltiples XMLs mal formados, comprobando que el microservicio extrae únicamente los nodos XML válidos bajo la especificación del CFDI 4.0 del SAT, los cifra y elimina de inmediato los archivos temporales de almacenamiento local del servidor en un tiempo menor a 5 segundos.  
3. **Test de Consistencia EFOS:** Comprobar que el cron job actualiza la lista diaria del Artículo 69-B, genera adecuadamente el hash SHA-256 de los RFCs publicados y reduce el tamaño de descarga del payload final por debajo de 500 KB para no consumir ancho de banda móvil de los usuarios de la aplicación.

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADcAAAAaCAYAAAAT6cSuAAAC30lEQVR4Xu2XS2hTQRSGU4ISH0hdxEheNy9FIioYRBB0oyh148aVYgVBXImImyKKWCgouAu4UHSnddGN2I0ggiA+QFBaN6ERXPjoxoVKQbCg3587E6cDNSlYbOD+8DMzZ845c87MnMlNLBYhQoT/hnw+vzcIgo/wl8PPhULhuNVhPAJn7Txz91Op1CrXz5IGQd+CP4rF4n5/rlQqbWTuORsxSGIJf35Jg6DXwpckMJXJZLLe3D7kD2DRlfcMSKBK8J/guHMyceRnGF/JZrMr5hj0EkjimKmlIY2TyeRqxtdN3fV56r0FEqnD79TbHhLaRP8VfEa/39ftKTj11qQ9TTuqxPS4wAFfv6fg1NsMvFir1ZbRHgnCp39UY98G+QX4Ajawf0L7WOSkJxjfsz8T9DcH4a2oqy9ZLpfbbWwaxkfL1vRfc3u2duu/I2y9wfMxU184Wc94Ek7zmGzxTFpA5xDzTYJNW1m5XF6H7Ia5DTV0ziKOKyHk73TtpScb2cpH22H4gF2yOp38/zH7C4Lw961Vb5582CQ97Mot/MWx36ZXFdkJ/ZzocaLf0EaZ2zCmtaTrJyd9Y7MTHujGv41jXjj11grCndOJIZ+Gk/6c4C5ugq+rX61Wl2tcqVSSChbVPtoE8+PSka2fnAI2/Xg6nV7Zjf92IPMB5R0YfYFjvoGz27NswKA7J5jFVaeqjSZsuFfIhVlH9VMzY5vchEj/m03UYiH+50CfWCi/hz+D8Orp8fgAj5r5lHFqvyfVvuE0N1gf7s7GwtO5qr4JfJej18/4rivzT46kD6tvNnRAp9Ot/0WBt3iMa7iGJq7atd+nJrFrBF9V4PpGldxPjjYhqkyQn+vW/6LBX9wgjmxE11DJoHNZuyydQvhYnJKSn5wFsoOF8IXt6N+R/VuwwydZ5Cn8Cu/Am/A2fAunFJDRaf9NEnX9aLcHYS3PMH5obMVHkimpbvz7MUWIECFChIXgNxytHNZz36o3AAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,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>