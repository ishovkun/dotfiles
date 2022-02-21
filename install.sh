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
