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
    if (id.toString() === friend_id.toString()) {
      throw new MethodNotAllowedException('Нельзя добавить самого себя');
    }

    const friendExists = await this.user.exists({ _id: friend_id });

    if (!friendExists) {
      throw new NotFoundException('Пользователь не найден');
    }

    const currentUser = await this.user.findById(id).select('friends');

    if (!currentUser) {
      throw new NotFoundException('Пользователь не найден');
    }

    const alreadyFriend = (currentUser.friends ?? []).some(
      (friend) => friend.toString() === friend_id.toString(),
    );

    if (alreadyFriend) {
      throw new MethodNotAllowedException('Пользователь уже в друзьях');
    }

    await this.user.updateOne(
      { _id: id },
      {
        $addToSet: {
          friends: friend_id,
        },
      },
    );

    await this.user.updateOne(
      { _id: friend_id },
      {
        $addToSet: {
          friends: id,
        },
      },
    );

    return {
      success: true,
    };
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
    const uniquePayload = [...new Set(payload.map((id) => id.toString()))];

    const existCategoriesCount = await this.rubric.countDocuments({
      _id: { $in: uniquePayload },
    });

    if (existCategoriesCount !== uniquePayload.length) {
      throw new MethodNotAllowedException('Значения не допустимы');
    }

    const user = await this.user.exists({ _id: user_id });
    if (!user) throw new UnauthorizedException('Пользователь не найден');

    return await this.updateUserInDB(
      {
        interests: uniquePayload,
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

  public async getFriends(id: ObjectId) {
    const currentUser = await this.user
      .findById(id)
      .select('friends')
      .populate({
        path: 'friends',
        select: '_id name surname email image_id interests',
        populate: {
          path: 'interests',
          select: '_id name',
        },
      });

    if (!currentUser) throw new NotFoundException('Пользователь не найден');

    return currentUser.friends ?? [];
  }

  public async getFriendSuggestions(id: ObjectId) {
    const currentUser = await this.user.findById(id).select('interests friends');

    if (!currentUser) throw new NotFoundException('Пользователь не найден');

    const currentInterestIds = (currentUser.interests ?? []).map((interest) =>
      interest.toString(),
    );

    if (!currentInterestIds.length) return [];

    const friendIds = (currentUser.friends ?? []).map((friend) =>
      friend.toString(),
    );

    const excludedIds = [id.toString(), ...friendIds];

    const users = await this.user
      .find({
        _id: { $nin: excludedIds },
        interests: { $in: currentInterestIds },
        isDiactivated: { $ne: true },
      })
      .select('_id name surname email image_id interests')
      .populate({
        path: 'interests',
        select: '_id name',
      });

    return users
      .map((user) => {
        const userInterestIds = (user.interests ?? []).map((interest: any) =>
          interest._id ? interest._id.toString() : interest.toString(),
        );

        const matchingInterestsCount = userInterestIds.filter((interestId) =>
          currentInterestIds.includes(interestId),
        ).length;

        return {
          _id: user._id,
          name: user.name,
          surname: user.surname,
          email: user.email,
          image_id: user.image_id,
          interests: user.interests,
          matchingInterestsCount,
        };
      })
      .filter((user) => user.matchingInterestsCount > 0)
      .sort((a, b) => b.matchingInterestsCount - a.matchingInterestsCount);
  }
}