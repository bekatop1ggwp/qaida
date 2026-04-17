import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, ObjectId } from 'mongoose';
import { LobbyDTO } from 'src/schema/dtos';

@Injectable()
export class LobbyService {
  constructor(@InjectModel('Lobby') private readonly lobby: Model<LobbyDTO>) {}

  private async findLobby(payload: any) {
    return await this.lobby.findOne(payload);
  }

  async createLobby(payload: LobbyDTO) {
    const existLobby = await this.findLobby({ title: payload.title });

    if (existLobby)
      throw new ConflictException('Уже существует лобби с таким названием');

    const lobby = await this.lobby.create(payload);

    return lobby;
  }

  /**
   * Добавить или выйти из лобби
   */
  async handleUser(user_id: ObjectId, lobby_id: ObjectId) {
    const isExist = await this.findLobby({
      _id: lobby_id,
      users: user_id,
    });
    const updateOperation = isExist
      ? { $pull: { users: user_id } }
      : { $addToSet: { users: user_id } };

    return await this.lobby.updateOne({ _id: lobby_id }, updateOperation);
  }

  async updateLobby(owner_id: ObjectId, payload: Omit<LobbyDTO, 'owner_id'>) {
    const lobby = await this.findLobby({
      owner_id,
      _id: payload._id,
    });
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { _id, ...data } = payload;
    if (lobby) return await this.lobby.updateOne({ _id: payload._id }, data);
    else throw new NotFoundException('Лобби не найдено');
  }

  async getLobbies(skip: number = 0, limit: number = 100) {
    const [lobbies, total] = await Promise.all([
      this.lobby.find().limit(limit).skip(skip),
      this.lobby.countDocuments(),
    ]);

    return { skip, limit, lobbies, total };
  }

  async deleteLobby(owner_id: ObjectId, lobby_id: ObjectId): Promise<any> {
    return await this.lobby.deleteOne({ owner_id, _id: lobby_id });
  }

  async getLobbyById(_id: ObjectId) {
    return await this.findLobby({ _id });
  }
}
