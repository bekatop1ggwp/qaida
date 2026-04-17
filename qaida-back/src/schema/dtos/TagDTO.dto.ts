import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, ObjectId } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';

export type TagDocument = HydratedDocument<TagDTO>;

@Schema()
export class TagDTO {
  @ApiProperty()
  _id: ObjectId;

  @ApiProperty()
  @Prop()
  name: string;

  @ApiProperty({
    enum: ['POSITIVE', 'NEGATIVE'],
  })
  @Prop({
    enum: ['POSITIVE', 'NEGATIVE'],
    default: 'POSITIVE',
  })
  type: 'POSITIVE' | 'NEGATIVE';
}

export const TagSchema = SchemaFactory.createForClass(TagDTO);
