# taxcal_app (Soy612)

App Flutter local-first para Personas Físicas del Régimen 612 (SAT, México). Ver `docs/` en la raíz del repo para la especificación funcional y el manual de marca.

## Publicar una nueva versión en Play Store

1. **Sube el número de versión en `pubspec.yaml`** (`version: X.Y.Z+N`) antes de compilar. El `+N` es el `versionCode` de Android — Play Console **rechaza** cualquier `.aab` con el mismo `versionCode` que uno ya subido a cualquier pista (incluida pruebas internas), así que cada build que se suba necesita un `+N` mayor al anterior.
2. Compila el bundle de release:
   ```
   flutter build appbundle --release
   ```
   Sale en `build/app/outputs/bundle/release/app-release.aab`.
3. Sube ese `.aab` en Play Console → tu app → Pruebas → (la pista que corresponda) → Crear nueva versión.

### Firma de release
El build de release firma con `android/key.properties` + `android/app/upload-keystore.jks` (ambos fuera de git vía `.gitignore`). Sin ese keystore no se puede generar un `.aab` válido para Play Store — **debe estar respaldado en un lugar seguro fuera de este equipo** (password manager, backup externo). Si se pierde, hay que pedir un restablecimiento de clave de carga a Google Play (Configuración → Integridad de la app / Protegido con Play), lo cual toma tiempo de revisión.

`applicationId`: `click.soy612`.
