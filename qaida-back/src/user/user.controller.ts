import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Put,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UserService } from './user.service';

import { ApiHeader, ApiParam, ApiTags, getSchemaPath } from '@nestjs/swagger';
import { Request } from 'express';
import { ObjectId } from 'mongoose';
import { FileDTO } from 'src/schema/dtos/FileDTO.dto';
import { UserDTO } from 'src/schema/dtos/UserDTO.dto';
import { AuthGuard } from 'src/shared/guards/auth.guard';

import { ApiBody, ApiResponse } from '@nestjs/swagger';
import { Password } from './password.dto';
import { Favorites } from './types';

@ApiTags('User')
@UseGuards(AuthGuard)
@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Delete('/')
  async deleteUserAccount(@Req() req: Request): Promise<any> {
    return await this.userService.deleteUserAccount(req['user'].id);
  }

  @Get('/me')
  @ApiResponse({
    status: 200,
    schema: {
      $ref: getSchemaPath(UserDTO),
    },
  })
  async getMe(@Req() req: Request) {
    return await this.userService.getme(req['user'].id);
  }

  @Get('/get-user-data')
  async getUserData() {
    return await this.userService.getUserDataForModel();
  }
  @Patch('/update')
  @ApiBody({
    schema: {
      $ref: getSchemaPath(UserDTO),
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Обновление пользователя, без пароля',
  })
  async updateUser(@Req() req: Request, @Body() body: Omit<UserDTO, '_id'>) {
    const data = {
      _id: req['user'].id,
      ...body,
    };
    return await this.userService.updateUser(data);
  }

  @Put('/favorites')
  @ApiBody({
    type: Favorites,
    description:
      'При добавлении или удалении отправлять просто массив с состояния',
  })
  async favorites(@Body() { place_ids }: Favorites, @Req() req: Request) {
    return this.userService.updateFavorites(req['user'].id, place_ids);
  }

  @Put('/interest')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        interests: {
          type: 'array',
          items: {
            type: 'string',
          },
        },
      },
    },
  })
  async insertInterests(
    @Req() req: Request,
    @Body() body: { interests: ObjectId[] },
  ) {
    return await this.userService.insertInterests(
      body.interests,
      req['user'].id,
    );
  }

  @Patch('/update/password')
  @ApiBody({
    type: Password,
  })
  @ApiResponse({
    status: 200,
    description: 'Обновление пароля',
  })
  async updatePassword(
    @Req() req: Request,
    @Body() body: { current: string; newPass: string },
  ) {
    return await this.userService.updatePassword(
      body.current,
      body.newPass,
      req['user'].id,
    );
  }

  @Patch('/avatar')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: {
          type: 'binary',
          format: 'binary',
        },
      },
    },
  })
  @ApiHeader({
    name: 'application/x-www-form-urlencoded',
    description: 'Файл',
  })
  @UseInterceptors(FileInterceptor('image'))
  async uploadAvatar(
    @UploadedFile() image: Express.Multer.File,
    @Req() req: Request,
  ) {
    const file: FileDTO = {
      buffer: Buffer.from(image.buffer),
      size: image.size,
      mimetype: image.mimetype,
    };
    // console.log(util.inspect(file, { depth: null }));

    return await this.userService.uploadAvatar(file, req['user'].id);
  }

  @Put('/activate')
  async activate(@Req() req: Request) {
    return await this.userService.deactivateUser(req['user'].id, req.method);
  }

  @Delete('/deactivate')
  async handleDeactivate(@Req() req: Request) {
    return await this.userService.deactivateUser(req['user'].id, req.method);
  }

  @ApiParam({
    type: 'string',
    name: 'friend_id',
  })
  @Put('/add/:friend_id')
  async addFriend(
    @Req() req: Request,
    @Param('friend_id') friend_id: ObjectId,
  ) {
    return await this.userService.addFriend(req['user'].id, friend_id);
  }

  @ApiParam({
    type: 'string',
    name: 'friend_id',
  })
  @Delete('/delete/:friend_id')
  async removeFriend(
    @Req() req: Request,
    @Param('friend_id') friend_id: ObjectId,
  ) {
    return await this.userService.removeFriend(req['user'].id, friend_id);
  }
}
