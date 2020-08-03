#!/usr/bin/env bash

godot-headless --path src --export-pack web "$(readlink -f exports/particles-life.pck)" && scp exports/particles-life.pck extserver:/home/ubuntu/
