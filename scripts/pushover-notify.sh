#!/bin/sh

TITLE="Notification from eero-monitor"
MESSAGE="$1"

if [[ "${pushover_user}" == "" || "${pushover_token}" == "" ]]; then
    echo "You need to provide the 'pushover_user' and 'pushover_token' environment variables"
    exit 1
fi

if [[ "${MESSAGE}" == "" ]]; then
    echo "No message was given"
    exit 1
fi

curl -s \
    --form-string "user=${pushover_user}" \
    --form-string "token=${pushover_token}" \
    --form-string "title=${TITLE}" \
    --form-string "message=${MESSAGE}" \
    https://api.pushover.net/1/messages.json \
    >/dev/null 2>&1
