import { Injectable, type NestMiddleware } from '@nestjs/common';
import type { Request, Response } from 'express';

type TenantAwareRequest = Request & { tenantId?: string };

function resolveTenantId(req: Request): string {
  const envTenant = process.env.DEFAULT_TENANT_ID?.trim();
  if (envTenant) return envTenant;

  const headerTenant = req.header('x-tenant-id')?.trim();
  if (headerTenant) return headerTenant;

  const hostHeader = req.header('host')?.trim() ?? '';
  const hostname = hostHeader.split(':')[0];
  if (!hostname) return 'wild-and-free';

  const isIpv4 = /^\d{1,3}(\.\d{1,3}){3}$/.test(hostname);
  if (isIpv4 || hostname === '::1') return 'wild-and-free';

  const parts = hostname.split('.');
  if (parts.length >= 2 && parts[0] && parts[0] !== 'localhost') return parts[0];
  if (hostname !== 'localhost') return hostname;

  return 'wild-and-free';
}

@Injectable()
export class TenantResolverMiddleware implements NestMiddleware {
  use(req: TenantAwareRequest, res: Response, next: () => void) {
    req.tenantId = resolveTenantId(req);
    next();
  }
}
