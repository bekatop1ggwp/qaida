import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';

export type ScheduleDocument = HydratedDocument<ScheduleDTO>;

@Schema()
export class ScheduleDTO {
  @ApiProperty()
  _id: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop({
    type: [
      {
        from: {
          type: String,
        },
        to: { type: String },
        day: { type: String },
      },
    ],
  })
  schedule: {
    from: string;
    to: string;
    day: string;
  }[];
}

export const ScheduleSchema = SchemaFactory.createForClass(ScheduleDTO);
