#!/usr/bin/env zsh

function prompt::bash() {
  local -r dim=$'%{\e[2m%}'

  local -ra colours=( 9 216 11 10 14 12 13 )
  local -ri 10 noerr=105 error=211 signl=216 cancl=134 range=111 spipe=183

  # ———————————————————————————————————————————————— #

  local -r  formatted_path="${PWD/#$HOME/~}"
  local -ra path_array=( "${(@s:/:)formatted_path}" )

  # ———————————————————————————————————————————————— #

  local -ri 10 retcode=$ret_codes[-1]

  local -i 10 err_col
  local msg

  case "$retcode" {
    (    -1  ) err_col=$range msg='-1'                    ;; #b)-1
    (     0  ) err_col=$noerr                             ;; #i)0
    (     1  ) err_col=$error                             ;; #r)1
    ( <-126> ) err_col=$error msg="$retcode"              ;; #r)2 -> 126
    (   127  ) err_col=$error msg='?'                     ;; #r)127
    (   128  ) err_col=$error msg='#?'                    ;; #r)128
    (   130  ) err_col=$cancl msg='INT'                   ;; #i)130  SIGINT
    (   141  ) err_col=$spipe msg='PIPE'                  ;; #v)141  SIGPIPE
    (   146  ) err_col=$signl msg='⏸'                     ;; #o)146  SIGTSTP
    ( <-161> ) err_col=$signl msg="$signals[retcode-127]" ;; #o)129 ~> 161
    ( <-255> ) err_col=$signl msg="$retcode"              ;; #o)162 -> 255
    (   *    ) err_col=$range msg="$retcode"              ;; #b)-> -2, 256 ->
  }

  # ———————————————————————————————————————————————— #

  local -i 10 i colour_num
  for i in {1..$#path_array}; {
    colour_num=$(( colours[ ( ( i - 1 ) % $#colours ) + 1 ] ))

    PS1+="%${colour_num}F${path_array[i]//://}"
    if (( i != $#path_array )) PS1+="$dim/%b"
  }

  # ———————————————————————————————————————————————— #

  PS1+="%${err_col}F "

  if (( $#msg )) PS1+="${dim}[%b$msg$dim]%b "

  PS1+='$%f '
}

# ——————————————————————————————————————————————————————————————————————————— #

# function _set_ps1 () {
#   local -ra colours=( 1 3 2 6 4 5 )
#   local -r formatted_path="${PWD/#$HOME/\~}"
#   local -a path_array=()
#
#   IFS='/' read -ra path_array <<< "$formatted_path"
#
#   local -i i colour_num
#   local colour_esc path_segment output
#
#   for i in "${!path_array[@]}"; do
#     colour_num="${colours[ i % ${#colours[@]} ]}"
#     colour_esc=$'\[\e[9'"${colour_num}m\]"
#
#     path_segment="${path_array[i]}"
#
#     output+="$colour_esc$path_segment"
#     # print a slash after every segment except the last
#     (( i != ${#path_array[@]} - 1 )) && output+=$'\[\e[2m\]/\[\e[22m\]'
#     output+=$'\[\e[m\]'
#   done
#
#   output+=$'\[\e[38;5;105m\] $\[\e[m\] '
#   export PS1="$output"
# }

# ——————————————————————————————————————————————————————————————————————————— #

# spell:ignore spipe signl cancl noerr
