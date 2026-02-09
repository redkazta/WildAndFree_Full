import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

interface Tag {
  tag_id: number;
  tag_name: string;
  color: string;
  animation: string;
}

interface ProcessedTag {
  id: number;
  name: string;
  color: string;
  animation: string;
  cssClass: string;
  isOwner: boolean;
}

@Injectable()
export class TagsService {
  constructor(private readonly httpService: HttpService) {}

  async getUserTags(userId: string) {
    try {
      const response = await firstValueFrom(
        this.httpService.get(`/users/${userId}/tags`)
      );
      
      // Procesar los tags para agregar clases CSS y lógica de negocio
      const tags = response.data.tags || [];
      const processedTags = tags.map((tag: Tag) => this.processTag(tag));
      
      // Si no hay tags, devolver un tag de fan por defecto
      if (processedTags.length === 0) {
        return {
          tags: [{
            id: 0,
            name: 'FAN',
            color: '#666666',
            animation: 'none',
            cssClass: 'role-fan',
            isOwner: false
          }]
        };
      }
      
      return { tags: processedTags };
    } catch (error) {
      console.error('Error fetching user tags:', error);
      // Devolver tag de fan por defecto en caso de error
      return {
        tags: [{
          id: 0,
          name: 'FAN',
          color: '#666666',
          animation: 'none',
          cssClass: 'role-fan',
          isOwner: false
        }]
      };
    }
  }

  async getAllTags() {
    try {
      const response = await firstValueFrom(
        this.httpService.get('/tags')
      );
      
      // Procesar todos los tags disponibles
      const tags = response.data || [];
      return { tags: tags.map((tag: any) => this.processTag(tag)) };
    } catch (error) {
      console.error('Error fetching all tags:', error);
      throw error;
    }
  }

  async assignTagToUser(userId: string, tagId: number) {
    try {
      const response = await firstValueFrom(
        this.httpService.post(`/users/${userId}/tags/${tagId}`)
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
        this.httpService.delete(`/users/${userId}/tags/${tagId}`)
      );
      return response.data;
    } catch (error) {
      console.error('Error removing tag from user:', error);
      throw error;
    }
  }

  async createTag(createTagDto: { name: string; color: string; animation: string }) {
    try {
      const response = await firstValueFrom(
        this.httpService.post('/tags', createTagDto)
      );
      return response.data;
    } catch (error) {
      console.error('Error creating tag:', error);
      throw error;
    }
  }

  async deleteTag(tagId: number) {
    try {
      const response = await firstValueFrom(
        this.httpService.delete(`/tags/${tagId}`)
      );
      return response.data;
    } catch (error) {
      console.error('Error deleting tag:', error);
      throw error;
    }
  }

  async getUsersWithTags() {
    try {
      // Este endpoint necesitaría ser implementado en el core-engine
      // Por ahora, devolver una lista vacía
      return { users: [] };
    } catch (error) {
      console.error('Error fetching users with tags:', error);
      throw error;
    }
  }

  private processTag(tag: Tag): ProcessedTag {
    const tagName = tag.tag_name.toLowerCase();
    let cssClass = 'role-fan';
    let isOwner = false;

    // Determinar la clase CSS basada en el nombre del tag
    if (tagName.includes('ceo') || tagName.includes('founder') || tagName.includes('owner') || 
        tagName.includes('director') || tagName.includes('executive') || tagName.includes('president')) {
      cssClass = 'role-owner';
      isOwner = true;
    } else if (tagName.includes('origins')) {
      cssClass = 'role-origins';
    } else if (tagName.includes('member')) {
      cssClass = 'role-member';
    } else if (tagName.includes('artist')) {
      cssClass = 'role-artist';
    } else if (tagName.includes('media')) {
      cssClass = 'role-media';
    } else if (tagName.includes('developer')) {
      cssClass = 'role-developer';
    } else if (tagName.includes('designer')) {
      cssClass = 'role-designer';
    } else if (tagName.includes('editor')) {
      cssClass = 'role-editor';
    } else if (tagName.includes('vip') || tagName.includes('premium') || tagName.includes('elite')) {
      cssClass = 'role-vip';
    }

    return {
      id: tag.tag_id,
      name: tag.tag_name.toUpperCase(),
      color: tag.color,
      animation: tag.animation,
      cssClass,
      isOwner
    };
  }
}