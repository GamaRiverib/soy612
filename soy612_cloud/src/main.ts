import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Firebase Hosting reenvía /api/** al servicio de Cloud Run conservando la
  // ruta completa (no la recorta), así que las rutas viven bajo /api aquí.
  app.setGlobalPrefix('api');

  app.use(helmet());

  const allowedOrigins = (process.env.CORS_ORIGIN ?? 'https://soy612.click')
    .split(',')
    .map((origin) => origin.trim());
  app.enableCors({ origin: allowedOrigins, methods: ['GET', 'POST'] });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  await app.listen(process.env.PORT ?? 8080);
}
bootstrap();
