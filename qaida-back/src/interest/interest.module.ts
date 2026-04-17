import { Module } from '@nestjs/common';
import { InterestService } from './interest.service';
import { SchemaModule } from 'src/schema/schema.module';
import { InterestContoller } from './interest.controller';

@Module({
  imports: [SchemaModule],
  controllers: [InterestContoller],
  providers: [InterestService],
})
export class InterestModule {}
