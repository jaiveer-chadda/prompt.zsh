#!/usr/bin/env zsh

# ——————————————————————————————————————————————————————————————————————————— #
# ── ── Environment ── ────────────────────────────────────────────────────── #
# ——————————————————————————————————————————————————————————————————————————— #

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
# ── ── Return Code ── ────────────────────────────────────────────────────── #
# ——————————————————————————————————————————————————————————————————————————— #

function prompt::return_code() {

  # Reserved Return Codes
  # ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
  # │ VAR   │ col code / rgb  │ code  │ msg  │ Description                    │
  # ├───────┼─────────────────┼───────┼──────┼────────────────────────────────┤
  # │ RANGE │ 4 (137,180,250) │<=-1   │ code │ Exit status out of range       │
  # │ NOERR │ 8 (129,255,195) │  0    │      │ No Error                       │
  # │ ERROR │ 9 (255,126,160) │  1    │      │ Catchall for general errors    │
  # │ ERROR │ 9 (255,126,160) │  2    │ 2    │ Misuse of shell builtins       │
  # │ ERROR │ 9 (255,126,160) │  126  │ 126  │ Command invoked cannot execute │
  # │ ERROR │ 9 (255,126,160) │  127  │ ?    │ Command not found              │
  # │ ERROR │ 9 (255,126,160) │  128  │ #?   │ Invalid argument to exit       │
  # │ SIGNL │ 1 (250,179,135) │  128+ │ code │ Fatal error signal "n"         │
  # │ CANCL │ 6 (153,102,204) │  130  │      │ Script terminated by Control-C │
  # │ SIGNL │ 1 (250,179,135) │  146  │      │ Suspended job (bg)             │
  # │ RANGE │ 4 (137,180,250) │>=256  │ code │ Exit status out of range       │

  if (( ! do_pipes )) local -a ret_codes=( "${ret_codes[-1]:-0}" )

  local -ri 10 noerr=8 error=0 signl=1 cancl=6 range=4 pnmax=9 spipe=10
  local -ri 10 pmax=2147483647 nmax=-2147483648
  local -i  10 colour
  local -i  2  is_first_arrow=1
  local code msg prev_colour

  for code in "${(@)ret_codes}"; {
    msg=
    case "$code" {
      (    -1  ) colour=$range                           ;; #b)-1
      (     0  ) colour=$noerr                           ;; #g)0
      (     1  ) colour=$error                           ;; #r)1
      ( <-126> ) colour=$error; msg="$code"              ;; #r)2 -> 126
      (   127  ) colour=$error; msg='?'                  ;; #r)127
      (   128  ) colour=$error; msg='#?'                 ;; #r)128
      (   130  ) colour=$cancl                           ;; #i)130  SIGINT
      (   141  ) colour=$spipe                           ;; #v)141  SIGPIPE
      (   146  ) colour=$signl                           ;; #o)146  SIGTSTP
      ( <-161> ) colour=$signl; msg="$signals[code-127]" ;; #o)129 ~> 161
      ( <-255> ) colour=$signl; msg="$code"              ;; #o)162 -> 255
      ( $pmax  ) colour=$pnmax; msg='∞'                  ;; #w) 2147483647
      ( $nmax  ) colour=$pnmax; msg='-∞'                 ;; #w)-2147483648
      (   *    ) colour=$range; msg="$code"              ;; #b)-> -2, 256 ->
    }

    # add the opening arrow
    if (( do_condense && prev_colour == colour && ! is_first_arrow )) {
      prompt::colour                $black  $colour; PS1+="$thin_arrow"
    } else {
      prompt::colour ${prev_colour:-$black} $colour; PS1+="$arrow"
      is_first_arrow=0
    }

    # write out the main colour and message
    if (( _PROMPT_OPTS[verbose] )) {
      prompt::colour $black $colour
      PS1+="${msg:+ $msg }"  # if `$msg` isn't empty then pad it with spaces
    }

    if (( do_condense )) {
      prompt::colour $colour $colour
      prev_colour=$colour
    } else {
      prompt::colour $colour $black; PS1+="$arrow"  # add the closing arrow
    }
  }

  if (( do_condense )) { prompt::colour $colour $black; PS1+="$arrow"; }

}

# ——————————————————————————————————————————————————————————————————————————— #
# ── ── Git Extension ── ──────────────────────────────────────────────────── #
# ——————————————————————————————————————————————————————————————————————————— #

function prompt::git_extension() {

  # —— Const & Var Setup ———————————————————————————————————————————— #

  local -ri 10 black=-1 git_sep=-1        #¬( 17,  17,  30) ( 17,  17,  30)
  local -ri 10 tree_clean=8 tree_dirty=0  # (129, 255, 195), (255, 126, 160)

  local -r dflt_branch_icon=''  # \ue725
  local -r main_branch_icon='𝛍'  # \U1d6cd

  local -r separator=$'%{\e[2m%} /%b%B'

  # in a better language there would be a better data structure for these,
  #  but this is the best I can do while still keeping them in the right order
  local -A icons counts; local -a states
  #         ahead     behind    staged    modified  deleted   untracked
  states=(  ahead     behnd     stged     modif     delet     untrk     )
  icons=(  [ahead]=↑ [behnd]=↓ [stged]=+ [modif]=𝚫 [delet]=× [untrk]=\? )
  counts=( [ahead]=0 [behnd]=0 [stged]=0 [modif]=0 [delet]=0 [untrk]=0  )

  # ————————————————————————————————————————————————————————————————— #

  prompt::colour $prev_bg $git_sep; PS1+="$arrow"

  # —— Get States' Counts ——————————————————————————————————————————— #

  local -r NL=$'\n' HT=$'\t'
  local -r git_status="$NL$( git status --porcelain )"
  local -ri 10 status_len=$#git_status

  # count how many lines of `$git_status` start with the pattern after `$NL`
  counts[stged]=$(( ( status_len - ${#git_status//${NL}[MARD]} ) / 2 ))
  counts[delet]=$(( ( status_len - ${#git_status//$NL D}       ) / 3 ))
  counts[modif]=$(( ( status_len - ${#git_status//$NL M}       ) / 3 ))
  counts[untrk]=$(( ( status_len - ${#git_status//$NL'??'}     ) / 3 ))

  # find how many commits ahead/behind of the remote we are
  #  if the repo doesn't have a remote, `$ahead/behind[count]` will remain 0
  local r_count  # remote count
  r_count="$( git rev-list --left-right --count HEAD...@{u} 2>/dev/null )" && {
    counts[ahead]="${r_count%$HT*}"
    counts[behnd]="${r_count#*$HT}"
  }

  # —— Format Output ———————————————————————————————————————————————— #

  local -i 10 remote_changes local_changes
  remote_changes=$(( counts[ahead] + counts[behnd] + counts[stged] ))
  local_changes=$((  counts[modif] + counts[delet] + counts[untrk] ))

  local -ri 10 any_changes=$(( remote_changes +  local_changes ))
  local -ri 2 do_separator=$(( remote_changes && local_changes ))

  local -ri 10 bg_colour=$(( any_changes ? tree_dirty : tree_clean ))

  prompt::colour $git_sep $bg_colour; PS1+="$arrow "
  prompt::colour $black   $bg_colour

  # if the current branch doesn't have a name,
  #  use the branch's hex code instead
  local -r branch_name="$(
    git symbolic-ref --short HEAD 2>/dev/null || \
    git rev-parse    --short HEAD 2>/dev/null
  )"

  # if we're on the main/master branch, use the pre-defined symbol (`𝛍`)
  if [[ "$branch_name" == [Mm]a(in|ster) && "$do_git_branch" -ne 1 ]] {
    PS1+="$main_branch_icon"

  } else {
    PS1+="$dflt_branch_icon $branch_name"
    # if the full branch name is being shown, and there are still more changes
    #  to be added, then add a separator
    if (( any_changes )) PS1+="$separator"
  }

  # get each state and add its count and icon to the end of the prompt
  local state icon count
  for state in "${(@)states}"; {
    icon="$icons[$state]" count="$counts[$state]"
    if (( count )) PS1+=" $count$icon"
    if [[ $icon == "$icons[stged]" && $do_separator -eq 1 ]] PS1+="$separator"
  }

  PS1+=' '
  prompt::colour $bg_colour $black
}

# ——————————————————————————————————————————————————————————————————————————— #
# ── ── Prompt Settings ── ────────────────────────────────────────────────── #
# ——————————————————————————————————————————————————————————————————————————— #

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

    ( * ) prompt::main ;|
    ( % | raw | -[er] ) echo -nE - "${(%)PS1}" ;;
    (   | do  | show  ) echo -E  - "$PS1"      ;;

    ( * ) return 1 ;;
  }

  return $?
}

# —— Set / Unset Settings ——————————————————————————————————————————————————— #

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

# —— Initialise Settings ———————————————————————————————————————————————————— #

prompt % &>/dev/null
prompt::set all

# ───────────────────────────── ── ── END ── ── ───────────────────────────── #

# spell:ignore behnd cancl mard modif noerr signl stged untrk ense anch spipe
# spell:ignoreRegExp /\bd(elet|flt)\b|\b[np]{1,2}max\b/g
