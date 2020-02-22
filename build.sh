#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh

# Check acces do docker daemon
assert_dependency "docker"
if ! docker version &> /dev/null; then
    echo "Docker daemon is not running or you have unsufficient permissions!"
    exit -1
fi

# Build the image
APP_NAME="tvheadend"
docker build --tag "$APP_NAME" .

if confirm_action "Test image?"; then
	# Set up temporary directory
	TMP_CONF_DIR=$(mktemp -d "/tmp/$APP_NAME-CONF-XXXXXXXXXX")
	add_cleanup "rm -rf $TMP_CONF_DIR"
	TMP_REC_DIR=$(mktemp -d "/tmp/$APP_NAME-REC-XXXXXXXXXX")
	add_cleanup "rm -rf $TMP_REC_DIR"

	# Apply permissions, UID matches process user
	APP_UID=1359
	chown -R "$APP_UID":"$APP_UID" "$TMP_CONF_DIR" "$TMP_REC_DIR"

	# Start the test
	docker run \
	--rm \
	--interactive \
	--publish 9981:9981/tcp \
	--publish 9982:9982/tcp \
	--mount type=bind,source="$TMP_REC_DIR",target="/home/hts/rec" \
	--mount type=bind,source="$TMP_CONF_DIR",target="/home/hts/.hts/tvheadend" \
	--name "$APP_NAME" \
	"$APP_NAME"
fi