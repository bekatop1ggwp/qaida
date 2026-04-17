import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument, ObjectId } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { CategoryDTO } from './CategoryDTO.dto';

export type RubricsDocument = HydratedDocument<RubricsDTO>;

@Schema()
export class RubricsDTO {
  @ApiProperty()
  _id?: ObjectId;
  @Prop()
  name: string;

  @ApiProperty({
    type: [CategoryDTO],
  })
  @Prop({
    type: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category',
      },
    ],
  })
  category_ids: ObjectId[];
}
export const RubricsSchema = SchemaFactory.createForClass(RubricsDTO);
