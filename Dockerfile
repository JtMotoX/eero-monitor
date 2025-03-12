FROM jtmotox/eero-client:latest

# SETUP SUPERCRONIC
ADD --chmod=755 https://github.com/aptible/supercronic/releases/latest/download/supercronic-linux-amd64 /usr/local/bin/supercronic
COPY --chown=root --chmod=644 ./crontab /crontab
RUN supercronic -no-reap -json -test /crontab

RUN mkdir -p /scripts && \
	printf '#!/bin/sh\nexec "$@"' >/scripts/entrypoint.sh && \
	chmod 755 /scripts/entrypoint.sh

WORKDIR /scripts

USER 9001:9001

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
