import { Module } from '@nestjs/common';
import { InterestModule } from 'src/interest/interest.module';

@Module({
  imports: [InterestModule],
  exports: [InterestModule],
})
export class AdminModule {}
