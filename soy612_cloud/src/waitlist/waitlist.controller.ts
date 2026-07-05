import { Body, Controller, HttpCode, HttpStatus, Post, Req } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { Request } from 'express';
import { sha256Hex } from '../common/hash.util';
import { CreateWaitlistEntryDto } from './dto/create-waitlist-entry.dto';
import { WaitlistService } from './waitlist.service';

@Controller('waitlist')
export class WaitlistController {
  constructor(private readonly waitlistService: WaitlistService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  async create(@Body() dto: CreateWaitlistEntryDto, @Req() req: Request) {
    const ip = req.ip ?? req.socket.remoteAddress ?? 'unknown';
    return this.waitlistService.subscribe(dto, sha256Hex(ip));
  }
}
