import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument, ObjectId } from 'mongoose';

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export type User = HydratedDocument<UserDTO>;
@Schema()
export class UserDTO {
  @ApiProperty()
  _id?: ObjectId;

  @ApiProperty()
  @Prop({
    default: false,
    type: Boolean,
  })
  isDiactivated?: boolean;

  @ApiProperty()
  @Prop()
  name?: string;

  @ApiProperty()
  @Prop()
  surname?: string;

  @ApiPropertyOptional()
  @Prop()
  father_name?: string;

  @ApiProperty()
  @Prop({
    required: true,
  })
  password?: string;

  @ApiProperty()
  @Prop({
    required: true,
  })
  email?: string;

  @ApiPropertyOptional()
  @Prop()
  messenger_one?: string;

  @ApiPropertyOptional()
  @Prop()
  messenger_two?: string;

  @ApiProperty({
    enum: ['MALE', 'FEMALE', 'BINARY'],
    default: 'BINARY',
  })
  @Prop({
    enum: ['MALE', 'FEMALE', 'BINARY'],
    default: 'BINARY',
  })
  gender?: 'MALE' | 'FEMALE' | 'BINARY';

  @Prop({
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  })
  friends?: ObjectId[];

  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'File',
  })
  image_id?: ObjectId;

  @Prop({
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Rubric' }],
  })
  interests?: ObjectId[];

  @Prop({
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Place' }],
    default: [],
  })
  favorites?: ObjectId[];
}

export const UserSchema = SchemaFactory.createForClass(UserDTO);
