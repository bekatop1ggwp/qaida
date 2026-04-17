import { getPlacesByCategoryId } from './../shared/utils/integrationService';
import {
  Injectable,
  Logger,
  MethodNotAllowedException,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, ObjectId } from 'mongoose';
import {
  CategoryDocument,
  LocationDocument,
  PlaceDocument,
  PlacesDTO,
  ScheduleDocument,
} from 'src/schema/dtos';
import { LocationService } from 'src/shared/services/location.service';
import {
  getIdFromName,
  getResponseById,
} from 'src/shared/utils/integrationService';
@Injectable()
export class PlaceService {
  constructor(
    @InjectModel('Place') private readonly place: Model<PlaceDocument>,
    @InjectModel('Location') private readonly location: Model<LocationDocument>,
    @InjectModel('Category') private readonly category: Model<CategoryDocument>,
    @InjectModel('Schedule') private readonly schedule: Model<ScheduleDocument>,
    private readonly locationService: LocationService,
  ) {}

  private logger = new Logger();

  private async isPlaceExist(name: string) {
    const place = await this.place.findOne({
      title: {
        $regex: name,
        $options: 'i',
      },
    });
    this.logger.debug('Существует? ', place ? 'Да' : 'Нет');
    return place;
  }

  async addPlace(name: string, isPulling: boolean = false, item?: any) {
    let response: any, id: any;
    if (!isPulling) {
      const isExists = await this.isPlaceExist(name);
      if (isExists) {
        throw new MethodNotAllowedException('Место уже существует');
      }
      id = await getIdFromName(name, process.env?.API_KEY);
      if (!id)
        throw new NotFoundException(
          'Место не найдено, введите точное совпадение',
        );
      response = await getResponseById(id, process.env?.API_KEY);
    } else {
      response = item;
    }

    const categories = response.rubrics.map((r) => ({
      name: r.name,
    }));
    const image = response.external_content?.find(
      (content) => content.type === 'photo_album',
    )?.main_photo_url;

    const neighborhood = response.links?.nearest_stations?.[0];
    const score_2gis = response.reviews.general_rating;

    const scheduleArray = this.formSchedule(response.schedule);

    const schedules =
      scheduleArray.length > 0
        ? await this.schedule.create({ schedule: scheduleArray })
        : null;

    // const locationData = await this.location.create(location);

    const locationData = await this.locationService.addLocation(response.point);

    const categoriesData = await this.createOrGetExistCategory(categories);
    // this.logger.debug('Категории ид', categoriesData);
    const data: PlacesDTO = {
      address: response.address_name as string,
      title: response.name as string,
      score_2gis: Number(score_2gis),
      image: image ? image : null,
      subtitle: response.full_name as string,
      url: `https://2gis.kz/astana/firm/${id}`,
      building_id: response.id,
      location_id: locationData._id,
      category_id: categoriesData,
      neighborhood_name: neighborhood ? neighborhood.name : null,
      neighborhood_id: neighborhood ? neighborhood.id : null,
      schedule_id: schedules && schedules._id,
    };

    const insertedPlace = await this.place.create(data);
    this.logger.log('New place', JSON.stringify(insertedPlace));
    return insertedPlace;
  }

  private formSchedule(schedule: any) {
    let scheduleArray = [];
    if (schedule) {
      scheduleArray = Object.entries(schedule)
        .map(([day, data]: [day: any, data: any]) => {
          const workingHours =
            data.working_hours && data.working_hours.length > 0
              ? data.working_hours[0]
              : { from: '', to: '' };
          return {
            from: workingHours.from,
            to: workingHours.to,
            day: day,
          };
        })
        .sort((a, b) => {
          const daysOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return daysOrder.indexOf(a.day) - daysOrder.indexOf(b.day);
        });
      return scheduleArray;
    }
    return scheduleArray;
  }

  private async createOrGetExistCategory(categories: { name: string }[]) {
    const categoryIds: ObjectId[] = [];
    for (const category of categories) {
      const existingCategory = await this.category.findOne({
        name: category.name,
      });
      if (existingCategory) {
        this.logger.log('Существует категория', existingCategory._id);
        categoryIds.push(existingCategory._id);
      } else {
        const newCategory = await this.category.create({
          name: category.name,
        });
        this.logger.log('Новая категория', newCategory._id);
        categoryIds.push(newCategory._id);
      }
    }
    return categoryIds;
  }

  async getPlacesByCategories(
    limit?: number,
    category_id?: string,
    page?: number,
  ) {
    const items: any[] = await getPlacesByCategoryId(
      category_id,
      process.env?.API_KEY,
      limit,
      page,
    );

    items.forEach(async (item) => {
      await this.addPlace('', true, item);
    });

    return 'Proccessing...';
  }
}
