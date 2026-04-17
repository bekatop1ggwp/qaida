import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AuthModule } from './auth/auth.module';
import { CategoriesModule } from './categories/categories.module';
import { CoreModule } from './core/core.module';
import { LobbyModule } from './lobby/lobby.module';
import { PlaceModule } from './place/place.module';
import { SchemaModule } from './schema/schema.module';
import { UserModule } from './user/user.module';
import { WebsocketModule } from './websocket/websocket.module';

@Module({
  imports: [
    AuthModule,
    CoreModule,
    UserModule,
    LobbyModule,
    WebsocketModule,
    SchemaModule,
    ConfigModule.forRoot({
      envFilePath: 'src/core/.env',
      ignoreEnvVars: false,
    }),
    PlaceModule,
    MongooseModule.forRoot(process.env?.DATABASE_URL),
    CategoriesModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
