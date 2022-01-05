#!/bin/sh

cd "$(dirname "$0")"

CONNECTED_DEVICES_JSON=$(./get-connected-devices.sh)

(echo "${CONNECTED_DEVICES_JSON}" | jq empty >/dev/null 2>&1) || { echo -e "${CONNECTED_DEVICES_JSON}"; exit 1; }

SEARCH_CONNECTED=$(echo -e "${CONNECTED_DEVICES_JSON}" | jq --arg SEARCH_CONNECTED_REGEXP "${SEARCH_CONNECTED_REGEXP}" '[.[] | select(.name | test($SEARCH_CONNECTED_REGEXP))] | length')

echo $SEARCH_CONNECTED
