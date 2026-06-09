#!/usr/bin/env zsh

function prompt::bash() {
  local -r dim=$'%{\e[2m%}'

  local -r  formatted_path="${PWD/#$HOME/~}"
  local -ra path_array=( "${(@s:/:)formatted_path}" )
  local -ra colours=( 1 3 2 6 4 5 )

  local -ri 10 ret_code=$ret_codes[-1]
  local -ri 10 dollar_colour=$(( ret_code == 0 ? 105 : 1 ))
  if (( ret_code != 0 && ret_code != 1 )) PS1+="%1F[$ret_code] "

  local -i 10 i colour_num
  for i in {1..$#path_array}; {
    colour_num=$(( colours[ ( ( i - 1 ) % $#colours ) + 1 ] + 8 ))

    PS1+="%${colour_num}F${path_array[i]//://}"
    if (( i != $#path_array )) PS1+="$dim/%b"
  }

  PS1+=" %${dollar_colour}F$%f "
}

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
