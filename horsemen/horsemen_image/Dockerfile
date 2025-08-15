FROM node:22.18.0
WORKDIR /app
COPY package.json .
RUN yarn install
COPY . .
EXPOSE 3001
ENTRYPOINT ["yarn", "run", "serve"]