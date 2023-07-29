FROM node:14-alpine

WORKDIR /app

COPY package.json package-lock.json /app/

RUN npm ci --production

COPY app.js /app

EXPOSE 80

CMD ["node", "app.js"]