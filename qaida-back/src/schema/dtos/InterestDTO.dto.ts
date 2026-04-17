import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';
export type Interest = HydratedDocument<InterestDTO>;

@Schema()
export class InterestDTO {
  @ApiProperty()
  _id?: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop({
    type: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category',
      },
    ],
  })
  category_id: mongoose.Schema.Types.ObjectId[];
}

export const InterestSchema = SchemaFactory.createForClass(InterestDTO);
