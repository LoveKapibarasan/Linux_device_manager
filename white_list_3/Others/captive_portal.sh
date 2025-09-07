#!/bin/bash

# failed (blocked by vodafone..)

ip=$(dig @8.8.8.8 +short neverssl.com)

REDIRECT_URL=$(curl -sI http://$ip \
    | grep -i '^Location:' \
    | cut -d' ' -f2 \
    | tr -d '\r')

REDIRECT_URL=$(echo "$REDIRECT_URL" | sed 's/^https:/http:/')

echo "Redirected: $REDIRECT_URL"

curl -v "$REDIRECT_URL"
