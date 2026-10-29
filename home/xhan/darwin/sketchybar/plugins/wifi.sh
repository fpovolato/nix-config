#!/usr/bin/env sh
# Show whether Wi-Fi is connected, and the network name when macOS reveals
# it (it hides the SSID from apps without Location Services access).

device="$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/ { getline; print $2 }')"
[ -z "$device" ] && exit 0

if [ -n "$(ipconfig getifaddr "$device")" ]; then
  ssid="$(ipconfig getsummary "$device" | awk -F ' SSID : ' '/ SSID : / { print $2 }')"
  [ "$ssid" = "<redacted>" ] && ssid=""
  sketchybar --set "$NAME" icon="" icon.color=0xffcdd6f4 label="$ssid" label.drawing="$([ -n "$ssid" ] && echo on || echo off)"
else
  sketchybar --set "$NAME" icon="" icon.color=0xff6c7086 label.drawing=off
fi
