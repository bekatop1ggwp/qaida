import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import mongoose, { HydratedDocument, ObjectId } from 'mongoose';

export type ReviewDocument = HydratedDocument<ReviewDTO>;

@Schema()
export class ReviewDTO {
  @ApiProperty()
  _id?: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Place',
  })
  place_id: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  })
  user_id: mongoose.Schema.Types.ObjectId;

  @Prop({
    type: Date,
    default: new Date(),
  })
  created_at: Date;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.Decimal128,
    max: 5,
    min: 1,
    default: 5,
  })
  score: number;

  @ApiPropertyOptional()
  @Prop()
  comment: string;

  @ApiPropertyOptional()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'File',
  })
  image?: ObjectId;

  @ApiProperty()
  @Prop({
    type: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Vote',
      },
    ],
  })
  votes?: ObjectId[];
}

export const ReviewSchema = SchemaFactory.createForClass(ReviewDTO);
