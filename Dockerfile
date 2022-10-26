FROM nginx:1.23.2-alpine
LABEL maintainer.name=imane maintainer.email=kabkabimane22@gmail.com
RUN apk update \
    && rm -rf /usr/share/nginx/html/*
RUN sed -n -e 's/listen      80;/listen      $PORT;/g' -e 's/listen  [::]:80;/listen  [::]:$PORT;/g' /etc/nginx/conf.d/default.conf
ADD ./static-website-example   /usr/share/nginx/html/
RUN adduser -D no-root
USER no-root
CMD [ "nginx", "-g"; "daemon off;" ]
