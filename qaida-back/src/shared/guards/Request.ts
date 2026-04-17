import { UserDTO } from 'src/schema/dtos/UserDTO.dto';
import { Request } from 'express';
import { JwtService } from '@nestjs/jwt';
import { Model, ObjectId } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { AdminDTO } from 'src/schema/dtos';

export class CustomRequest {
  private jwt = new JwtService();

  constructor(
    @InjectModel('User') private user: Model<UserDTO>,
    @InjectModel('Admin') private admin: Model<AdminDTO>,
  ) {}

  public extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }

  public async extractUserFromToken(token: string) {
    const { id } = await this.jwt.verifyAsync(token, {
      secret: process.env?.ACCESS_TOKEN,
    });

    return await this.user.findOne({ _id: id }, { _id: 1 });
  }

  public async checkAdmin(id: ObjectId) {
    return !!(await this.admin.findById(id));
  }
}
