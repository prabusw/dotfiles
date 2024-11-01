#!/usr/bin/env sh
current_song=$(playerctl metadata --format 'Album: {{ album }}  Title:{{ title }}  Artist:{{artist }}')
makoctl dismiss && sway-notify "$current_song"
