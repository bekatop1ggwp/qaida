import { Module } from '@nestjs/common';
import { GeolocationModule } from 'src/geolocation/geolocation.module';

@Module({
  imports: [GeolocationModule],
  exports: [GeolocationModule],
})
export class WebsocketModule {}
