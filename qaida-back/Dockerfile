FROM node:20-alpine

WORKDIR /home/app

COPY package.json /home/app

RUN npm install -g pnpm
RUN pnpm install

COPY . /home/app/

EXPOSE 8080
