#!/usr/bin/env zsh

function prompt::get_path () {
  local -rA dir_icons=(
    'Desktop'        ''  # \uf4a9
    'Documents'      ''  # \uf016
    'Downloads'      ''  # \uf409
    'CS'             ' ' # \uf121
    'y_settings_etc' ''  # \uf013
    '.config'       '.'  # \uf013
    'Shellscript'    ''  # \uf489
    'zsh'            ''  # \uf489
  )

  # —— Get & Format $PWD ———————————————————————————————————————————— #

  # Get `$PWD`, and replace `/Users/$USER` with `~`
  local -r basic_pwd="${PWD/#$HOME/~}"
  local adjusted_pwd="$basic_pwd"

  local dir_name icon
  # Add icons to several common folders
  for dir_name icon in "${(@kv)dir_icons}"; {
    # I'm matching the leading and trailing slashes – `\/${~dir_name}\/`,
    #  and then re-adding them in the replacement – `/$icon.../`.
    # This is bc I don't want (e.g.) `CS` to match `/path/to/CS_folder/`,
    #  or `/path/to/some_CS_folder/`. It should only match `/path/to/CS/`
    if (( do_short )) {
      adjusted_pwd="${adjusted_pwd/\/$dir_name\///$icon/}"
    } else {
      adjusted_pwd="${adjusted_pwd/\/$dir_name\///$icon $dir_name/}"
    }
  }

  # —— Split $PWD into Array ———————————————————————————————————————— #

  # Split the array at every `/`
  path_arr=( "${(s:/:)adjusted_pwd}" )

  # The array splitting will have got rid of the PWD's leading `/`
  #  Which will only matter if we're not in a subdir of ~
  #  If we're not, then we can tell bc the 1st elem of path_arr will be empty
  if [[ -z "$path_arr[1]" ]] path_arr=( '/' "${(@)path_arr:#}" )
  # But if it isn't empty, then:
  # ...=( '/'       ) : add the leading `/` back
  # ...=(    ...:#} ) : remove any empty elements from the array
}
