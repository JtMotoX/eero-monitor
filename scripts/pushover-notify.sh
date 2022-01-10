#!/bin/sh

TITLE="Notification from eero-monitor"
MESSAGE="$1"

if [[ "${PUSHOVER_USER}" == "" || "${PUSHOVER_TOKEN}" == "" ]]; then
    echo "You need to provide the 'PUSHOVER_USER' and 'PUSHOVER_TOKEN' environment variables"
    exit 1
fi

if [[ "${MESSAGE}" == "" ]]; then
    echo "No message was given"
    exit 1
fi

curl -s \
    --form-string "user=${PUSHOVER_USER}" \
    --form-string "token=${PUSHOVER_TOKEN}" \
    --form-string "title=${TITLE}" \
    --form-string "message=${MESSAGE}" \
    https://api.pushover.net/1/messages.json \
    >/dev/null 2>&1
