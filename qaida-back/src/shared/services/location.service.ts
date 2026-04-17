import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { LocationDocument } from 'src/schema/dtos';

@Injectable()
export class LocationService {
  constructor(
    @InjectModel('Location') private readonly location: Model<LocationDocument>,
  ) {}

  public async addLocation(points: { lat: number; lon: number }) {
    return await this.location.create(points);
  }
}
