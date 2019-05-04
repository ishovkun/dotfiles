#! /bin/sh

byobu new-session -d -s $USER

#compile window
byobu rename-window -t $USER:1 ' '

# sim window
byobu new-window -t $USER:2 -n ' '
byobu send-keys "cd ~/sim" C-m

byobu new-window -t $USER:3 -n ' '
byobu send-keys "vifm" C-m

byobu attach-session -t $USER
