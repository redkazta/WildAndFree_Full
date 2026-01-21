import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { HealthController } from './health/health.controller';
import { HealthService } from './health/health.service';

@Module({
  imports: [HttpModule],
  controllers: [AppController, HealthController],
  providers: [AppService, HealthService],
})
export class AppModule {}
