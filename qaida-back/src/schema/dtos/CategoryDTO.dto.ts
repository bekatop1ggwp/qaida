import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';

export type CategoryDocument = HydratedDocument<CategoryDTO>;

@Schema()
export class CategoryDTO {
  @ApiProperty()
  _id?: mongoose.Schema.Types.ObjectId;
  @Prop({
    required: true,
  })
  @ApiProperty()
  name: string;
}

export const CategorySchema = SchemaFactory.createForClass(CategoryDTO);
