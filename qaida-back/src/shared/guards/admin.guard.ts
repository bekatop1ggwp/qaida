import {
  CanActivate,
  ExecutionContext,
  Injectable,
  MethodNotAllowedException,
  UnauthorizedException,
} from '@nestjs/common';
import { CustomRequest } from './Request';

@Injectable()
export class AdminGuard extends CustomRequest implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) throw new UnauthorizedException('Токен не найден');
    try {
      const payload = (await this.extractUserFromToken(token)) as { _id: any };
      if (await this.checkAdmin(payload._id)) {
        return false;
      }
      request['admin'] = true;
      return true;
    } catch (error) {
      throw new MethodNotAllowedException('Не являеться админом');
    }
  }
}
