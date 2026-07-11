import { ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { FirebaseService } from './../src/firebase/firebase.service';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;
  const set = jest.fn().mockResolvedValue(undefined);
  const get = jest.fn().mockResolvedValue({ exists: false });
  const doc = jest.fn().mockReturnValue({ get, set });
  const collection = jest.fn().mockReturnValue({ doc });

  beforeEach(async () => {
    jest.clearAllMocks();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(FirebaseService)
      .useValue({
        firestore: () => ({ collection }),
        onModuleInit: () => undefined,
      })
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.init();
  });

  it('/api/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/api/health')
      .expect(200)
      .expect({ status: 'ok' });
  });

  it('/api/waitlist (POST) accepts a valid lead', async () => {
    await request(app.getHttpServer())
      .post('/api/waitlist')
      .send({
        email: 'beta@soy612.click',
        perfil: 'profesionista_independiente',
        planInteres: 'estandar',
      })
      .expect(201)
      .expect({ accepted: true });

    expect(collection).toHaveBeenCalledWith('waitlist');
    expect(set).toHaveBeenCalledWith(
      expect.objectContaining({
        email: 'beta@soy612.click',
        perfil: 'profesionista_independiente',
        planInteres: 'estandar',
      }),
    );
  });

  it('/api/waitlist (POST) rejects invalid payloads', () => {
    return request(app.getHttpServer())
      .post('/api/waitlist')
      .send({
        email: 'no-es-correo',
        perfil: 'otro',
        planInteres: 'premium',
      })
      .expect(400);
  });

  afterEach(async () => {
    await app.close();
  });
});
