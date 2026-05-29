#!/usr/bin/env zsh

function prompt::set prompt::unset () {
  local -r mode="${0##*::}"
  if [[ "$mode $1" == 'set all' ]] { source "$_PROMPT_OPTS_FILE"; return; }

  if [[ "$mode" == unset ]] {
    unset "_PROMPT_OPTS[$1]" &>/dev/null
  } else {
    _PROMPT_OPTS[$1]=$(( invert ? ! $2 : $2 ))
  }
  typeset -p 1 _PROMPT_OPTS > "$_PROMPT_OPTS_FILE"
}

function prompt() {
  local -r pos="+|1|yes|on|true|"
  local -r neg="-|0|no|off|false"

  local -i 2 invert=0
  if [[ "$1" == no(t|) ]] { invert=1; shift; }

  case "$1" {
    ( opts | -l ) 
      echoAA _PROMPT_OPTS 2>/dev/null || typeset -p 1 _PROMPT_OPTS ;;

    ( refresh ) prompt::set all ;;

    ( debug | override )
      case "$2" {
        ( $~pos ) prompt::set override 1 ;;
        ( $~neg ) prompt::set override 0 ;;
        (   *   ) return 1               ;;
      } ;;

    ( git )
      case "$2" {
        ( $~pos ) prompt::set git 1 ;;
        ( $~neg ) prompt::set git 0 ;;
        ( br(anch|) )
          if [[ "$3" == 'name' ]] shift
          case "$3" {
            (  | on ) prompt::set git-branch 1 ;;
            ( abbr* ) prompt::set git-branch 0 ;;
            (   *   ) return 1                 ;;
          } ;;
        ( * ) return 1 ;;
      } ;;

    ( short ) prompt::set short 1 ;;
    ( long  ) prompt::set short 0 ;;

    ( verb(ose|) )
      case "$2" {
        ( $~pos ) prompt::set verbose 1 ;;
        ( $~neg ) prompt::set verbose 0 ;;
        (   *   ) return 1              ;;
      } ;;

    ( pipe(s|) )
      case "$2" {
        ( $~pos ) prompt::set pipes 1 ;;
        ( $~neg ) prompt::set pipes 0 ;;
        ( cond* )
          case "$3" {
            ( $~pos ) prompt::set condense 1 ;;
            ( $~neg ) prompt::set condense 0 ;;
            (   *   ) return 1               ;;
          } ;;
        ( * ) return 1 ;;
      } ;;

    ( cond(ense|) )
      case "$2" {
        ( $~pos ) prompt::set condense 1 ;;
        ( $~neg ) prompt::set condense 0 ;;
        (   *   ) return 1               ;;
      } ;;

    ( jobs )
      case "$2" {
        ( $~pos ) prompt::set jobs 1 ;;
        ( $~neg ) prompt::set jobs 0 ;;
        (   *   ) return 1           ;;
      } ;;

    ( * ) prompt::main ;|
    ( % | raw | -[er] ) echo -nE - "${(%)PS1}" ;;
    (   | do  | show  ) echo -E  - "$PS1"      ;;

    ( * ) return 1 ;;
  }

  return $?
}

# spell:ignoreRegExp /\([\w|]+\)/g
