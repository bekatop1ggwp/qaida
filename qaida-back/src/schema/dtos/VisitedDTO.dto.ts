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
    required: true,
    index: true,
  })
  user_id: ObjectId;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Place',
    required: true,
    index: true,
  })
  place_id: ObjectId;

  @Prop({
    type: Date,
    default: Date.now,
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

// Один пользователь -> одна запись на одно место
VisitedSchema.index({ user_id: 1, place_id: 1 }, { unique: true });