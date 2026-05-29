#!/usr/bin/env zsh

typeset __pwd__="${0:a:h}"

# ——————————————————————————————————————————————————————————————————————————— #

precmd_functions+=( prompt::main )
typeset -xa precmd_functions=( "${(@u)precmd_functions}" )

export _PROMPT_OPTS_FILE="${__pwd__:h}/context/config"

# ——————————————————————————————————————————————————————————————————————————— #

source "$__pwd__/settings/settings.zsh"

source "$__pwd__/features/git.zsh"
source "$__pwd__/features/return-code.zsh"
source "$__pwd__/features/jobs.zsh"

source "$__pwd__/main/default-prompt.zsh"

# ——————————————————————————————————————————————————————————————————————————— #

prompt % &>/dev/null
prompt::set all

# ——————————————————————————————————————————————————————————————————————————— #

unset __pwd__ &>/dev/null
