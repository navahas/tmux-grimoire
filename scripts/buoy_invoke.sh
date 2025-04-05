#!/usr/bin/env bash
mode=$1 # standard or ephemeral

custom_buoy=$2
custom_buoy=$2
custom_buoy="${custom_buoy// /-}" # Replace spaces with dashes
custom_buoy="${custom_buoy//[^a-zA-Z0-9_-]/}" # Strip all non-alphanumeric except - and _
custom_buoy="${custom_buoy,,}" # Convert to lowercase

custom_command=$3
custom_command=${3:-}
custom_command="${custom_command//\"/\\\"}"  # Escape " early

replay_flag=$4

buoy_session="_buoy-session"
ephemeral_buoy_session="_ephemeral-buoy-session"

# Resolve buoy script base path
buoyspath=$(tmux show-option -gv '@buoyshell-buoyspath' 2>/dev/null)
: "${buoyspath:=$HOME/.config/custom-buoys}"


if [[ "$custom_command" == buoys/* ]]; then
  custom_command="$buoyspath/${custom_command#buoys/}"
fi

# Universal detach or invoke for Persistent Buoy
if [[ "standard" == "${mode}" ]]; then
  current_session=$(tmux display-message -p '#{client_session}')
  if [[ "$current_session" == "$ephemeral_buoy_session" ]]; then
      tmux detach-client -s "$ephemeral_buoy_session"
  elif [[ "$current_session" == "$buoy_session" ]]; then
      tmux detach-client -s "$buoy_session"
  else
      . ~/.tmux/plugins/tmux-buoyshell/scripts/buoy.sh "$custom_buoy" "$custom_command" "$replay_flag"
  fi
# Universal detach or invoke for Ephemeral Buoy
elif [[ "ephemeral" == "${mode}" ]]; then
  current_session=$(tmux display-message -p '#{client_session}')
  if [[ "$current_session" == "$buoy_session" ]]; then
      tmux detach-client -s "$buoy_session"
  elif [[ "$current_session" == "$ephemeral_buoy_session" ]]; then
      tmux detach-client -s "$ephemeral_buoy_session"
  else
      . ~/.tmux/plugins/tmux-buoyshell/scripts/ephemeral_buoy.sh "$custom_buoy" "$custom_command"
  fi
fi
