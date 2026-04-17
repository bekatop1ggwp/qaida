import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import mongoose, { HydratedDocument } from 'mongoose';
import { CategoryDTO } from './CategoryDTO.dto';

export type PlaceDocument = HydratedDocument<PlacesDTO>;

@Schema()
export class PlacesDTO {
  @ApiProperty()
  _id?: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop()
  title: string;

  @ApiProperty()
  @Prop()
  subtitle: string;

  @ApiPropertyOptional()
  @Prop()
  description?: string;

  @ApiProperty({
    type: [CategoryDTO],
  })
  @Prop({
    type: [{ ref: 'Category', type: mongoose.Schema.Types.ObjectId }],
  })
  category_id: mongoose.Schema.Types.ObjectId[];

  @ApiProperty()
  @Prop()
  address: string;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Location',
  })
  location_id: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop()
  url: string;

  @ApiPropertyOptional()
  @Prop()
  image?: string;

  @ApiPropertyOptional()
  @Prop()
  score?: number[];

  @ApiProperty()
  @Prop({
    min: 1,
    max: 5,
    type: mongoose.Schema.Types.Decimal128,
  })
  score_2gis: number;

  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Schedule',
  })
  schedule_id?: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop()
  neighborhood_name?: string;

  @ApiProperty()
  @Prop()
  neighborhood_id: string;

  @ApiProperty()
  @Prop()
  building_id: number;
}

export const PlaceSchema = SchemaFactory.createForClass(PlacesDTO);
