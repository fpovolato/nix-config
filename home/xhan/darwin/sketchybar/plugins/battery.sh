#!/usr/bin/env sh
# Show the battery charge and whether the Mac is charging.

percentage="$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)"
[ -z "$percentage" ] && exit 0

case "$percentage" in
  9[0-9]|100) icon="" ;;
  [6-8][0-9]) icon="" ;;
  [3-5][0-9]) icon="" ;;
  [1-2][0-9]) icon="" ;;
  *) icon="" ;;
esac

if pmset -g batt | grep -q "AC Power"; then
  icon=""
fi

sketchybar --set "$NAME" icon="$icon" label="$percentage%"
