import { Module, type MiddlewareConsumer, type NestModule } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { HealthController } from './health/health.controller';
import { HealthService } from './health/health.service';
import { TenantController } from './tenant/tenant.controller';
import { TenantResolverMiddleware } from './tenant/tenant.middleware';
import { TenantService } from './tenant/tenant.service';

@Module({
  imports: [HttpModule],
  controllers: [AppController, HealthController, TenantController],
  providers: [AppService, HealthService, TenantService, TenantResolverMiddleware],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(TenantResolverMiddleware).forRoutes('*');
  }
}
