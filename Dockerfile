FROM node:26-alpine AS base

# Install corepack (included in Node.js 26+, but explicit enable for Alpine)
RUN corepack enable

FROM base AS build

WORKDIR /app

# Copy package files first for better layer caching
COPY package.json yarn.lock ./
RUN yarn install --immutable

COPY . .
RUN yarn build

FROM base AS production

WORKDIR /app
ENV NODE_ENV=production

# Copy production dependencies manifest
COPY --from=build /app/package.json /app/yarn.lock ./

RUN yarn install --immutable

COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public

# Switch to non-root user
USER 1000 1000

EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:4000 || exit 1

CMD ["yarn", "start"]
