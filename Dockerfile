FROM jtmotox/eero-client:latest

ARG USER_ID="1001"

# SETUP SUPERCRONIC
ENV SUPERCRONIC_VERSION="v0.2.1"
RUN wget https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
	chmod 755 /usr/local/bin/supercronic
COPY --chown=${USER_ID} --chmod=644 ./crontab /crontab
RUN supercronic -json -test /crontab

USER ${USER_ID}
