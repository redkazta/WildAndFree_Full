import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class TagsService {
  constructor(private readonly httpService: HttpService) {}

  async getUserTags(userId: string) {
    try {
      const response = await firstValueFrom(
        this.httpService.get(`/api/v1/users/${userId}/tags`)
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching user tags:', error);
      throw error;
    }
  }

  async getAllTags() {
    try {
      const response = await firstValueFrom(
        this.httpService.get('/api/v1/tags')
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching all tags:', error);
      throw error;
    }
  }

  async assignTagToUser(userId: string, tagId: number) {
    try {
      const response = await firstValueFrom(
        this.httpService.post(`/api/v1/users/${userId}/tags/${tagId}`, {}, {
          headers: { 'X-User-Id': userId }
        })
      );
      return response.data;
    } catch (error) {
      console.error('Error assigning tag to user:', error);
      throw error;
    }
  }

  async removeTagFromUser(userId: string, tagId: number) {
    try {
      const response = await firstValueFrom(
        this.httpService.delete(`/api/v1/users/${userId}/tags/${tagId}`, {
          headers: { 'X-User-Id': userId }
        })
      );
      return response.data;
    } catch (error) {
      console.error('Error removing tag from user:', error);
      throw error;
    }
  }

  async createTag(createTagDto: { name: string; color: string; animation: string }, userId: string) {
    try {
      const response = await firstValueFrom(
        this.httpService.post('/api/v1/tags', createTagDto, {
          headers: { 'X-User-Id': userId }
        })
      );
      return response.data;
    } catch (error) {
      console.error('Error creating tag:', error);
      throw error;
    }
  }

  async deleteTag(tagId: number, userId: string) {
    try {
      const response = await firstValueFrom(
        this.httpService.delete(`/api/v1/tags/${tagId}`, {
          headers: { 'X-User-Id': userId }
        })
      );
      return response.data;
    } catch (error) {
      console.error('Error deleting tag:', error);
      throw error;
    }
  }

  async getUsersWithTags(userId: string) {
    try {
      const response = await firstValueFrom(
        this.httpService.get('/api/v1/admin/users-with-tags', {
          headers: { 'X-User-Id': userId }
        })
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching users with tags:', error);
      throw error;
    }
  }
}