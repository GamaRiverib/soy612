import { IsEmail, IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export type WaitlistPlan = 'estandar' | 'pro';

export class CreateWaitlistEntryDto {
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @IsIn(['estandar', 'pro'])
  plan!: WaitlistPlan;

  /**
   * Honeypot anti-spam: campo que el formulario real nunca envía con
   * contenido. Si llega no vacío, la petición viene de un bot.
   */
  @IsOptional()
  @IsString()
  @MaxLength(200)
  empresa?: string;
}
