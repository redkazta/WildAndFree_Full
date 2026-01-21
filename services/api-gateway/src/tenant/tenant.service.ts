import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import type { TenantInitResponse } from 'shared-types';

@Injectable()
export class TenantService {
  constructor(private readonly http: HttpService) {}

  async initTenant(tenantId: string): Promise<TenantInitResponse> {
    const response = await lastValueFrom(
      this.http.get<TenantInitResponse>(
        `http://localhost:8080/api/v1/tenant/${encodeURIComponent(tenantId)}/init`,
      ),
    );

    return response.data;
  }
}

