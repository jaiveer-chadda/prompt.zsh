#!/usr/bin/env zsh

#############################################
# prompt::get_path                          #
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾                          #
# Parses `$PWD`, converts it into an array, #
#  and makes any necessary substitutions    #
#                                           #
# Globals: sets `path_arr`                  #
#############################################
function prompt::get_path () {
  local -rA dir_icons=(
    # General                 # Desktop
    'bash'          ''       'cs'                  ' '
    'man'           '󰺄'       'labour'              '󰧲'
    'shared'        '󱒃'       'screenshots'         '󰄀'
    'temp'          '󰔛'       'university work'     ' '
    'vscode'        ''
    'zsh'           ''

    # General Dev             # CS
    '.git'          '󰊢'       'applescript'         ''
    '.idea'         ''       'c'                   ''
    '.vscode'       ''       'c#'                  ''
    'archive'       ''       'discord'             ' '
    'archives'      ''       'java'                ''
    'backup'        '󰁯'       'karabiner'           ''
    'backups'       '󰁯'       'man pages'           '󰺄'
    'build'         ''       'python'              ''
    'export'        ''       'raycast'             ''
    'out'           ''       'rust'                ''
    'output'        ''       'shellscript'         ''
    'resources'     '󱂸'       'swift'               ''
    'source'        '󰴉'       'vs_code'             ''
    'test'          '󰙨'       'web'                 '󰖟'
    'tests'         '󰙨'       'x_Automation'        '󰚩'
    '#'             ''        'y_settings_etc'      ''
    '#'             ''        'z_other'             '󱝏'

    # Root (/)                # Documents
    'applications'  ''       'apps'                ''
    'bin'           ''       'audio'               ''
    'dev'           '󰾰'       'backups:archives'    '󱝏'
    'fd'            '󰮗'       'images'              ''
    'private'       ' '      'videos'              '󰨜'
    'sbin'         's'
    'system'        '󰡀 '      # Specific Dirs
    'tmp'           '󰔛'       'com~apple~clouddocs' ' '
    'users'         ' '      'homebrew'            '󱄖'
    'volumes'       ''

    # Home (~)
    '.config'      '.'
    '.local'        ''
    '.trash'        ''
    'desktop'       ''
    'documents'     ''
    'downloads'     ''
    'library'       ''
    'movies'        '󰿎'
    'music'         ''
    'pictures'      ''
    'public'        '󰛍'
  )

  # split $PWD at every slash
  path_arr=( "${(@s:/:)PWD}" )

  # TODO: make this work for home dirs that aren't subdirs of `/Users`

  # if we're in a subdir of `/Users/$USER`, replace it with `~`
  if [[ "$PWD" == "$HOME"* ]] {
    shift 2 path_arr
    path_arr[1]='~'

  # if we're in the home folder of another user (i.e. any subdir of `/Users`
  #  that isn't `/Users/Shared`), then replace it with `~$USER`
  } elif [[ "$PWD" == '/Users/'(^Shared) ]] {
    shift 2 path_arr
    path_arr[1]="~${PWD:t}"
  }

  if [[ -z "$path_arr[1]" ]] path_arr[1]='/'  # if we're not in `~/**`
  path_arr=( "${(@)path_arr:#}" )  # remove all empty elements

  # —— Get & Format $PWD ———————————————————————————————————————————— #

  local -i 10 i path_len=$#path_arr
  local dir_name icon

  for i in {1..$path_len}; {
    dir_name="$path_arr[i]"
    icon="$dir_icons[$dir_name:l]"

    if (( do_short && i != path_len )) {
      path_arr[i]="${icon:-$dir_name}"
    } else {
      path_arr[i]="${icon:+$icon }$dir_name"
    }
  }
}
