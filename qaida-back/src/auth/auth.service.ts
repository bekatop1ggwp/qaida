import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcryptjs';
import mongoose, { Model } from 'mongoose';
import { UserDTO } from 'src/schema/dtos/UserDTO.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwt: JwtService,
    @InjectModel('User') private readonly user: Model<UserDTO>,
  ) {}

  private logger = new Logger();

  private async generateToken(
    secret: string,
    expiresIn: string,
    id: mongoose.Schema.Types.ObjectId,
  ) {
    return await this.jwt.signAsync(
      { id },
      {
        secret,
        expiresIn,
      },
    );
  }

  private async getUser(payload: UserDTO) {
    return await this.user.findOne(payload);
  }

  public async createUser(payload: UserDTO) {
    try {
      const candidate = await this.getUser({ email: payload.email });

      if (candidate) throw new ConflictException('User already exists');

      return await this.user.create({
        ...payload,
        password: bcrypt.hashSync(payload.password, 7),
      });
    } catch (error) {
      this.logger.error('ERROR', JSON.stringify(error, null, 2));
      throw new BadRequestException(error);
    }
  }

  public async authorize(payload: UserDTO) {
    const candidate = await this.getUser({ email: payload.email });

    if (!candidate)
      throw new UnauthorizedException('Пользователь не существует');

    if (!bcrypt.compareSync(payload.password, candidate.password))
      throw new UnauthorizedException('Пароль не сходиться');

    return {
      access_token: await this.generateToken(
        process.env?.ACCESS_TOKEN as string,
        '6h',
        candidate._id,
      ),
      refresh_token: await this.generateToken(
        process.env?.REFRESH_TOKEN as string,
        '3d',
        candidate._id,
      ),
    };
  }

  public async getme(_id: mongoose.Schema.Types.ObjectId) {
    try {
      const candidate = await this.getUser({ _id });
      return candidate;
    } catch (error) {
      throw new UnauthorizedException(error);
    }
  }

  public async refresh(token: string) {
    try {
      const { id: _id } = await this.jwt.verifyAsync(token, {
        secret: process.env?.REFRESH_TOKEN,
      });

      const user = await this.getUser({ _id });

      if (!user) throw new Error('User not found');

      return {
        access_token: await this.generateToken(
          process.env?.ACCESS_TOKEN,
          '3d',
          _id,
        ),
      };
    } catch (error) {
      this.logger.error('ERROR', JSON.stringify(error, null, 2));
      throw new UnauthorizedException(error);
    }
  }
}
