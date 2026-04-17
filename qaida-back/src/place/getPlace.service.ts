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
            $mergeObjects: [{ $arrayElemAt: ['$visited_place', 0] }, '$place'],
          },
        },
      },
    ]);
    return places;
  }
}
