import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import type { HealthStatus } from 'shared-types';

@Injectable()
export class HealthService {
  constructor(private readonly http: HttpService) {}

  async getCoreEngineHealth(): Promise<HealthStatus> {
    const response = await lastValueFrom(
      this.http.get<HealthStatus>('http://localhost:8080/api/v1/health'),
    );

    return response.data;
  }
}
