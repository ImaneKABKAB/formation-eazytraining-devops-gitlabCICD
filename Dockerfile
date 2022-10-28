FROM nginx:1.23.2-alpine
LABEL maintainer.name=imane maintainer.email=kabkabimane22@gmail.com
RUN apk update \
    && rm -rf /usr/share/nginx/html/*
RUN chmod 777 /etc/nginx/nginx.conf
COPY static.com.conf /etc/nginx/conf.d/
RUN chmod 777 /etc/nginx/conf.d/static.com.conf
ADD ./static-website-example   /usr/share/nginx/html/
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/static.com.conf && nginx -g 'daemon off;'
