import { Module, type MiddlewareConsumer, type NestModule } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { HealthController } from './health/health.controller';
import { HealthService } from './health/health.service';
import { InitController } from './init/init.controller';
import { InitService } from './init/init.service';
import { TenantController } from './tenant/tenant.controller';
import { TenantResolverMiddleware } from './tenant/tenant.middleware';
import { TenantService } from './tenant/tenant.service';
import { TagsModule } from './tags/tags.module';

@Module({
  imports: [HttpModule, TagsModule],
  controllers: [AppController, HealthController, TenantController, InitController],
  providers: [
    AppService,
    HealthService,
    TenantService,
    TenantResolverMiddleware,
    InitService,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(TenantResolverMiddleware).forRoutes('*');
  }
}
