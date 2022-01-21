#!/bin/sh

cd "$(dirname "$0")"

CONNECTED_DEVICES_JSON=$(./get-connected-devices.sh)

SEARCH_CONNECTED_COUNT=$(echo -e "${CONNECTED_DEVICES_JSON}" | grep -E "${SEARCH_CONNECTED_REGEXP}" | wc -l)

echo $SEARCH_CONNECTED_COUNT
