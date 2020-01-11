set -g prefix F12
unbind-key -n C-a

# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
# is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    # | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
# bind-key -n M-h if-shell "$is_vim" "send-keys M-h"  "select-pane -L"
# bind-key -n M-j if-shell "$is_vim" "send-keys M-j"  "select-pane -D"
# bind-key -n M-k if-shell "$is_vim" "send-keys M-k"  "select-pane -U"
# bind-key -n M-l if-shell "$is_vim" "send-keys M-l"  "select-pane -R"
# bind-key -n M-\ if-shell "$is_vim" "send-keys M-\\" "select-pane -l"
# bind -n M-h run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)n?vim(diff)?$|emacs.*$' && tmux send-keys C-h) || tmux select-pane -L"
# bind -n M-j run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)n?vim(diff)?$|emacs.*$' && tmux send-keys C-j) || tmux select-pane -D"
# bind -n M-k run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)n?vim(diff)?$|emacs.*$' && tmux send-keys C-k) || tmux select-pane -U"
# bind -n M-l run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)n?vim(diff)?$|emacs.*$' && tmux send-keys C-l) || tmux select-pane -R"
# bind -n M-h run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim(diff)?$|emacs.*$' && tmux send-keys C-h) || tmux select-pane -L"
# bind -n M-j run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim(diff)?$|emacs.*$' && tmux send-keys C-j) || tmux select-pane -D"
# bind -n M-k run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim(diff)?$|emacs.*$' && tmux send-keys C-k) || tmux select-pane -U"
# bind -n M-l run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim(diff)?$|emacs.*$' && tmux send-keys C-l) || tmux select-pane -R"
# go to a specific window
bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5
bind-key -n M-6 select-window -t 6
# resize split
# bind-key -n M-S-Right resize-pane -L

bind-key -n M-S-Up resize-pane -U 15
bind-key -n M-S-Down resize-pane -D 15
bind-key -n M-S-Left resize-pane -L 25
bind-key -n M-S-Right resize-pane -R 25
unbind-key -n C-F9
