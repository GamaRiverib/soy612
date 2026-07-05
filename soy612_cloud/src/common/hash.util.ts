import { createHash } from 'node:crypto';

/** SHA-256 hex digest. Se usa para no persistir IPs/emails en claro más de lo necesario. */
export function sha256Hex(value: string): string {
  return createHash('sha256').update(value).digest('hex');
}
