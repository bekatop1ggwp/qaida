import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';
export type LocationDocument = HydratedDocument<LocationDTO>;

@Schema()
export class LocationDTO {
  @ApiProperty()
  _id?: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop({
    required: true,
  })
  lat: number;

  @ApiProperty()
  @Prop({
    required: true,
  })
  lon: number;
}

export const LocationSchema = SchemaFactory.createForClass(LocationDTO);
