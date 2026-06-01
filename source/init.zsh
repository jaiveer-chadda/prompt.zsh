#!/usr/bin/env zsh

function prompt::init () {

  local -r source_dir="${${(%):-%x}:a:h}"
  export _PROMPT_OPTS_FILE="${source_dir:h}/context/config"

  local file; for file in "$source_dir"/*/**/*.zsh; source "$file"

  # ———————————————————————————————————————————————————————————————————————— #

  autoload -Uz add-zsh-hook

  # make sure that `iterm2_precmd` always comes after `prompt::main`
  add-zsh-hook -d precmd prompt::main
  add-zsh-hook -d precmd iterm2_precmd

  add-zsh-hook    precmd prompt::main
  add-zsh-hook    precmd iterm2_precmd

  # ———————————————————————————————————————————————————————————————————————— #

  prompt % &>/dev/null
  prompt::set all

} # ———————————————————————————————————————————————————————————————————————— #

prompt::init "$@"
