FROM node:26 AS build

WORKDIR /app


COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build

FROM node:26 AS production

WORKDIR /app

COPY --from=build /app/package.json /app/yarn.lock ./
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public

RUN yarn install --production --frozen-lockfile

ENV NODE_ENV=production

EXPOSE 4000

CMD ["yarn", "start"]
