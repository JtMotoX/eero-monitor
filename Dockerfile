FROM jtmotox/eero-client:latest

# SETUP SUPERCRONIC
ENV SUPERCRONIC_VERSION="v0.2.1"
RUN wget https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
	chmod 755 /usr/local/bin/supercronic
COPY --chown=root --chmod=644 ./crontab /crontab
RUN supercronic -json -test /crontab

RUN mkdir -p /scripts && \
	printf '#!/bin/sh\nexec "$@"' >/scripts/entrypoint.sh && \
	chmod 755 /scripts/entrypoint.sh

WORKDIR /scripts

USER 9001:9001

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
