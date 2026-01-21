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

export interface Artist {
  id: string;
  name: string;
  role: string;
  image_url: string;
}

export interface TenantInitData {
  crew_name: string;
  artists: Artist[];
}

export interface TenantInitResponse {
  config: TenantConfig;
  data: TenantInitData;
}
