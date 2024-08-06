#!/usr/bin/env bash
current_queue=$(cmus-remote -C "save -q -" |sed 's/.*\///')
makoctl dismiss && sway-notify "$current_queue"
