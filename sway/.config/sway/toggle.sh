#!/usr/bin/env bash

x_or_wayland="wayland"
# echo "Window system: $x_or_wayland"
# echo "one is $1"
# echo "two is $2"
if [[ ! -z "$2"  ]]; then
    x_or_wayland=$2
fi
# echo "Window system: $x_or_wayland"
app_name=$1

identifier="app_id"
active=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true).app_id')
if [[ $x_or_wayland == "X" ]]; then
    identifier="class"
    active=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true).window_properties.class')
fi

if [[ $active == $app_name ]]; then
    swaymsg "[$identifier=$app_name] move scratchpad"
else
    swaymsg "[$identifier=$app_name] focus"
fi

echo "active is $active"
echo "$active_window_properties"

