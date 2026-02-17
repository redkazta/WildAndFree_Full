import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import type { Artist } from 'shared-types';

@Injectable()
export class InitService {
  constructor(private readonly http: HttpService) {}

  async getArtists(): Promise<Artist[]> {
    const response = await lastValueFrom(
      this.http.get<Artist[]>('http://localhost:8080/api/v1/artists'),
    );

    return response.data;
  }
}
