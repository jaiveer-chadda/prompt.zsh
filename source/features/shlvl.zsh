#!/usr/bin/env zsh

function prompt::shlvl() {
  if (( SHLVL <= 1 || ! do_shlvl )) return 0
  local -ri 10 shlvl_colour=4

  prompt::colour $black $shlvl_colour; PS1+="$arrow"  # start segment
  if (( SHLVL > 2 )) PS1+=" $SHLVL "  # add a number if SHLVL >= 3
  prompt::colour $shlvl_colour $black; PS1+="$arrow"  # close segment
}
