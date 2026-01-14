#!/bin/bash

source ../.env
sed -i "s/LOKI_BASIC_AUTH_PASSWORD/${LOKI_BASIC_AUTH_PASSWORD}/g" ./config.alloy
sed -i "s/MIMIR_BASIC_AUTH_PASSWORD/${MIMIR_BASIC_AUTH_PASSWORD}/g" ./config.alloy
sed -i "s/ORG_ID/${ORG_ID}/g" ./config.alloy
