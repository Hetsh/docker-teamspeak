FROM library/alpine:20200319
RUN apk add --no-cache \
    libstdc++=9.3.0-r1 \
    ca-certificates=20191127-r2

# Unprivileged user
ARG APP_USER="ts"
ARG APP_UID=1361
RUN adduser --disabled-password --uid "$APP_UID" --no-create-home --gecos "$APP_USER" --shell /sbin/nologin "$APP_USER"

# Teamspeak Server
ARG APP_VERSION=3.12.1
ARG APP_DIR="/opt/teamspeak-server"
ARG APP_ARCHIVE="teamspeak3-server_linux_alpine-$APP_VERSION.tar.bz2"
ADD "https://files.teamspeak-services.com/releases/server/$APP_VERSION/$APP_ARCHIVE" "$APP_DIR/$APP_ARCHIVE"
RUN tar --extract --strip-components=1 --directory "$APP_DIR" --file "$APP_DIR/$APP_ARCHIVE" && \
    rm "$APP_DIR/$APP_ARCHIVE"

# Volumes & Configuration
ARG DATA_DIR="/teamspeak-server-data"
ARG CONF_DIR="/etc/teamspeak-server"
ARG LOG_DIR="/var/log/teamspeak-server"
RUN mkdir "$DATA_DIR" "$CONF_DIR" "$LOG_DIR" && \
    echo -e "license_accepted=1\ndbsqlpath=$APP_DIR/sql/\nlogpath=$LOG_DIR\nserverquerydocs_path=$APP_DIR/serverquerydocs" > "$CONF_DIR/teamspeak-server.ini" && \
    chown -R "$APP_USER":"$APP_USER" "$DATA_DIR" "$CONF_DIR" "$LOG_DIR"
VOLUME ["$DATA_DIR", "$LOG_DIR", "$CONF_DIR"]

#      VOICE    QUERY/RAW QUERY/SSH FILES
EXPOSE 9987/udp 10011/tcp 10022/tcp 30033/tcp

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT "/opt/teamspeak-server/ts3server" inifile="/etc/teamspeak-server/app.ini"
