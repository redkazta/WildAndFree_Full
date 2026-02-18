import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import type {
  CreateTagRequest,
  StatusResponse,
  Tag,
  TagsListResponse,
  UserTagsResponse,
  UsersWithTagsResponse,
} from 'shared-types';

@Injectable()
export class TagsService {
  constructor(private readonly httpService: HttpService) {}

  async getUserTags(userId: string): Promise<UserTagsResponse> {
    try {
      const response = await firstValueFrom(
        this.httpService.get<UserTagsResponse>(`/users/${userId}/tags`),
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching user tags:', error);
      throw error;
    }
  }

  async getAllTags(): Promise<TagsListResponse> {
    try {
      const response = await firstValueFrom(
        this.httpService.get<TagsListResponse>('/tags'),
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching all tags:', error);
      throw error;
    }
  }

  async assignTagToUser(
    userId: string,
    tagId: number,
  ): Promise<StatusResponse> {
    try {
      const response = await firstValueFrom(
        this.httpService.post<StatusResponse>(
          `/users/${userId}/tags/${tagId}`,
          {},
          {
            headers: { 'X-User-Id': userId },
          },
        ),
      );
      return response.data;
    } catch (error) {
      console.error('Error assigning tag to user:', error);
      throw error;
    }
  }

  async removeTagFromUser(
    userId: string,
    tagId: number,
  ): Promise<StatusResponse> {
    try {
      const response = await firstValueFrom(
        this.httpService.delete<StatusResponse>(
          `/users/${userId}/tags/${tagId}`,
          {
            headers: { 'X-User-Id': userId },
          },
        ),
      );
      return response.data;
    } catch (error) {
      console.error('Error removing tag from user:', error);
      throw error;
    }
  }

  async createTag(
    createTagDto: CreateTagRequest,
    userId: string,
  ): Promise<Tag> {
    try {
      const response = await firstValueFrom(
        this.httpService.post<Tag>('/tags', createTagDto, {
          headers: { 'X-User-Id': userId },
        }),
      );
      return response.data;
    } catch (error) {
      console.error('Error creating tag:', error);
      throw error;
    }
  }

  async deleteTag(tagId: number, userId: string): Promise<StatusResponse> {
    try {
      const response = await firstValueFrom(
        this.httpService.delete<StatusResponse>(`/tags/${tagId}`, {
          headers: { 'X-User-Id': userId },
        }),
      );
      return response.data;
    } catch (error) {
      console.error('Error deleting tag:', error);
      throw error;
    }
  }

  async getUsersWithTags(userId: string): Promise<UsersWithTagsResponse> {
    try {
      const response = await firstValueFrom(
        this.httpService.get<UsersWithTagsResponse>('/admin/users-with-tags', {
          headers: { 'X-User-Id': userId },
        }),
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching users with tags:', error);
      throw error;
    }
  }
}
