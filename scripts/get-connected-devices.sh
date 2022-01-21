#!/bin/sh

cd "$(dirname "$0")"

if [[ "${NETWORK_ID}" == "" ]]; then
	echo You must pass the NETWORK_ID
	exit 1
fi

DEVICES_JSON=$(cd /eero-client; ./sample.py devices)

(echo "${DEVICES_JSON}" | jq empty >/dev/null 2>&1) || { echo -e "${DEVICES_JSON}"; exit 1; }

echo -e "${DEVICES_JSON}" | jq '.[]' | jq -s | jq -r --arg NETWORK_FILTER "/${NETWORK_ID}/" '.[] | select(.url | contains($NETWORK_FILTER)) | select(.connected == true) | {name: (if .nickname != null then .nickname else .hostname end) } | .[]' | sort
