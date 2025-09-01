#!/bin/bash

REDIRECT_URL=$(curl -sI http://neverssl.com \
    | grep -i '^Location:' \
    | cut -d' ' -f2 \
    | tr -d '\r')

REDIRECT_URL=$(echo "$REDIRECT_URL" | sed 's/^https:/http:/')

echo "Redirected: $REDIRECT_URL"

curl -v "$REDIRECT_URL"
