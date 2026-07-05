import { Injectable, Logger } from '@nestjs/common';
import { FieldValue } from 'firebase-admin/firestore';
import { FirebaseService } from '../firebase/firebase.service';
import { sha256Hex } from '../common/hash.util';
import { CreateWaitlistEntryDto } from './dto/create-waitlist-entry.dto';

@Injectable()
export class WaitlistService {
  private readonly logger = new Logger(WaitlistService.name);

  constructor(private readonly firebase: FirebaseService) {}

  /**
   * Registra un lead de la lista de espera. Si el honeypot viene relleno
   * (bot), no se persiste nada pero se responde éxito de todas formas para
   * no delatar la detección. El documento se indexa por el hash del email
   * para que reintentos del mismo correo actualicen el registro en vez de
   * duplicarlo.
   */
  async subscribe(dto: CreateWaitlistEntryDto, ipHash: string): Promise<{ accepted: true }> {
    if (dto.empresa) {
      this.logger.warn('Honeypot triggered on /waitlist, ignoring silently');
      return { accepted: true };
    }

    const email = dto.email.trim().toLowerCase();
    const docId = sha256Hex(email);
    const ref = this.firebase.firestore().collection('waitlist').doc(docId);
    const snapshot = await ref.get();

    if (snapshot.exists) {
      await ref.set({ plan: dto.plan, ipHash, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    } else {
      await ref.set({
        email,
        plan: dto.plan,
        ipHash,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    return { accepted: true };
  }
}
