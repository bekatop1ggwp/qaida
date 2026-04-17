import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument, ObjectId } from 'mongoose';

import { ApiProperty } from '@nestjs/swagger';

export type VoteDocument = HydratedDocument<VoteDTO>;

@Schema()
export class VoteDTO {
  @ApiProperty()
  _id?: ObjectId;

  @ApiProperty({
    enum: ['POSITIVE', 'NEGATIVE'],
    default: 'POSITIVE',
  })
  @Prop({
    enum: ['POSITIVE', 'NEGATIVE'],
    default: 'POSITIVE',
  })
  type: 'POSITIVE' | 'NEGATIVE';

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  })
  user_id: ObjectId;
}

export const VoteSchema = SchemaFactory.createForClass(VoteDTO);
