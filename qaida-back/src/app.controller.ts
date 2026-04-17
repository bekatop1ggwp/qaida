import {
  Controller,
  Get,
  Param,
  Post,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, ObjectId } from 'mongoose';
import { FileDTO } from './schema/dtos/FileDTO.dto';
import { Response } from 'express';
import { FileInterceptor } from '@nestjs/platform-express';
import { AuthGuard } from './shared/guards/auth.guard';
@Controller()
export class AppController {
  constructor(@InjectModel('File') private readonly file: Model<FileDTO>) {}

  @Get('/image/:id')
  async getImage(@Param('id') id: ObjectId, @Res() res: Response) {
    const image = await this.file.findById(id);

    res.set({
      'Content-Type': image.mimetype,
      'Content-Length': image.size,
    });
    res.send(image.buffer);
  }

  @Post('/image/upload')
  @UseGuards(AuthGuard)
  @UseInterceptors(FileInterceptor('image'))
  async uploadImage(@UploadedFile() image: Express.Multer.File) {
    const file: FileDTO = {
      buffer: Buffer.from(image.buffer),
      size: image.size,
      mimetype: image.mimetype,
    };

    return await this.file.create(file);
  }
}
