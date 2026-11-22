FROM node:26 AS build

WORKDIR /app

RUN npm install -g corepack

COPY package.json yarn.lock ./
RUN yarn install --immutable

COPY . .
RUN yarn build


FROM node:26 AS production

WORKDIR /app

RUN npm install -g corepack

COPY --from=build /app/package.json /app/yarn.lock ./
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public

RUN yarn install --production --immutable

ENV NODE_ENV=production

EXPOSE 4000

CMD ["yarn", "start"]
