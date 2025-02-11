#!/usr/bin/env bash
mode=$1 # standard or ephemeral

buoy_key=$(tmux show-option -gv '@buoyshell-key')
ephemeral_buoy_key=$(tmux show-option -gv '@ephemeral-buoyshell-key')
buoy_session="_buoy-session"
ephemeral_buoy_session="_ephemeral-buoy-session"

# Universal detach or invoke for Persistent Buoy
if [[ "standard" == "${mode}" ]]; then
  current_session=$(tmux display-message -p '#{client_session}')
  if [[ "$current_session" == "$ephemeral_buoy_session" ]]; then
      tmux detach-client -s "$ephemeral_buoy_session"
  elif [[ "$current_session" == "$buoy_session" ]]; then
      tmux detach-client -s "$buoy_session"
  else
      . ~/.tmux/plugins/tmux-buoyshell/scripts/buoy.sh
  fi
# Universal detach or invoke for Ephemeral Buoy
elif [[ "ephemeral" == "${mode}" ]]; then
  current_session=$(tmux display-message -p '#{client_session}')
  if [[ "$current_session" == "$buoy_session" ]]; then
      tmux detach-client -s "$buoy_session"
  elif [[ "$current_session" == "$ephemeral_buoy_session" ]]; then
      tmux detach-client -s "$ephemeral_buoy_session"
      tmux kill-session -t "$ephemeral_buoy_session"
  else
      . ~/.tmux/plugins/tmux-buoyshell/scripts/ephemeral_buoy.sh
  fi
fi
