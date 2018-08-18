SEGMENT_SEPARATOR=""
# SEGMENT_SEPARATOR=$'\ue0b0'
local ret_status="%(?:%{$fg[cyan]%}$SEGMENT_SEPARATOR:%{$fg[red]%}$SEGMENT_SEPARATOR)"
local dir_info="%(?:%{$bg[cyan]%}%{$fg[black]%} %c :%{$bg[red]$fg[black]%} %c )"

PROMPT='${dir_info}%{$reset_color%}${ret_status}%{$reset_color%} $(git_prompt_info)'
RPROMPT='%{$fg[green]%}%*%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
ZLE_RPROMPT_INDENT=1
