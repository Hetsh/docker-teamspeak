FROM library/alpine:20200122
RUN apk add --no-cache \
    tvheadend=4.2.8-r1

ARG APP_USER="hts"
ARG APP_GROUP="hts"
RUN addgroup --gid 986 "$APP_GROUP" && \
    adduser --disabled-password --ingroup "$APP_GROUP" --uid 1359 "$APP_USER"
USER "$APP_USER"

ARG CONF_DIR="/home/$APP_USER/.hts/tvheadend"
VOLUME ["$CONF_DIR"]

ARG REC_DIR="/home/$APP_USER/rec"
VOLUME ["$REC_DIR"]

EXPOSE 9981/tcp 9982/tcp
#      HTTP     HTSP

ENTRYPOINT exec tvheadend -C
