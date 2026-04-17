import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, ObjectId } from 'mongoose';
import { InterestDTO } from 'src/schema/dtos';

@Injectable()
export class InterestService {
  constructor(
    @InjectModel('Interest') private readonly interest: Model<InterestDTO>,
  ) {}

  public async populateInterests() {
    const interests = await this.interest.find();
    if (interests.length === 0) {
      const initialInterests = [
        { name: 'Кино' },
        { name: 'Кальян' },
        { name: 'Бар' },
      ];

      return await this.interest.insertMany(initialInterests, {
        includeResultMetadata: true,
      });
    }
  }

  public async addInterest(name: string) {
    return await this.interest.create({ name });
  }

  public async removeInterest(id: ObjectId) {
    return await this.interest.findOneAndDelete({ _id: id });
  }
}
