import { Controller, Get, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { TenantInitResponse } from 'shared-types';
import { TenantService } from './tenant.service';

type TenantAwareRequest = Request & { tenantId?: string };

@Controller('gateway')
export class TenantController {
  constructor(private readonly tenantService: TenantService) {}

  @Get('config')
  async getConfig(
    @Req() req: TenantAwareRequest,
  ): Promise<TenantInitResponse & { tenant_id: string }> {
    const tenantId = req.tenantId ?? 'wild-and-free';
    const payload = await this.tenantService.initTenant(tenantId);
    return { tenant_id: tenantId, ...payload };
  }
}
