#!/bin/bash

source .env
sed -i "s/LOKI_BASIC_PASSWORD/${LOKI_BASIC_PASSWORD}/g" ./traefik/dynamic_conf.yml
docker restart traefik