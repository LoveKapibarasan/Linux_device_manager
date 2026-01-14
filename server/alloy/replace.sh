#!/bin/bash

source ../.env
read -p "Enter org ID: " ORG_ID
export ORG_ID=''
sed -i "s/LOKI_BASIC_PASSWORD/${LOKI_BASIC_PASSWORD}/g" ./config.alloy
sed -i "s/ORG_ID/${ORG_ID}/g" ./config.alloy