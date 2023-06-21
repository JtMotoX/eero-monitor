#!/bin/sh

# CONVERT 1PASSWORD ENVIRONMENT VARIABLES
if env | grep -E '^[^=]*=OP:' >/dev/null; then
	curl -sS -o /tmp/1password-vars.sh "https://raw.githubusercontent.com/JtMotoX/1password-docker/main/1password/op-vars.sh"
	chmod 755 /tmp/1password-vars.sh
	. /tmp/1password-vars.sh || exit 1
	rm -f /tmp/1password-vars.sh
fi

# MAKE SURE WE HAVE ACCESS TO LOG FILES
if ! { touch /logs/.test && rm -f /logs/.test; }; then
	echo "ERROR: Access denied 'logs'"
	echo "note: 'chmod -R 777 logs'"
	exit 1
fi
for file in $(find /logs -type f -name '*.log'); do
	if [ ! -w "${file}" ]; then
		echo "ERROR: Access denied '$(basename ${file})'"
		echo "note: 'chmod -R 777 logs'"
		exit 1
	fi
done

if [ "$1" = "run" ]; then
	supercronic /crontab >/proc/1/fd/1 2>&1
	exit 1
fi

exec "$@"
