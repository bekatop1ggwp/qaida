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

  private logger = new Logger(GeolocationService.name);

  handleConnection(socket: Socket): void {
    const clientId = socket.id;
    this.logger.log(`Client connected: ${clientId}`);
    this.connectedClients.add(clientId);

    socket.on('disconnect', () => {
      this.connectedClients.delete(clientId);
      this.clientLocations.delete(clientId);
      this.logger.log(`Client disconnected: ${clientId}`);
    });
  }

  async handleGeolocation(
    clientId: string,
    user_id: string,
    location: IGeoLocation,
  ) {
    this.clientLocations.set(clientId, { location, user_id });

    const nearbyLocations = await this.location.aggregate([
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
      {
        $project: { _id: 1 },
      },
    ]);

    if (!nearbyLocations.length) return [];

    const locationIds = nearbyLocations.map((item) => item._id);

    const places = await this.place.find(
      { location_id: { $in: locationIds } },
      { _id: 1 },
    );

    if (!places.length) return [];

    const uniquePlaces = Array.from(
      new Map(places.map((place) => [String(place._id), place])).values(),
    );

    const placeIds = uniquePlaces.map((place) => place._id);

    const existingVisits = await this.visit.find(
      {
        user_id,
        place_id: { $in: placeIds },
      },
      { place_id: 1 },
    );

    const blockedPlaceIds = new Set(
      existingVisits.map((visit) => String(visit.place_id)),
    );

    const visitsToCreate = uniquePlaces
      .filter((place) => !blockedPlaceIds.has(String(place._id)))
      .map((place) => ({
        place_id: place._id,
        user_id,
      }));

    if (!visitsToCreate.length) return [];

    try {
      const createdVisits = await this.visit.insertMany(visitsToCreate, {
        ordered: false,
      });

      this.logger.debug(
        `Created ${createdVisits.length} processing visit(s) for user ${user_id}`,
      );

      return createdVisits;
    } catch (error: any) {
      if (error?.code === 11000 || error?.writeErrors?.length) {
        this.logger.warn(
          `Duplicate visit prevented by unique index for user ${user_id}`,
        );
        return [];
      }

      throw error;
    }
  }
}