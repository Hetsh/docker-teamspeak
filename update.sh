#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Base image
update_image "library/alpine" "Alpine" "\d{8}"

# Teamspeak Server
TS_PKG="APP_VERSION"
TS_VERSION_REGEX="(\d+\.)+\d+"
CURRENT_TS_VERSION=$(cat Dockerfile | grep -P -o "$TS_PKG=\K$TS_VERSION_REGEX")
NEW_TS_VERSION=$(curl -L -s "https://files.teamspeak-services.com/releases/server/" | grep -P -o "$TS_VERSION_REGEX" | sort --version-sort | tail -n 1)
if [ "$CURRENT_TS_VERSION" != "$NEW_TS_VERSION" ]; then
	prepare_update "$TS_PKG" "Teamspeak Server" "$CURRENT_TS_VERSION" "$NEW_TS_VERSION"
	update_version "$NEW_TS_VERSION"
fi

# Packages
IMG_ARCH="x86_64"
BASE_PKG_URL="https://pkgs.alpinelinux.org/package/edge"
update_pkg "libstdc++" "Std. C++ Libs" "false" "$BASE_PKG_URL/community/$IMG_ARCH" "(\d+\.)+\d+-r\d+"
update_pkg "ca-certificates" "CA-Certificates" "false" "$BASE_PKG_URL/main/$IMG_ARCH" "\d{8}-r\d+"

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi
