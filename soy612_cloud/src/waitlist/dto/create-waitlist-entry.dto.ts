import {
  IsEmail,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export type WaitlistPerfil =
  'profesionista_independiente' | 'actividad_empresarial' | 'contador' | 'otro';
export type WaitlistPlanInteres = 'estandar' | 'pro' | 'no_se';

export class CreateWaitlistEntryDto {
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @IsIn([
    'profesionista_independiente',
    'actividad_empresarial',
    'contador',
    'otro',
  ])
  perfil!: WaitlistPerfil;

  @IsIn(['estandar', 'pro', 'no_se'])
  planInteres!: WaitlistPlanInteres;

  /**
   * Honeypot anti-spam: the real form leaves this empty. If it arrives with
   * content, the request is treated as bot traffic.
   */
  @IsOptional()
  @IsString()
  @MaxLength(200)
  empresa?: string;
}
