#!/usr/bin/env zsh

# ——————————————————————————————————————————————————————————————————————————— #
# ── ── Environment ── ────────────────────────────────────────────────────── #
# ——————————————————————————————————————————————————————————————————————————— #

source "${0:h}/features/git.zsh"
source "${0:h}/features/return-code.zsh"
source "${0:h}/settings/settings.zsh"

precmd_functions+=( prompt::main )
typeset -xa precmd_functions=( "${(@u)precmd_functions}" )

export _PROMPT_OPTS_FILE="$CONTEXT_FLAGS/prompt"

function prompt::colour() {
  if (( $1 == -1 )) { PS1+='%B%F{#11111E}'; } else { PS1+="%$colours[$1+1]F"; }
  if (( $2 == -1 )) { PS1+='%k'           ; } else { PS1+="%$colours[$2+1]K"; }
}

# ——————————————————————————————————————————————————————————————————————————— #
# ── ── Main Function ── ──────────────────────────────────────────────────── #
# ——————————————————————————————————————————————————————————————————————————— #

function prompt::main() {
  local -a ret_codes=( "${(@)pipestatus:-$?}" )

  setopt local_options local_traps warn_create_global warn_nested_var

  # make sure that the prompt doesn't leak colours anywhere
  trap "PS1+='%k%f%u%s%b%(!:#:$) '" INT TERM QUIT

  export {PS1,PROMPT,prompt}='%b'

  # —— Set Constants ———————————————————————————————————————————————— #

  local -r      arrow='' # \ue0b0
  local -r thin_arrow='' # \ue0b1

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

  local -ri 10 black=-1
  local -ri 10 trunc_len=-1  # this is just temp for now

  local -rA dir_icons=(
    'Desktop'        ''  # \uf4a9
    'Documents'      ''  # \uf016
    'Downloads'      ''  # \uf409
    'CS'             ' ' # \uf121
    'y_settings_etc' ''  # \uf013
    '.config'       '.'  # \uf013
    'zsh'            ''  # \uf489
  )

  # —— Parse Options ———————————————————————————————————————————————— #

  local -i 2 do_{condense,pipes,short,tiny,git{,_branch}}=0

  if ! (( _PROMPT_OPTS[override] )) {
    do_pipes=$(( _PROMPT_OPTS[pipes] && ${#${ret_codes//[ 0]}} ))

    do_short=$(( COLUMNS <= 106 || _PROMPT_OPTS[short] ))
    do_tiny=$((  COLUMNS <= 80  || $#PWD > 90          ))

    do_git_branch=${_PROMPT_OPTS[git-branch]}
    do_condense=${_PROMPT_OPTS[condense]}
    do_git=${_PROMPT_OPTS[git]}
  }

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
  local -a path_arr=( "${(s:/:)adjusted_pwd}" )

  # The array splitting will have got rid of the PWD's leading `/`
  #  Which will only matter if we're not in a subdir of ~
  #  If we're not, then we can tell bc the 1st elem of path_arr will be empty
  if [[ -z "$path_arr[1]" ]] path_arr=( '/' "${(@)path_arr:#}" )
  # But if it isn't empty, then:
  #  =( '/'             ) : add the leading `/` back
  #  =(          ...:#} ) : remove any empty elements from the array

  local -ri 10 path_length=$#path_arr

  # —— return_code() ———————————————————————————————————————————————— #

  prompt::return_code

  # —— Loop & Colour Paths —————————————————————————————————————————— #

  local -i 10 i {curr_,prev_}bg=$black
  local path_segment
  # Iterate through the path array, and colour each segment accordingly
  for i in {1..$path_length}; {
    #r)FIXME: this is rly awful, cos for a "tiny" prompt, I'm still looping
    #r)  through every segment to figure out what colour this segment should be
    if (( do_tiny )) {
      if (( i != path_length )) continue
      prev_bg="$black"
    }

    curr_bg=$(( ( i - 1 ) % 7 ))

    # replace any colons in the directory name with slashes
    path_segment="${path_arr[i]//://}"

    # Shorten every directory name except the current one
    if (( do_short && i != path_length )) {
      path_segment="$path_segment[1,$trunc_len]"
    }
    # ↓ Colour and draw the arrow
    prompt::colour $prev_bg $curr_bg; PS1+="$arrow"
    prompt::colour $black   $curr_bg; PS1+=" $path_segment "
    # ↑ Colour and print the path segment's name

    # set the current bg to the previous one
    prev_bg="$curr_bg"
  }

  # —— git_extension() —————————————————————————————————————————————— #

  # Now get the git segment (if it exists)
  # IF in a git repo, AND not in the `.git` dir (if `.git` isn't in `$PWD`)
  #  then run the git extension
  if git rev-parse --is-inside-work-tree &>/dev/null \
    && (( do_git && ! path_arr[(Ie).git] )) {
    prompt::git_extension

  } else {
    # otherwise just colour the last arrow
    prompt::colour $prev_bg $black
  }

  PS1+="$arrow"

  # —— Cleanup —————————————————————————————————————————————————————— #

  trap - INT TERM QUIT
  # Finally, print a final reset sequence, and a traling space, then export it
  export {PS1,PROMPT,prompt}="$PS1%k%f%u%s%b "
}

# ——————————————————————————————————————————————————————————————————————————— #
# —— —— Initialise Settings —— —————————————————————————————————————————————— #
# ——————————————————————————————————————————————————————————————————————————— #

prompt % &>/dev/null
prompt::set all

# ───────────────────────────── ── ── END ── ── ───────────────────────────── #
