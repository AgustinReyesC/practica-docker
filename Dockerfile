FROM node:22-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY package.json .
RUN npm install

COPY . .

RUN mkdir -p /app/datos

EXPOSE 3000

CMD ["node", "server.js"]
