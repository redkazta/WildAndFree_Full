import { Controller, Get } from '@nestjs/common';
import { CURRENT_TENANT } from 'shared-types/tenant.config';
import type { Artist } from 'shared-types';
import { InitService } from './init.service';

@Controller('gateway')
export class InitController {
  constructor(private readonly initService: InitService) {}

  @Get('init')
  async getInit(): Promise<{ tenant: typeof CURRENT_TENANT; artists: Artist[] }> {
    const artists = await this.initService.getArtists();
    return { tenant: CURRENT_TENANT, artists };
  }
}

