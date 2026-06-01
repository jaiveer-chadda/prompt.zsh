#!/usr/bin/env zsh

function prompt::main() { #
  case "$_PROMPT_OPTS[mode]" {
    ( tiny ) prompt::tiny    ;;
    ( bash ) prompt::bash    ;;
    ( dark ) prompt::dark    ;;
    (  *   ) prompt::default ;;
  } 2>/dev/null || prompt::default
}
