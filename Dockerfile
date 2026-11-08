FROM nginx:1.31-alpine-slim AS web

RUN rm -rf /etc/nginx/ /var/www/

COPY ./env/nginx /etc/nginx/
COPY ./build /var/www/

EXPOSE 8080/tcp
