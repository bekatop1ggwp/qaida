import {
  Controller,
  UseGuards,
  Body,
  Post,
  Delete,
  Param,
} from '@nestjs/common';
import { AdminGuard } from 'src/shared/guards/admin.guard';

import { InterestService } from './interest.service';
import { ObjectId } from 'mongoose';
import { ApiTags } from '@nestjs/swagger';
@ApiTags('Interest')
@UseGuards(AdminGuard)
@Controller('admin/interest')
export class InterestContoller {
  constructor(private readonly interestService: InterestService) {}

  @Post('/')
  async addInterest(@Body('name') name: string) {
    return await this.interestService.addInterest(name);
  }

  @Delete('/:id')
  async removeInterest(@Param('id') id: ObjectId) {
    return await this.interestService.removeInterest(id);
  }
}
