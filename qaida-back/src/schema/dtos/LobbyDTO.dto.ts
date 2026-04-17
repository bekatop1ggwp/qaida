import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument, ObjectId } from 'mongoose';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
export type LobbyDocument = HydratedDocument<LobbyDTO>;

@Schema()
export class LobbyDTO {
  @ApiProperty()
  _id: ObjectId;

  @ApiProperty()
  @Prop()
  title: string;

  @Prop({
    type: Date,
    default: Date.now(),
  })
  created_at: Date;

  @ApiPropertyOptional()
  @Prop({
    ref: 'File',
    type: mongoose.Schema.Types.ObjectId,
  })
  image: ObjectId;

  @ApiPropertyOptional()
  @Prop()
  description: string;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  })
  owner_id: ObjectId;

  @ApiProperty()
  @Prop({
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  })
  users: ObjectId[];
}

export const LobbySchema = SchemaFactory.createForClass(LobbyDTO);
