import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Socket } from 'socket.io';
import {
  LocationDocument,
  PlaceDocument,
  VisitedDocument,
} from 'src/schema/dtos';
import { IGeoLocation } from './types';

@Injectable()
export class GeolocationService {
  private connectedClients: Set<string> = new Set();
  private clientLocations: Map<
    string,
    { location: IGeoLocation; user_id: string }
  > = new Map();

  constructor(
    @InjectModel('Location') private readonly location: Model<LocationDocument>,
    @InjectModel('Place') private readonly place: Model<PlaceDocument>,
    @InjectModel('Visited') private readonly visit: Model<VisitedDocument>,
  ) {}

  private logger = new Logger();

  handleConnection(socket: Socket): void {
    const clientId = socket.id;
    this.logger.log('Client Connected', clientId);
    this.connectedClients.add(clientId);

    console.log(this.connectedClients);

    socket.on('disconnect', () => {
      this.connectedClients.delete(clientId);
      this.clientLocations.delete(clientId);
      this.logger.log('disconnected client', clientId);

      console.log({
        connectedClients: this.connectedClients,
        locations: this.clientLocations,
      });
    });
  }

  async handleGeolocation(
    clientId: string,
    user_id: string,
    location: IGeoLocation,
  ) {
    this.clientLocations.set(clientId, { location, user_id });

    const locations = await this.location.aggregate([
      {
        $addFields: {
          distance: {
            $sqrt: {
              $add: [
                { $pow: [{ $subtract: ['$lat', location.lat] }, 2] },
                { $pow: [{ $subtract: ['$lon', location.lon] }, 2] },
              ],
            },
          },
        },
      },
      {
        $match: {
          distance: { $lte: 0.0004382872 },
        },
      },
    ]);

    this.logger.debug('location id', locations);

    if (locations) {
      const places = await this.place.find(
        {
          location_id: {
            $in: locations.map((e) => e._id),
          },
        },
        { _id: 1 },
      );

      if (places) {
        const objectToCreate = places.map((place) => ({
          place_id: place._id,
          user_id,
        }));
        this.logger.debug('PLACE', objectToCreate);
        const visited = await this.visit.create(objectToCreate);

        return visited;
      }
    }
  }
}
