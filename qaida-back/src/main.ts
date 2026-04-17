import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { InterestService } from './interest/interest.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['debug', 'error', 'log'],
  });
  const config = new DocumentBuilder()
    .setTitle('Qaida Diploma')
    .setDescription('The Qaida API description')
    .setVersion('1.0')
    .build();
  app.enableCors();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('swagger', app, document);

  app.setGlobalPrefix('api');

  (await app.resolve(InterestService)).populateInterests();

  await app.listen(8080);
}
bootstrap();
