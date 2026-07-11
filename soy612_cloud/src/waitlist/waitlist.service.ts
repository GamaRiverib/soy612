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
  async subscribe(
    dto: CreateWaitlistEntryDto,
    ipHash: string,
  ): Promise<{ accepted: true }> {
    if (dto.empresa) {
      this.logger.warn('Honeypot triggered on /waitlist, ignoring silently');
      return { accepted: true };
    }

    const email = dto.email.trim().toLowerCase();
    const docId = sha256Hex(email);
    const ref = this.firebase.firestore().collection('waitlist').doc(docId);
    const snapshot = await ref.get();

    const leadData = {
      perfil: dto.perfil,
      planInteres: dto.planInteres,
      ipHash,
      updatedAt: FieldValue.serverTimestamp(),
    };

    if (snapshot.exists) {
      await ref.set(leadData, { merge: true });
    } else {
      await ref.set({
        email,
        ...leadData,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    return { accepted: true };
  }
}
