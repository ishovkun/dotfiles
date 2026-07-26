#!/usr/bin/env bash

# MOZ_ENABLE_WAYLAND=1
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
fi
