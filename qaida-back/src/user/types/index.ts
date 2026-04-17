import { ApiProperty } from '@nestjs/swagger';

export class Favorites {
  @ApiProperty()
  place_ids: string[];
}
