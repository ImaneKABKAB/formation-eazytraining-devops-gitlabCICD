FROM nginx:1.21.1
LABEL maintainer.name=imane maintainer.email=kabkabimane22@gmail.com
RUN apt-get update \
    && rm -rf /usr/share/nginx/html/*
COPY nginx.conf /etc/nginx/conf.d/default.conf
ADD ./static-website-example   /usr/share/nginx/html/
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
