import { Injectable, OnModuleInit } from '@nestjs/common';
import { App, cert, getApps, initializeApp } from 'firebase-admin/app';
import { Firestore, getFirestore } from 'firebase-admin/firestore';

/**
 * Inicializa el SDK de Firebase Admin una sola vez por proceso. En Cloud Run
 * usa las credenciales de la cuenta de servicio adjunta al servicio
 * (Application Default Credentials) sin necesidad de un archivo de llave; en
 * local, respeta GOOGLE_APPLICATION_CREDENTIALS si está definida.
 */
@Injectable()
export class FirebaseService implements OnModuleInit {
  private app!: App;
  private firestoreInstance!: Firestore;

  onModuleInit(): void {
    const existing = getApps();
    if (existing.length > 0) {
      this.app = existing[0];
    } else {
      const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON;
      this.app = keyPath
        ? initializeApp({ credential: cert(JSON.parse(keyPath)) })
        : initializeApp();
    }
    this.firestoreInstance = getFirestore(this.app);
  }

  firestore(): Firestore {
    return this.firestoreInstance;
  }
}
