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
# tmux disk space plugin
if [ ! -d "${HOME}/build/tmux-df" ]
then
    git clone https://github.com/tassaron/tmux-df "${HOME}/build/tmux-df"
fi
# vim plugin manager
if [ ! -d "${HOME}/.vim/bundle/Vundle.vim" ]
then
    git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}/.vim/bundle/Vundle.vim"
    vim +PluginInstall +qall
fi

# enable 24bit colors
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [ ! -f "${HOME}/.terminfo" ]
then
   /usr/bin/tic -x -o ~/.terminfo ${SCRIPT_DIR}/misc/xterm-24bit.terminfo
fi
