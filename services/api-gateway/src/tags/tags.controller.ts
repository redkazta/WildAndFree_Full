import {
  Controller,
  Get,
  Post,
  Delete,
  Headers,
  Body,
  Param,
} from '@nestjs/common';
import { TagsService } from './tags.service';
import type {
  CreateTagRequest,
  StatusResponse,
  Tag,
  TagsListResponse,
  UserTagsResponse,
  UsersWithTagsResponse,
} from 'shared-types';

@Controller('tags')
export class TagsController {
  constructor(private readonly tagsService: TagsService) {}

  @Get('my-tags')
  async getMyTags(
    @Headers('x-user-id') userId: string,
  ): Promise<UserTagsResponse> {
    if (!userId) {
      throw new Error('User ID required');
    }
    return this.tagsService.getUserTags(userId);
  }

  @Get('all')
  async getAllTags(): Promise<TagsListResponse> {
    return this.tagsService.getAllTags();
  }

  @Post('assign')
  async assignTag(
    @Headers('x-user-id') actorId: string,
    @Body() assignDto: { userId?: string; tagId: number },
  ): Promise<StatusResponse> {
    if (!actorId) {
      throw new Error('User ID required');
    }
    const targetUserId = assignDto.userId || actorId;
    return this.tagsService.assignTagToUser(targetUserId, assignDto.tagId);
  }

  @Delete('remove/:tagId')
  async removeTag(
    @Headers('x-user-id') actorId: string,
    @Param('tagId') tagId: string,
    @Body() body: { userId?: string },
  ): Promise<StatusResponse> {
    if (!actorId) {
      throw new Error('User ID required');
    }
    const targetUserId = body?.userId || actorId;
    return this.tagsService.removeTagFromUser(targetUserId, parseInt(tagId));
  }

  // Admin endpoints
  @Post('create')
  async createTag(
    @Headers('x-user-id') userId: string,
    @Body() createTagDto: CreateTagRequest,
  ): Promise<Tag> {
    if (!userId) {
      throw new Error('User ID required for admin operations');
    }
    return this.tagsService.createTag(createTagDto, userId);
  }

  @Delete('delete/:tagId')
  async deleteTag(
    @Headers('x-user-id') userId: string,
    @Param('tagId') tagId: string,
  ): Promise<StatusResponse> {
    if (!userId) {
      throw new Error('User ID required for admin operations');
    }
    return this.tagsService.deleteTag(parseInt(tagId), userId);
  }

  @Get('users-with-tags')
  async getUsersWithTags(
    @Headers('x-user-id') userId: string,
  ): Promise<UsersWithTagsResponse> {
    if (!userId) {
      throw new Error('User ID required for admin operations');
    }
    return this.tagsService.getUsersWithTags(userId);
  }
}
