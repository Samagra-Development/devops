ROM node:18 AS install
WORKDIR /app
COPY package.json ./
RUN yarn install

FROM node:18 as build
WORKDIR /app
COPY prisma ./prisma/
RUN npx prisma generate
RUN ls prisma
RUN ls prisma/generated
COPY --from=install /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:18
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/node_modules ./node_modules
EXPOSE 3000

# https://docs.docker.com/reference/dockerfile/#healthcheck
# interval:Time between running the check
# timeout: Maximum time to allow one check to run
# start-period: Start period for the container to initialize before starting health-retries countdown
# start-interval: Time between running the check during the start period 
# retries: Consecutive failures needed to report unhealthy
#
# only exit code 1 should be used to indicate unhealthy containers
HEALTHCHECK --interval=30s \
--timeout=30s \
--start-period=10s \
--start-interval=5s \
--retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1 

CMD [ "npm", "run", "start:migrate:prod" ]