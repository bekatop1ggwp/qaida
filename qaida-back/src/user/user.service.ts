import {
  Injectable,
  Logger,
  MethodNotAllowedException,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { UserDTO } from 'src/schema/dtos/UserDTO.dto';

import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcryptjs';
import mongoose, { Model, ObjectId } from 'mongoose';
import { RubricsDocument } from 'src/schema/dtos';
import { FileDTO } from 'src/schema/dtos/FileDTO.dto';

@Injectable()
export class UserService {
  constructor(
    @InjectModel('User') private readonly user: Model<UserDTO>,
    @InjectModel('File') private readonly file: Model<FileDTO>,
    @InjectModel('Rubric') private readonly rubric: Model<RubricsDocument>,
  ) {}

  private logger = new Logger();
  /**
   *  Обновляет пользователя для того чтобы не писать один и тот же код несколько раз
   */
  private async updateUserInDB(data: any, id: ObjectId | string) {
    return await this.user.updateOne({ _id: id }, data);
  }

  public async uploadAvatar(file: FileDTO, _id: ObjectId) {
    const image = (await this.file
      .create(file)
      .catch((err) => this.logger.error(err))) as FileDTO;

    const user = await this.updateUserInDB({ image_id: image._id }, _id);

    const data = {
      ...user,
      image: `${process.env?.BACKEND_URL}/api/image/${image._id}`,
    };

    return data;
  }

  public async updateUser(body: UserDTO) {
    return await this.updateUserInDB(body, body._id);
  }

  public async updatePassword(prevPass: string, newPass: string, id: ObjectId) {
    const user = await this.user.findOne({ _id: id });
    if (!user) throw new NotFoundException('User not found!');
    if (!bcrypt.compareSync(prevPass, user.password))
      throw new MethodNotAllowedException('Password did not match');

    return await this.updateUserInDB(
      { password: bcrypt.hashSync(newPass, 7) },
      id,
    );
  }

  public async updateFavorites(user_id: string, place_ids: string[]) {
    try {
      return await this.updateUserInDB(
        {
          favorites: place_ids,
        },
        user_id,
      );
    } catch (error) {
      throw new UnauthorizedException(error);
    }
  }

  public async getme(_id: mongoose.Schema.Types.ObjectId) {
    try {
      const candidate = await this.user
        .findById(_id)
        .populate(['interests', 'favorites', 'friends']);
      return candidate;
    } catch (error) {
      throw new UnauthorizedException(error);
    }
  }

  public async addFriend(id: ObjectId, friend_id: ObjectId) {
    const currentUser = await this.updateUserInDB(
      {
        $push: {
          friends: friend_id,
        },
      },
      id,
    );
    const friend = await this.updateUserInDB(
      {
        $push: {
          friends: id,
        },
      },
      friend_id,
    );

    return { currentUser, friend };
  }

  public async removeFriend(id: ObjectId, friend_id: ObjectId) {
    const currentUser = await this.updateUserInDB(
      {
        $pull: {
          friends: friend_id,
        },
      },
      id,
    );
    const friend = await this.updateUserInDB(
      {
        $pull: {
          friends: id,
        },
      },
      friend_id,
    );

    return { currentUser, friend };
  }

  public async insertInterests(payload: ObjectId[], user_id: ObjectId) {
    const existCategories = await this.rubric.find({
      _id: {
        $in: payload,
      },
    });

    if (!existCategories)
      throw new MethodNotAllowedException('Значения не допустимы');

    const user = await this.user.findOne({ _id: user_id });
    if (!user) throw new UnauthorizedException('Пользователь не найден');

    return await this.updateUserInDB(
      {
        $addToSet: {
          interests: payload,
        },
      },
      user_id,
    );
  }

  public async deactivateUser(_id: ObjectId, method?: string) {
    const user = await this.user.findOne({ _id });

    if (user?.isDiactivated && method === 'DELETE') {
      throw new MethodNotAllowedException('Пользователь уже деактивирован');
    }

    return await this.user.updateOne(
      { _id },
      {
        isDiactivated: method === 'DELETE' ? true : false,
      },
    );
  }

  public async deleteUserAccount(_id: ObjectId) {
    return await this.user.deleteOne({ _id });
  }

  public async getUserDataForModel() {
    const userData = await this.user
      .find(
        {
          interests: {
            $ne: [],
          },
        },
        {
          password: 0,
          gender: 0,
          friends: 0,
          isDiactivated: 0,
          __v: 0,
        },
        {},
      )
      .populate([
        {
          path: 'interests',
          populate: {
            path: 'category_ids',
            model: 'Category',
            select: '_id name',
          },
        },
        {
          path: 'favorites',
          select: '_id title',
        },
      ]);
    return userData;
  }
}
