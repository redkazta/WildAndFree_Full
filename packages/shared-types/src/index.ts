export interface HealthStatus {
  status: string;
  engine: string;
  crew: string;
  timestamp: string;
}

export type TenantModules = Record<string, boolean>;

export interface TenantConfig {
  id: string;
  name: string;
  primary_color: string;
  secondary_color: string;
  modules: TenantModules;
}

export interface TenantInitData {
  crew_name: string;
}

export interface TenantInitResponse {
  config: TenantConfig;
  data: TenantInitData;
}
