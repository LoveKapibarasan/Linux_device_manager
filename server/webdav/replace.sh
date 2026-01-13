#!/bin/bash

source ../.env
sed -i "s/WEBDAV_PASSWORD/${WEBDAV_PASSWORD}/g" ./webdav.yaml