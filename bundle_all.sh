#!/usr/bin/env bash

./bundle_server.sh
godot-headless --path src --export web "$(readlink -f exports/web/index.html)"
butler push exports/web creikey/particles-battle:web
