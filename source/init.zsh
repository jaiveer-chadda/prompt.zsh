#!/usr/bin/env zsh

typeset __pwd__="${0:a:h}"

# ——————————————————————————————————————————————————————————————————————————— #

autoload -Uz add-zsh-hook

# make sure that the `iterm2_precmd` function always comes after `prompt::main`
add-zsh-hook -d precmd prompt::main
add-zsh-hook -d precmd iterm2_precmd

add-zsh-hook    precmd prompt::main
add-zsh-hook    precmd iterm2_precmd

# ——————————————————————————————————————————————————————————————————————————— #

export _PROMPT_OPTS_FILE="${__pwd__:h}/context/config"

# ——————————————————————————————————————————————————————————————————————————— #

source "$__pwd__/settings/settings.zsh"

source "$__pwd__/features/git.zsh"
source "$__pwd__/features/return-code.zsh"
source "$__pwd__/features/jobs.zsh"
source "$__pwd__/features/shlvl.zsh"

source "$__pwd__/main/default-prompt.zsh"
source "$__pwd__/main/main.zsh"

# ——————————————————————————————————————————————————————————————————————————— #

prompt % &>/dev/null
prompt::set all

# ——————————————————————————————————————————————————————————————————————————— #

unset __pwd__ &>/dev/null
