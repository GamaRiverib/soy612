# Plan de prueba cerrada en Google Play

## Objetivo

Completar el requisito de Google Play para poder solicitar acceso a producción: una prueba cerrada con al menos 12 verificadores que permanezcan opt-in durante 14 días continuos.

## Pendientes del owner

1. Reclutar verificadores
   - Reunir al menos 12 correos Google válidos.
   - Recomendado: 18 a 25 correos para tener margen si alguien no acepta o abandona.
   - Cada correo debe ser el que la persona usa en Google Play.

2. Configurar la lista en Play Console
   - Ir a Closed testing.
   - Agregar los correos manualmente o mediante Google Group.
   - Guardar cambios y confirmar que la release cerrada está activa.

3. Enviar instrucciones a verificadores
   - Link de opt-in: https://play.google.com/apps/testing/click.soy612
   - Pedir que acepten ser verificadores.
   - Pedir que instalen la app.
   - Pedir que no salgan del programa durante 14 días continuos.
   - Pedir que usen la app y reporten problemas a soporte@soy612.click.

4. Dar seguimiento durante los 14 días
   - Confirmar que al menos 12 personas hicieron opt-in.
   - Revisar feedback privado en Play Console.
   - Registrar errores, dudas de uso, dispositivos y versiones Android.
   - Corregir bugs críticos si aparecen.

5. Solicitar acceso a producción
   - Hacerlo cuando se cumplan 14 días continuos con al menos 12 testers opt-in.
   - Preparar respuestas sobre:
     - cómo se reclutaron testers;
     - qué feedback se recibió;
     - qué cambios se hicieron;
     - por qué la app está lista para producción.

## Mensaje sugerido para verificadores

Hola. Estoy haciendo la prueba cerrada de soy612 en Google Play.

Por favor entra con el correo de Google Play que me compartiste:

https://play.google.com/apps/testing/click.soy612

Pasos:

1. Acepta participar como verificador.
2. Instala la app desde Google Play.
3. Úsala al menos una vez y revisa el flujo principal.
4. No salgas del programa durante 14 días.
5. Si encuentras errores o algo confuso, escríbeme o manda correo a soporte@soy612.click.

Gracias por ayudar a validar la beta cerrada.

## Estado del landing

El landing ya está ajustado para este flujo:

- CTA principal: lista de espera para beta cerrada.
- Campo de correo: solicita el correo de Google Play.
- CTA secundario: enlace para verificadores ya aprobados.
- Link secundario: https://play.google.com/apps/testing/click.soy612
- Copy visible: explica que la beta cerrada requiere invitación previa.

## Nota técnica de despliegue

El formulario del landing envía el nuevo payload de waitlist:

```json
{
  "email": "tester@gmail.com",
  "perfil": "profesionista_independiente",
  "planInteres": "estandar",
  "empresa": ""
}
```

Por eso, para desplegar el landing actual en producción, también debe desplegarse el backend `soy612_cloud` actualizado. Si solo se despliega Firebase Hosting y Cloud Run conserva la versión anterior, el formulario puede fallar porque el backend anterior esperaba `plan` en vez de `perfil` y `planInteres`.
