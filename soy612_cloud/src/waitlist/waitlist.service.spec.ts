import { Test, TestingModule } from '@nestjs/testing';
import { FirebaseService } from '../firebase/firebase.service';
import { WaitlistService } from './waitlist.service';

function buildFakeFirestore(existing: boolean) {
  const set = jest.fn().mockResolvedValue(undefined);
  const get = jest.fn().mockResolvedValue({ exists: existing });
  const doc = jest.fn().mockReturnValue({ get, set });
  const collection = jest.fn().mockReturnValue({ doc });
  return { collection, doc, get, set };
}

describe('WaitlistService', () => {
  let service: WaitlistService;
  let fakeFirestore: ReturnType<typeof buildFakeFirestore>;
  let firebaseService: { firestore: jest.Mock };

  async function setup(existing: boolean) {
    fakeFirestore = buildFakeFirestore(existing);
    firebaseService = { firestore: jest.fn().mockReturnValue(fakeFirestore) };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WaitlistService,
        { provide: FirebaseService, useValue: firebaseService },
      ],
    }).compile();

    service = module.get(WaitlistService);
  }

  it('writes a new entry with createdAt when the email has not signed up before', async () => {
    await setup(false);

    const result = await service.subscribe(
      {
        email: 'Nueva@Correo.com',
        perfil: 'profesionista_independiente',
        planInteres: 'pro',
      },
      'iphash',
    );

    expect(result).toEqual({ accepted: true });
    expect(fakeFirestore.collection).toHaveBeenCalledWith('waitlist');
    expect(fakeFirestore.set).toHaveBeenCalledWith(
      expect.objectContaining({
        email: 'nueva@correo.com',
        perfil: 'profesionista_independiente',
        planInteres: 'pro',
        ipHash: 'iphash',
        createdAt: expect.anything(),
      }),
    );
  });

  it('merges (no duplicate) when the email already exists', async () => {
    await setup(true);

    await service.subscribe(
      {
        email: 'ya@existe.com',
        perfil: 'actividad_empresarial',
        planInteres: 'estandar',
      },
      'iphash2',
    );

    expect(fakeFirestore.set).toHaveBeenCalledWith(
      {
        perfil: 'actividad_empresarial',
        planInteres: 'estandar',
        ipHash: 'iphash2',
        updatedAt: expect.anything(),
      },
      { merge: true },
    );
  });

  it('silently ignores honeypot submissions without writing to Firestore', async () => {
    await setup(false);

    const result = await service.subscribe(
      {
        email: 'bot@spam.com',
        perfil: 'contador',
        planInteres: 'pro',
        empresa: 'Acme Bots Inc',
      },
      'iphash3',
    );

    expect(result).toEqual({ accepted: true });
    expect(fakeFirestore.collection).not.toHaveBeenCalled();
  });
});
