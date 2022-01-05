#!/bin/sh

cd "$(dirname "$0")"

IS_SOMEONE_HOME=$(./is-someone-home.sh)

if ! [[ "${IS_SOMEONE_HOME}" =~ ^[0-9]+$ ]]; then
	echo -e "${IS_SOMEONE_HOME}"
    echo "Error getting data"
	exit 1
fi

PREVIOUS_COUNT_FILE=/tmp/monitor-someone-home-previous-count.txt
touch "${PREVIOUS_COUNT_FILE}"
PREVIOUS_COUNT=$(cat "${PREVIOUS_COUNT_FILE}")
PREVIOUS_COUNT=${PREVIOUS_COUNT:-'0'}
echo "${IS_SOMEONE_HOME}" >"${PREVIOUS_COUNT_FILE}"

if [[ "${IS_SOMEONE_HOME}" -eq 0 && "${PREVIOUS_COUNT}" -gt 0 ]]; then
	echo "Everybody left"
	./pushover-notify.sh "Everybody left"
elif [[ "${IS_SOMEONE_HOME}" -gt 0 && "${PREVIOUS_COUNT}" -eq 0 ]]; then
	echo "Someone came home"
	./pushover-notify.sh "Someone came home"
fi
