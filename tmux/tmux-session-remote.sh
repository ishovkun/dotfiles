#!/bin/sh

SESSION='  rem'
echo $SESSION
SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

# Only create tmux session if it doesn't already exist
if [ "$SESSIONEXISTS" = "" ]
then
    tmux new-session -d -s $SESSION
    echo $SESSION

    tmux rename-window -t 1 ' '
    tmux send-keys -t ' ' "cd ~/dev/;clear" C-m

    tmux new-window -t $SESSION:2 -n " "
    tmux send-keys -t 2 "emacs -nw" C-m

    tmux new-window -t $SESSION:3 -n ' '
    tmux send-keys -t ' ' "vifm" C-m

    tmux new-window -t $SESSION:3 -n ' '
    tmux send-keys -t ' ' "cd ~/sim; clear;" C-m
fi

tmux attach-session -t $SESSION:1
