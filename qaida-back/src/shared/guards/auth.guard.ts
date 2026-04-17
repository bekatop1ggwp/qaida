import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { CustomRequest } from './Request';

@Injectable()
export class AuthGuard extends CustomRequest implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) throw new UnauthorizedException();
    try {
      const payload = await this.extractUserFromToken(token);
      request['user'] = payload;
      return true;
    } catch (error) {
      throw new UnauthorizedException();
    }
  }
}
