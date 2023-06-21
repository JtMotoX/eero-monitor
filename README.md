# Eero Monitor

Monitors your Eero network and sends notifications and/or trigger webhooks for home automation.  This runs a Docker container from [JtMotoX/eero-client-docker](https://github.com/JtMotoX/eero-client-docker) which uses [343max/eero-client](https://github.com/343max/eero-client.git) to get information from your Eero network.

## Login:

1. ```docker volume create --name eero-client-data``` 

1. ```docker run --rm -it -v eero-client-data:/data jtmotox/eero-client info```



## Run Individual Scripts:

- ```docker-compose run --rm eero-monitor /scripts/list-networks.sh```

## Run Cron:

1. Copy the [sample.env](./sample.env) to [.env](./.env) and make necessary changes
1. ```docker-compose up -d```
1. ```docker-compose logs -f```

---

### Todo:
- Handle internet outages
