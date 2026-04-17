import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument, ObjectId } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';
export type AdminDocument = HydratedDocument<AdminDTO>;

@Schema()
export class AdminDTO {
  @ApiProperty()
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  })
  userId: ObjectId;
}

export const AdminSchema = SchemaFactory.createForClass(AdminDTO);
