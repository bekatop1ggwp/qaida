import { Controller, Get, Post, Put, Query } from '@nestjs/common';
import { CategoriesService } from './categories.service';

import { ApiResponse, ApiTags } from '@nestjs/swagger';
import { RubricsDTO } from 'src/schema/dtos';

@ApiTags('Category')
@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoryService: CategoriesService) {}

  @Get('/')
  @ApiResponse({
    status: 200,
    type: RubricsDTO,
    description: 'Не зависит от регистра, можно писать сабстринги',
  })
  async getGategories(@Query('q') q: string) {
    return await this.categoryService.getAllCategories(q);
  }

  @Post('/2gis/load')
  async loadCategories() {
    return await this.categoryService.loadCategories();
  }

  @Put('/2gis/file')
  async loadFromFile() {
    return this.categoryService.loadFromFile();
  }
}
