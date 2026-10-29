#!/usr/bin/env sh
# Show the output volume; $INFO holds it on volume_change.

if [ "$SENDER" = "volume_change" ]; then
  case "$INFO" in
    [6-9][0-9]|100) icon="" ;;
    [1-9]|[1-5][0-9]) icon="" ;;
    *) icon="" ;;
  esac
  sketchybar --set "$NAME" icon="$icon" label="$INFO%"
fi
