# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# do not do fancy terminal prompts while connecting through tramp
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# oh-my-zsh variables
# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"
# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"
# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="false"

# zgen
# install: git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
source "${HOME}/.zgen/zgen.zsh"
if ! zgen saved; then
  zgen oh-my-zsh
  # specify plugins here
  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/sudo
  zgen oh-my-zsh plugins/z
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-completions src
  zgen load zsh-users/zsh-autosuggestions
  zgen load cal2195/q
  zgen load Aloxaf/fzf-tab
  # theme
  # zgen oh-my-zsh themes/arrow
  zgen load $HOME/dotfiles/zsh/ishovkun.zsh-theme
  # generate the init script from plugins above
  zgen save
  ### NOTE: after update, run: zgen reset; source ~/.zshrc
fi

# User configuration
local ret_status="%(?:%{$fg_bold[green]%}❯ :%{$fg_bold[red]%}❯ )"

# nnn config
n ()
{
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi
    # so that I can cd on quit
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # bookmarks
    export NNN_BMS='D:~/Downloads;h:~/;b:~/build;d:~/dev;s:~/sim'
    # colors
    export NNN_COLORS="2136"
    # required for previews
    export NNN_FIFO=/tmp/nnn.fifo
    # plugins
    export NNN_PLUG='f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview'
    # run
    nnn "$@"
    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

nnn-navigate () {
  n < /dev/tty;
  zle reset-prompt
}

zle -N nnn-navigate
bindkey '\ee' nnn-navigate

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
export EDITOR='vim'

# aliases
alias gmsh="~/build/gmsh/bin/gmsh"
alias ssh="TERM=xterm-256color ssh"
alias msh2="~/dev/msh2gprs/build/msh2gprs"
alias doom="~/.emacs.d/bin/doom"

PYTHONPATH="${PYTHONPATH}:/home/ishovkun/dev"
PYTHONPATH="${PYTHONPATH}:/$HOME/build/python"
export PYTHONPATH

# color gcc output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--color=light,fg:15,bg:0,bg+:10,info:2"

# disable ctrl-s
stty -ixon

# trueccolor
export TERM=xterm-24bit


if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
fi


export PARDISO_LIC_PATH="$HOME/lic/pardiso.lic"
export SSH_ASKPASS='/usr/bin/ksshaskpass'
