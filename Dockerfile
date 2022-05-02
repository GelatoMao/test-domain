# Image Name:
#   hub.tess.io/adihadoop/bdp-nginx:v0.0.1

FROM hub.tess.io/adihadoop/alex-base-image:latest

RUN apt update && apt install -y nginx
RUN touch /var/log/nginx/access.log; \
 touch /var/log/nginx/error.log; \
 touch /run/nginx.pid; \
 chmod 777 /run/nginx.pid \
 mkdir -p /var/lib/nginx/body; \
 mkdir -p /var/lib/nginx/fastcgi; \
 mkdir -p /var/lib/nginx/proxy; \
 mkdir -p /var/lib/nginx/scgi; \
 mkdir -p /var/lib/nginx/uwsgi; 

RUN apk add --update busybox-suid vim
RUN apt-get update && apt install -y cron 

# RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN groupadd -g 70375 bdpai
RUN useradd -u 69760 -g bdpai bdpai
USER 69760


ADD --chown=bdpai:bdpai crontab /etc/crontabs/bdpai
RUN dos2unix /etc/crontabs/bdpai
ADD --chown=bdpai:bdpai clear.sh ./clear.sh

# COPY ./clear.sh /bdp/clear.sh
# WORKDIR /bdp

CMD ["crond", "-f"]
