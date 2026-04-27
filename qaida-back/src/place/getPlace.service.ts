import {
  Injectable,
  Logger,
  NotAcceptableException,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, ObjectId, isObjectIdOrHexString } from 'mongoose';
import {
  PlaceDocument,
  ReviewDocument,
  RubricsDocument,
  VisitedDocument,
} from 'src/schema/dtos';
import { IParams } from './types';

@Injectable()
export class GetPlacesService {
  private logger = new Logger();
  constructor(
    @InjectModel('Place') private readonly place: Model<PlaceDocument>,
    @InjectModel('Rubric') private readonly rubric: Model<RubricsDocument>,
    @InjectModel('Visited') private readonly visit: Model<VisitedDocument>,
    @InjectModel('Review') private readonly review: Model<ReviewDocument>,
  ) {}

  async getPlace(categoryId?: string, rubricId?: string) {
    let query = {};

    if (categoryId) {
      query = {
        category_id: {
          $in: [categoryId],
        },
      };
    } else if (rubricId) {
      const categoryIds = await this.rubric.findOne(
        { _id: rubricId },
        { category_ids: 1 },
      );
      this.logger.debug(
        'Debug categories',
        JSON.stringify(categoryIds, null, 2),
      );
      query = {
        category_id: {
          $in: categoryIds?.category_ids,
        },
      };
    }

    return await this.place.find(query).populate('category_id');
  }

  public async getPlaceById(_id: ObjectId) {
    if (!isObjectIdOrHexString(_id))
      throw new NotAcceptableException(
        'Предоставленный ID не является корректным',
      );
    const place = await this.place
      .findById(_id)
      .populate(['schedule_id', 'location_id']);
    if (!place) throw new NotFoundException('Место не найдено');
    return place;
  }

  public async getPlaceDetails(_id: ObjectId): Promise<any> {
    if (!isObjectIdOrHexString(_id)) {
      throw new NotAcceptableException(
        'Предоставленный ID не является корректным',
      );
    }

    const place = await this.place
      .findById(_id)
      .populate(['schedule_id', 'location_id', 'category_id'])
      .lean();

    if (!place) {
      throw new NotFoundException('Место не найдено');
    }

    const categoryIds = Array.isArray(place.category_id)
      ? place.category_id
          .map((category: any) => category?._id ?? category)
          .filter(Boolean)
      : [];

    const [reviews, interestingPlaceCandidates] = await Promise.all([
      this.review
        .find({ place_id: _id })
        .sort({ created_at: -1 })
        .populate({
          path: 'user_id',
          select: 'name surname email image_id',
        })
        .populate({
          path: 'votes',
          select: 'type user_id',
        })
        .lean(),

      categoryIds.length
        ? this.place
            .find({
              _id: { $ne: place._id },
              category_id: { $in: categoryIds },
            })
            .sort({
              score_2gis: -1,
              title: 1,
            })
            .limit(20)
            .populate('category_id')
            .lean()
        : [],
    ]);

    const seenInterestingPlaceKeys = new Set<string>();
    const interestingPlaces = [];

    for (const item of interestingPlaceCandidates as any[]) {
      const title = item?.title?.toString().trim().toLowerCase() ?? '';
      const address = item?.address?.toString().trim().toLowerCase() ?? '';

      const uniqueKey = `${title}|${address}`;

      if (!title || seenInterestingPlaceKeys.has(uniqueKey)) {
        continue;
      }

      seenInterestingPlaceKeys.add(uniqueKey);
      interestingPlaces.push(item);

      if (interestingPlaces.length >= 5) {
        break;
      }
    }

    const reviewCount = reviews.length;

    const averageRating =
      reviewCount === 0
        ? 0
        : Number(
            (
              reviews.reduce((sum: number, review: any) => {
                const score = review?.score;
                const normalizedScore =
                  score?.toString instanceof Function
                    ? Number(score.toString())
                    : Number(score ?? 0);

                return sum + normalizedScore;
              }, 0) / reviewCount
            ).toFixed(1),
          );

    return {
      place,
      reviewsPreview: reviews.slice(0, 1),
      reviews,
      reviewCount,
      averageRating,
      interestingPlaces,
    };
  }

  async findByParams(params: IParams) {
    const { limit, page, score2gis, ...q } = params;

    const range = limit ? limit : 10;
    const skip = page ? (page - 1) * range : 0;

    const query = {
      ...q,
    };

    if (q.address) {
      query['address'] = {
        $regex: q.address,
      } as { $regex: string };
    }

    if (q.title) {
      query['title'] = {
        $regex: q.title,
      } as { $regex: string };
    }

    if (score2gis) {
      query['score_2gis'] = { $gte: String(score2gis) };
    }

    this.logger.debug('Query', JSON.stringify(query));

    const places = await this.place.find(query).limit(range).skip(skip);

    const totalCount = await this.place.countDocuments(query);

    const totalPages = Math.ceil(totalCount / range);

    return {
      page: page ? Number(page) : 1,
      totalCount,
      totalPages,
      limit: Number(range),
      places,
    };
  }

  async findByUser(
    user_id: ObjectId,
    status?: 'VISITED' | 'PROCESSING' | 'SKIP',
    date?: number,
  ) {
    const query = {
      user_id,
    };

    if (status) {
      query['status'] = status;
    }
    if (date && !isNaN(Number(date))) {
      query['visited_time'] = new Date(Number(date));
    } else if (date) {
      throw new NotAcceptableException('Не правильный тип даты отправлен');
    }

    return await this.visit.find(query).populate(['place_id', 'user_id']);
  }

  async clearVisitedHistory(user_id: ObjectId): Promise<{ deletedCount: number }> {
    const result = await this.visit.deleteMany({
      user_id,
      status: 'VISITED',
    });

    return {
      deletedCount: result.deletedCount ?? 0,
    };
  }

  async changeStatus(
    visit_id: ObjectId,
    status: 'VISITED' | 'PROCESSING' | 'SKIP',
  ) {
    const visited = await this.visit.findOneAndUpdate(
      { _id: visit_id },
      {
        status,
      },
      {
        new: true,
      },
    );

    return visited;
  }

  async getTopThreePopular() {
    const places = await this.visit.aggregate([
      {
        $match: {
          status: 'VISITED',
        },
      },
      {
        $group: {
          _id: '$place_id',
          count: { $sum: 1 },
          place: { $first: '$$ROOT' },
          average_score: { $avg: { $ifNull: ['$score', []] } }, // Calculate the average score
        },
      },
      {
        $sort: { count: -1 },
      },
      {
        $limit: 3,
      },
      {
        $lookup: {
          from: 'places',
          localField: '_id',
          foreignField: '_id',
          as: 'visited_place',
        },
      },
      {
        $replaceRoot: {
          newRoot: {
            $mergeObjects: ['$place', { $arrayElemAt: ['$visited_place', 0] }],
          },
        },
      },
    ]);
    return places;
  }

  async createDemoProcessingVisits(user_id: ObjectId, count: number = 5) {
    const safeCount = Math.max(1, Math.min(count || 5, 20));

    const existingVisits = await this.visit.find(
      { user_id },
      { place_id: 1 },
    );

    const blockedPlaceIds = existingVisits.map((visit) => visit.place_id);

    const candidatePlaces = await this.place.aggregate([
      {
        $match: {
          _id: { $nin: blockedPlaceIds },
        },
      },
      {
        $sample: { size: safeCount },
      },
      {
        $project: { _id: 1 },
      },
    ]);

    if (!candidatePlaces.length) {
      return [];
    }

    const docsToCreate = candidatePlaces.map((place) => ({
      user_id,
      place_id: place._id,
      status: 'PROCESSING',
      visited_time: new Date(),
    }));

    return await this.visit.insertMany(docsToCreate, { ordered: false });
  }
}
