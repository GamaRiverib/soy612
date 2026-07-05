# soy612_cloud

Backend de **soy612 Cloud Gateway** (NestJS + TypeScript), desplegado en **Cloud Run** sobre el proyecto GCP/Firebase `soy612`. Ver el plan completo en `../docs/Especificación Técnica - soy612 Pro.md` y el plan de expansión vigente.

Este servicio nunca ve datos fiscales en claro ni llaves de cifrado del usuario (principio Zero-Knowledge). Todas las rutas viven bajo el prefijo global `/api` porque Firebase Hosting reenvía `/api/**` a este servicio conservando la ruta completa (ver `../firebase.json`). Por ahora (Fase 0) solo expone:

- `GET /api/health` — chequeo de salud.
- `POST /api/waitlist` — captura de leads del landing page (`{ email, plan: 'estandar' | 'pro' }`). Incluye honeypot anti-spam (`empresa`, debe venir vacío) y rate limiting (5 req/min por IP en esta ruta, 20 req/min global).

## Desarrollo local

```bash
npm install
cp .env.example .env   # ajusta CORS_ORIGIN si pruebas el landing en otro puerto
npm run start:dev
```

Requiere estar autenticado con `gcloud auth application-default login` (o tener `GOOGLE_APPLICATION_CREDENTIALS_JSON` en `.env`) para que `firebase-admin` pueda hablar con Firestore del proyecto `soy612`.

## Tests

```bash
npm test        # unitarios (Firestore mockeado, no toca datos reales)
npm run test:e2e
```

## Build y despliegue

```bash
npm run build
docker build -t soy612-cloud .
gcloud run deploy soy612-cloud --source . --project soy612 --region us-central1 --allow-unauthenticated
```

El despliegue real a Cloud Run/DNS se documenta y ejecuta manualmente por ahora (ver plan, Fase 0.4-0.6) — no se automatiza vía este README hasta que exista el pipeline de CI/CD.
