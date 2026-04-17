import { Module } from '@nestjs/common';
import { GeolocationGateway } from './geolocation.gateway';
import { GeolocationService } from './geolocation.service';
import { SchemaModule } from 'src/schema/schema.module';

@Module({
  imports: [SchemaModule],
  providers: [GeolocationService, GeolocationGateway],
})
export class GeolocationModule {}
