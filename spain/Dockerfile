# build-stage
FROM node:26.1.0 AS build-stage
WORKDIR /home
COPY www .
RUN npm install
RUN npm run build

# runtime-stage
FROM nginx:alpine AS runtime-stage
COPY --from=build-stage /home/dist /usr/share/nginx/html
