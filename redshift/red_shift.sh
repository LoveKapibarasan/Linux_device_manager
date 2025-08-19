#!/usr/bin/env bash
# 例: save as set_bluelight_pi.sh, then: chmod +x set_bluelight_pi.sh

GAMMA="1:0.6:0.4"

# connected な output 名を自動取得
OUTPUT=$(xrandr --query | awk '/ connected/{print $1; exit}')

if [ -n "$OUTPUT" ]; then
    echo "Setting gamma for $OUTPUT"
    xrandr --output "$OUTPUT" --gamma $GAMMA
else
    echo "No connected display found!"
fi

# xrandr --output eDP-1 --gamma 1:0.6:0.4 # internal display
# echo 'xrandr --output eDP-1 --gamma 1:0.6:0.4' >> ~/.profile

