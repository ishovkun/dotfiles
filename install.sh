#!/usr/bin/env bash

# build directory
mkdir -p $HOME/build
# install zgen minimalist plugin manager for zsh
if [ ! -d "${HOME}/.zgen" ]
then
    git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
fi
# tmux resurrect
if [ ! -d "${HOME}/build/tmux-resurrect" ]
then
    git clone https://github.com/tmux-plugins/tmux-resurrect "${HOME}/build/tmux-resurrect"
fi

# enable 24bit colors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
/usr/bin/tic -x -o ~/.terminfo ${SCRIPT_DIR}/misc/xterm-24bit.terminfo
