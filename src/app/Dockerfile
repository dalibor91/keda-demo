# building of app 
FROM node:18.14 as build 

COPY . /app
WORKDIR /app

RUN npm i && npm run build 

FROM node:18.14 as prod 

RUN mkdir /app 
WORKDIR /app

COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/package-lock.json ./package-lock.json

RUN npm install --production 

FROM prod as consumer 

CMD ["node", "dist/main.js", "consume"]

FROM prod as producer 

CMD ["node", "dist/main.js", "produce"]