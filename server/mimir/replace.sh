#!/bin/bash

source ../.env
sed -i "s/MINIO_ROOT_PASSWORD/${MINIO_ROOT_PASSWORD}/g" ./mimir.yaml