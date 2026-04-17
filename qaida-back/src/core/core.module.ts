import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AdminModule } from '../admin/admin.module';

@Module({
  imports: [
    JwtModule.register({
      global: true,
    }),

    AdminModule,
  ],
  exports: [ JwtModule],
})
export class CoreModule {}
