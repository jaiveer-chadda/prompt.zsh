#!/usr/bin/env zsh

function prompt::git_extension() {

  # Quit the git extension if:
  #  - not in a git repo, or
  #  - in the `.git` dir (if `.git` is in `$PWD`)
  #  - its been disabled in settings
  if ! git rev-parse --is-inside-work-tree &>/dev/null \
    || (( ! do_git || path_arr[(Ie).git] )) return 0

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
  prompt::colour $bg_colour $black; PS1+="$arrow"
}

# spell:ignore untrk modif stged behnd delet mard
