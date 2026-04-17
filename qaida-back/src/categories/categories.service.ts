import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CategoryDocument, RubricsDocument } from 'src/schema/dtos';
import { getAllRubrics } from 'src/shared/utils/integrationService';

import categories from './csvjson.json';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectModel('Category') private readonly category: Model<CategoryDocument>,
    @InjectModel('Rubric') private readonly rubric: Model<RubricsDocument>,
  ) {}
  private logger = new Logger();

  async getAllCategories(q: string) {
    let aggregationPipeline: any[] = [];

    if (q) {
      aggregationPipeline = [
        {
          $lookup: {
            from: 'categories', // Assuming the name of your categories collection is 'categories'
            localField: 'category_ids',
            foreignField: '_id',
            as: 'categories',
          },
        },
        {
          $addFields: {
            categories: {
              $filter: {
                input: '$categories',
                as: 'category',
                cond: {
                  $regexMatch: {
                    input: { $toLower: '$$category.name' },
                    regex: q.toLowerCase(),
                  },
                },
              },
            },
          },
        },
        {
          $match: {
            categories: { $ne: [] },
          },
        },
      ];
    } else {
      aggregationPipeline = [
        {
          $lookup: {
            from: 'categories',
            localField: 'category_ids',
            foreignField: '_id',
            as: 'categories',
          },
        },
      ];
    }

    const data = await this.rubric.aggregate(aggregationPipeline);

    return data;
  }

  async loadCategories() {
    const categoriesArray = await getAllRubrics(process.env?.API_KEY);

    this.logger.debug('Количество категории', categoriesArray.length);

    const newCategories = (
      await this.createOrGetExistCategory(categoriesArray)
    ).map((e) => ({
      name: e,
    }));

    const dbCategories = await this.category.insertMany(newCategories);

    return dbCategories;
  }

  private async createOrGetExistCategory(categories: string[]) {
    const existedCategories = await this.category.find({}, { name: 1, _id: 0 });
    const existedNames = existedCategories.map((e) => e.name);

    const newCategories = categories.filter(
      (category) => !existedNames.includes(category),
    );

    return newCategories;
  }

  async loadFromFile() {
    const groupedObjects = [];
    const groups = {};

    for (const obj of categories) {
      const group = obj.group;
      const _id = obj._id;

      if (!(group in groups)) {
        groups[group] = { name: group, category_ids: [_id] };
      } else {
        groups[group].category_ids.push(_id);
      }
    }

    for (const group in groups) {
      groupedObjects.push(groups[group]);
    }

    const rubrics = await this.rubric.insertMany(groupedObjects);
    return rubrics;
  }
}
