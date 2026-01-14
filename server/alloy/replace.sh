#!/bin/bash

source ../.env
read -p "Enter org ID: " ORG_ID
export ORG_ID=''
sed -i "s/LOKI_PASSWORD/${LOKI_PASSWORD}/g" ./config.alloy
sed -i "s/ORG_ID/${ORG_ID}/g" ./config.alloy