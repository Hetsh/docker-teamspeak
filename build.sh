#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh

# Check access to docker daemon
assert_dependency "docker"
if ! docker version &> /dev/null; then
	echo "Docker daemon is not running or you have unsufficient permissions!"
	exit -1
fi

# Build the image
APP_NAME="teamspeak"
docker build --tag "$APP_NAME" .

if confirm_action "Test image?"; then
	# Set up temporary directory
	TMP_DIR=$(mktemp -d "/tmp/$APP_NAME-XXXXXXXXXX")
	add_cleanup "rm -rf $TMP_DIR"

	# Configuration from ReadMe
	echo "license_accepted=1
dbsqlpath=/opt/teamspeak-server/sql/
logpath=/var/log/teamspeak-server
serverquerydocs_path=/opt/teamspeak-server/serverquerydocs" > "$TMP_DIR/app.ini"

	# Apply permissions, UID matches process user
	extract_var APP_UID "./Dockerfile" "\K\d+"
	chown -R "$APP_UID":"$APP_UID" "$TMP_DIR"

	# Start the test
	extract_var CONF_DIR "./Dockerfile" "\"\K[^\"]+"
	extract_var DATA_DIR "./Dockerfile" "\"\K[^\"]+"
	docker run \
	--rm \
	--tty \
	--interactive \
	--publish 9987:9987/udp \
	--publish 10011:10011/tcp \
	--publish 10022:10022/tcp \
	--publish 30033:30033/tcp \
	--mount type=bind,source="$TMP_DIR/app.ini",destination="$CONF_DIR/app.ini" \
	--mount type=bind,source="$TMP_DIR",destination="$DATA_DIR" \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
	--name "$APP_NAME" \
	"$APP_NAME"
fi