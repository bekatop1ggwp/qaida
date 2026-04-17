import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument } from 'mongoose';
import { ApiProperty } from '@nestjs/swagger';
export type FileDocument = HydratedDocument<FileDTO>;

@Schema()
export class FileDTO {
  @ApiProperty()
  _id?: mongoose.Schema.Types.ObjectId;

  @ApiProperty()
  @Prop({
    required: true,
  })
  mimetype: string;

  @ApiProperty()
  @Prop({
    required: true,
    type: mongoose.Schema.Types.Buffer,
  })
  buffer: Buffer;

  @ApiProperty()
  @Prop({
    required: true,
  })
  size: number;
}

export const FileSchema = SchemaFactory.createForClass(FileDTO);
