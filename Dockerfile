FROM node:12.21.0 AS build

ENV APP_DIR /app
WORKDIR $APP_DIR

ADD . $APP_DIR

RUN npm install --silent

RUN npm run build

FROM nginx:1.16.0-alpine

RUN apk --no-cache add curl

RUN curl -L https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-`uname -s`-`uname -m` -o envsubst && \
    chmod +x envsubst && \
    mv envsubst /usr/local/bin

COPY nginx/nginx.conf /etc/nginx/nginx.template
COPY --from=build /app/build /usr/share/nginx/html

ENTRYPOINT ["/bin/sh", "-c"]

CMD ["envsubst < /etc/nginx/nginx.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]