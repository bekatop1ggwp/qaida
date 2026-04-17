import { Module } from '@nestjs/common';
import { GetPlacesService } from 'src/place/getPlace.service';
import { SchemaModule } from 'src/schema/schema.module';
import { LocationService } from 'src/shared/services/location.service';
import { PlaceController } from './place.controller';
import { PlaceService } from './place.service';
import { PlaceReviewService } from './placeReview.service';
import { ReviewController } from './review.controller';
@Module({
  imports: [SchemaModule],
  providers: [
    PlaceService,
    LocationService,
    GetPlacesService,
    PlaceReviewService,
  ],
  controllers: [PlaceController, ReviewController],
})
export class PlaceModule {}
