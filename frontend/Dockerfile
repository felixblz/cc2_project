FROM node:22 AS build
WORKDIR /app
COPY package*.json .
RUN npm ci --omit=dev --ignore-scripts
COPY . .
RUN npm run build

FROM nginx:stable-alpine-slim
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]