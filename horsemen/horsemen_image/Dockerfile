FROM node:22.18.0
RUN apt-get update && apt-get install -y vim
WORKDIR /app
COPY package.json .
RUN yarn install
COPY . .
EXPOSE 3001
ENTRYPOINT ["yarn", "run", "serve"]
