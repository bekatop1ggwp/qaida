import { ApiProperty } from '@nestjs/swagger';

export class Password {
  @ApiProperty({
    type: 'string',
  })
  current: string;

  @ApiProperty({
    type: 'string',
  })
  newPass: string;
}
