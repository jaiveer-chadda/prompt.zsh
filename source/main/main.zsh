#!/usr/bin/env zsh

function prompt::main() {
  local -a ret_codes=( "${(@)pipestatus:-$?}" )

  case "$_PROMPT_OPTS[mode]" {
    ( tiny ) prompt::tiny    ;;
    ( bash ) prompt::bash    ;;
    ( dark ) prompt::dark    ;;
    (  *   ) prompt::default ;;
  } 2>/dev/null || prompt::default
}
