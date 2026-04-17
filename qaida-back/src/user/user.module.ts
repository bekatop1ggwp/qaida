import { Module } from '@nestjs/common';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { SchemaModule } from 'src/schema/schema.module';

@Module({
  imports: [SchemaModule],
  controllers: [UserController],
  providers: [UserService],
})
export class UserModule {}
