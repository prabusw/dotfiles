#!/usr/bin/env sh
current_song=$(playerctl metadata --format '{{ title }} from {{ album }} by {{artist }} is playing in {{ playerName }}')
makoctl dismiss && sway-notify "$current_song"
