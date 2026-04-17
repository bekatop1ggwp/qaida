import { Module } from '@nestjs/common';
import { LobbyService } from './lobby.service';
import { LobbyController } from './lobby.controller';

import { SchemaModule } from 'src/schema/schema.module';

@Module({
  imports: [SchemaModule],
  providers: [LobbyService],
  controllers: [LobbyController],
})
export class LobbyModule {}
