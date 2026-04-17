import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBody, ApiResponse, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { ObjectId } from 'mongoose';
import { ReviewDTO, VoteDTO } from 'src/schema/dtos';
import { AuthGuard } from 'src/shared/guards/auth.guard';
import { PlaceReviewService } from './placeReview.service';

@ApiTags('Review')
@Controller('review')
export class ReviewController {
  constructor(private readonly placeReview: PlaceReviewService) {}

  @Get('/:place_id')
  async getPlaceReviews(@Param('place_id') place_id: ObjectId) {
    return await this.placeReview.getReviewForPlace(place_id);
  }

  @ApiResponse({
    type: 'string',
    isArray: true,
  })
  @Get('/vote/dict')
  getVoteDict() {
    return ['NEGATIVE', 'POSITIVE'];
  }

  @ApiResponse({ type: ReviewDTO })
  @ApiBody({
    type: ReviewDTO,
  })
  @UseGuards(AuthGuard)
  @Post('/')
  async addReview(@Req() req: Request, @Body() body: ReviewDTO) {
    const payload: ReviewDTO = {
      ...body,
      user_id: req['user']._id,
    };
    return await this.placeReview.addReview(payload);
  }

  @ApiResponse({ type: ReviewDTO })
  @ApiBody({
    type: ReviewDTO,
  })
  @UseGuards(AuthGuard)
  @Patch('/:review_id')
  async updateReview(
    @Param('review_id') review_id: ObjectId,
    @Req() req: Request,
    @Body() payload: { comment: string; score: number },
  ) {
    return await this.placeReview.handleReview(
      req['method'],
      payload,
      review_id,
    );
  }

  @UseGuards(AuthGuard)
  @Delete('/:review_id')
  async deleteReview(
    @Param('review_id') review_id: ObjectId,
    @Req() req: Request,
  ) {
    return await this.placeReview.handleReview(req['method'], null, review_id);
  }

  @ApiResponse({ type: VoteDTO })
  @ApiBody({
    type: VoteDTO,
  })
  @UseGuards(AuthGuard)
  @Patch('/:review_id/:vote_id')
  async updateVote(
    @Req() req: Request,
    @Param('vote_id') vote_id: ObjectId,
    @Param('review_id') review_id: ObjectId,
    @Body() { type }: { type: 'POSITIVE' | 'NEGATIVE' },
  ) {
    return await this.placeReview.handleVote(
      vote_id,
      review_id,
      type,
      req['method'],
    );
  }

  @ApiResponse({ type: ReviewDTO })
  @UseGuards(AuthGuard)
  @Delete('/:review_id/:vote_id')
  async deleteVote(
    @Req() req: Request,
    @Param('review_id') review_id: ObjectId,
    @Param('vote_id') vote_id: ObjectId,
  ) {
    return await this.placeReview.handleVote(
      vote_id,
      review_id,
      '',
      req['method'],
    );
  }

  @ApiResponse({ type: ReviewDTO })
  @ApiBody({ type: VoteDTO })
  @UseGuards(AuthGuard)
  @Post('/vote/:review_id')
  async addVote(
    @Req() req: Request,
    @Body() body: VoteDTO,
    @Param('review_id') review_id: ObjectId,
  ) {
    const payload: VoteDTO = {
      ...body,
      user_id: req['user']._id,
    };
    return await this.placeReview.addVoteToReview(review_id, payload);
  }
}
