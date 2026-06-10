#!/usr/bin/env zsh

function prompt::get_path () {
  local -rA dir_icons=(
    'Desktop'        ''  # \uf4a9
    'Documents'      ''  # \uf016
    'Downloads'      ''  # \uf409
    'CS'             ' ' # \uf121
    'y_settings_etc' ''  # \uf013
    '.config'       '.'  # \uf013
    'Shellscript'    ''  # \ue691
    'zsh'            ''  # \uf489
  )

  path_arr=( "${(@s:/:)PWD/#$HOME/~}" )
  if [[ -z "$path_arr[1]" ]] path_arr[1]='/'  # if we're not in `~/**`
  path_arr=( "${(@)path_arr:#}" )  # remove all empty elements

  # —— Get & Format $PWD ———————————————————————————————————————————— #

  local -i 10 i path_len=$#path_arr
  local dir_name icon

  for i in {1..$path_len}; {
    dir_name="$path_arr[i]"
    icon="$dir_icons[$dir_name]"

    if (( do_short && i != path_len )) {
      path_arr[i]="${icon:-$dir_name}"
    } else {
      path_arr[i]="${icon:+$icon }$dir_name"
    }
  }
}
