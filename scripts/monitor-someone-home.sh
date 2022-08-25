#!/bin/sh

cd "$(dirname "$0")"

##################################################

init_config() {
	CONFIG_FILE="$1"
	# CREATE BLANK CONFIG IF CONFIG IS EMPTY OR INVALID
	MONITOR_CONFIGS=$(cat "${MONITOR_FILE}" 2>/dev/null)
	if [[ -z "${MONITOR_CONFIGS}" || $(echo "${MONITOR_CONFIGS}" | jq empty 2>/dev/null; echo $?;) -ne 0 ]]; then
		echo -n "{}" >"${MONITOR_FILE}"
	fi
}

determine_jq_arg_type() {
	VAL="$1"
	# DETERMINE IF VALUE IS JSON VALUE OR STRING
	if (echo '{}' | jq --argjson val "${VAL}" '.' >/dev/null 2>&1); then
		echo "--argjson"
	else
		echo "--arg"
	fi
}

update_config() {
	# GET PARAMETERS
	CONFIG_FILE="$1"
	KEY="$2"
	VAL="$3"
	init_config "${CONFIG_FILE}"
	ARG_TYPE=$(determine_jq_arg_type "${VAL}")
	# WRITE TO FILE
	CONFIGS=$(cat "${CONFIG_FILE}" | jq --arg key "${KEY}" ${ARG_TYPE} val "${VAL}" '. + {($key): $val}')
	echo -e "${CONFIGS}" >"${CONFIG_FILE}"
}

get_config() {
	CONFIG_FILE="$1"
	KEY="$2"
	VAL="$3"
	init_config "${CONFIG_FILE}"
	ARG_TYPE=$(determine_jq_arg_type "${VAL}")
	VAL=$(jq --arg key "${KEY}" ${ARG_TYPE} val "${VAL}" '.[$key] // $val' "${CONFIG_FILE}")
	echo -e "${VAL}"
}

##################################################

# GET NUMBER OF PEOPLE HOME
IS_SOMEONE_HOME=$(./is-someone-home.sh)

# MAKE SURE WE RECEIVED AN INTEGER OF NUMBER OF PEOPLE HOME
if ! [[ "${IS_SOMEONE_HOME}" =~ ^[0-9]+$ ]]; then
	echo -e "${IS_SOMEONE_HOME}"
    echo "Error getting data"
	exit 1
fi

# SET MONITOR FILE
MONITOR_FILE=/tmp/monitor-conf.json
if [[ -f "${MONITOR_FILE}" ]]; then
	MONITOR_FILE_CREATED=0
else
	touch "${MONITOR_FILE}"
    MONITOR_FILE_CREATED=1
fi

# DISPLAY CONFIG CONTENT
# cat "${MONITOR_FILE}" | jq

# GET PREVIOUS CONFIG
PREVIOUS_IS_SOMEONE_HOME=$(get_config "${MONITOR_FILE}" "IS_SOMEONE_HOME" 0)
SOMEBODY_HOME_TIME=$(get_config "${MONITOR_FILE}" "SOMEBODY_HOME_TIME" 0)
ACTION_PERFORMED_STATE=$(get_config "${MONITOR_FILE}" "ACTION_PERFORMED_STATE" 0) # 0 = ACTION PERFORMED FOR NOBODY HOME, 1 = ACTION PERFORMED FOR SOMEBODY HOME

# UPDATE CONFIGS
update_config "${MONITOR_FILE}" "IS_SOMEONE_HOME" "${IS_SOMEONE_HOME}"

# NOBODY IS HOME
if [[ "${IS_SOMEONE_HOME}" -eq 0 ]]; then
	# DO NOT PERFORM ACTION IF CONTAINER STARTED FRESH
	if [[ "${MONITOR_FILE_CREATED}" -eq 1 ]]; then
		ACTION_PERFORMED_STATE=0
		update_config "${MONITOR_FILE}" "ACTION_PERFORMED_STATE" ${ACTION_PERFORMED_STATE}
	fi
	# PERFORM ACTION IF WE HAVE NOT ALREADY
	if [[ "${ACTION_PERFORMED_STATE}" -ne 0 ]]; then
		SOMEBODY_HOME_AGO="$(($(date +%s)-SOMEBODY_HOME_TIME))"
		# TRIGGER WHEN NOBODY HAS BEEN HOME FOR SPECIFIED LENGTH OF TIME
		if [[ "${SOMEBODY_HOME_AGO}" -gt ${NOTIFY_GONE_SEC} ]]; then
			update_config "${MONITOR_FILE}" "ACTION_PERFORMED_STATE" 0
			echo "Everybody left"
			curl "https://api.voicemonkey.io/trigger?access_token=${VOICEMONKEY_ACCESS}&secret_token=${VOICEMONKEY_SECRET}&monkey=${MONKEY_AWAY}" >/dev/null 2>&1
		fi
	fi
# SOMEBODY IS HOME
elif [[ "${IS_SOMEONE_HOME}" -gt 0 ]]; then
	update_config "${MONITOR_FILE}" "SOMEBODY_HOME_TIME" $(date +%s)
	# DO NOT PERFORM ACTION IF CONTAINER STARTED FRESH
	if [[ "${MONITOR_FILE_CREATED}" -eq 1 ]]; then
		ACTION_PERFORMED_STATE=1
		update_config "${MONITOR_FILE}" "ACTION_PERFORMED_STATE" ${ACTION_PERFORMED_STATE}
	fi
	# PERFORM ACTION IF WE HAVE NOT ALREADY
	if [[ "${ACTION_PERFORMED_STATE}" -ne 1 ]]; then
		update_config "${MONITOR_FILE}" "ACTION_PERFORMED_STATE" 1
		echo "Someone came home"
		curl "https://api.voicemonkey.io/trigger?access_token=${VOICEMONKEY_ACCESS}&secret_token=${VOICEMONKEY_SECRET}&monkey=${MONKEY_HOME}" >/dev/null 2>&1
	fi
fi
