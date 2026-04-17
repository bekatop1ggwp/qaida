import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument, ObjectId } from 'mongoose';

import { ApiProperty } from '@nestjs/swagger';

export type VisitedDocument = HydratedDocument<VisitedDTO>;

@Schema()
export class VisitedDTO {
  @ApiProperty()
  _id?: ObjectId;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  })
  user_id: ObjectId;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Place',
  })
  place_id: ObjectId;

  @Prop({
    type: Date,
    default: new Date(),
  })
  visited_time: Date;

  @ApiProperty({
    enum: ['VISITED', 'PROCESSING', 'SKIP'],
    default: 'PROCESSING',
  })
  @Prop({
    enum: ['VISITED', 'PROCESSING', 'SKIP'],
    default: 'PROCESSING',
  })
  status: 'VISITED' | 'PROCESSING' | 'SKIP';
}

export const VisitedSchema = SchemaFactory.createForClass(VisitedDTO);
