#!/bin/sh

cd "$(dirname "$0")"

INFO_JSON=$(cd /eero-client; ./sample.py info)

(echo "${INFO_JSON}" | jq empty >/dev/null 2>&1) || { echo -e "${INFO_JSON}"; exit 1; }

echo -e "${INFO_JSON}" | jq '. + {network_id: .url} | .network_id |= sub(".*networks\/"; "") | {name: .name, network_id: .network_id}'
