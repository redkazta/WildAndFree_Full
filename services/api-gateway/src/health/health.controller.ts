import { Controller, Get } from '@nestjs/common';
import type { HealthStatus } from 'shared-types';
import { HealthService } from './health.service';

@Controller('gateway')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get('health')
  async getHealth(): Promise<HealthStatus> {
    return this.healthService.getCoreEngineHealth();
  }
}

