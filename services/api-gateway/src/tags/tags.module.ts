import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TagsController } from './tags.controller';
import { TagsService } from './tags.service';

@Module({
  imports: [
    HttpModule.register({
      baseURL: 'http://localhost:8080/api/v1',
      timeout: 5000,
      headers: {
        'Content-Type': 'application/json',
      },
    }),
  ],
  controllers: [TagsController],
  providers: [TagsService],
})
export class TagsModule {}
