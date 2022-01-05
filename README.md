# Eero Monitor

Monitors your Eero network and sends notifications and/or trigger webhooks for home automation.

## Login:

1. ```docker volume create --name eero-client-data``` 

1. ```docker run --rm -it -v eero-client-data:/data jtmotox/eero-client info```

## Run:

1. ```docker-compose up -d```
1. ```docker-compose logs -f```