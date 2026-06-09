#!/usr/bin/env zsh

function prompt::default() {

  # —— Set Constants ———————————————————————————————————————————————— #

  local -r      arrow='' # \ue0b0
  local -r thin_arrow='' # \ue0b1

  local -ri 10 black=-1
  local -ra colours=(
    '211'  #  0 : ( 243, 139, 168 )
    '216'  #  1 : ( 250, 179, 135 )
    '222'  #  2 : ( 249, 226, 175 )
    '114'  #  3 : ( 166, 227, 161 )
    '111'  #  4 : ( 137, 180, 250 )
    '105'  #  5 : ( 151, 140, 247 )
    '134'  #  6 : ( 153, 102, 204 )

    '34'   #  7 : (  64, 160,  43 )
    '85'   #  8 : ( 129, 255, 195 )

    '189'  #  9 : ( 224, 231, 255 )
    '183'  # 10 : ( 203, 166, 247 )
  )

  # —— Parse Options ———————————————————————————————————————————————— #

  local -i 2 do_{condense,pipes,short,tiny,git{,_branch}}=0

  if ! (( _PROMPT_OPTS[override] )) {
    do_pipes=$(( _PROMPT_OPTS[pipes] && ${#${ret_codes//[ 0]}} ))

    do_short=$(( COLUMNS <= 106 || _PROMPT_OPTS[short] ))
    do_tiny=$((  COLUMNS <= 80  || $#PWD > 90          ))

    do_git_branch=${_PROMPT_OPTS[git-branch]}
    do_condense=${_PROMPT_OPTS[condense]}
    do_shlvl=${_PROMPT_OPTS[shlvl]}
    do_jobs=${_PROMPT_OPTS[jobs]}
    do_git=${_PROMPT_OPTS[git]}
  }

  # —— Get & Format $PWD ———————————————————————————————————————————— #

  local -a path_arr
  prompt::get_path

  # —— Add Features ————————————————————————————————————————————————— #

  local -i 10 i {curr,prev}_bg=$black

  prompt::shlvl
  prompt::return_code
  prompt::path
  prompt::jobs
  prompt::git_extension

  # —— Cleanup —————————————————————————————————————————————————————— #

  # Finally, print a final reset sequence and a trailing space
  PS1+='%k%f%b '
}

# —— prompt::colour() ——————————————————————————————————————————————————————— #

function prompt::colour() {
  if (( $1 == -1 )) { PS1+='%B%F{#06060F}'; } else { PS1+="%$colours[$1+1]F"; }
  if (( $2 == -1 )) { PS1+='%k'           ; } else { PS1+="%$colours[$2+1]K"; }
}
