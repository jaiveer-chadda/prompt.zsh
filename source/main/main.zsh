#!/usr/bin/env zsh

function prompt::main() {
  local -a ret_codes=( "${(@)pipestatus:-$?}" )

  setopt local_options warn_create_global

  export {PS1,PROMPT,prompt}='%b'

  case "$_PROMPT_OPTS[mode]" {
    ( tiny ) prompt::tiny    ;;
    ( bash ) prompt::bash    ;;
    ( dark ) prompt::dark    ;;
    (  *   ) prompt::default ;;
  } 2>/dev/null || prompt::default

  # Finally, export whatever prompt the specified function has made
  export {PS1,PROMPT,prompt}="$PS1"
}
