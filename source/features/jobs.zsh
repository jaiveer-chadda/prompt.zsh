#!/usr/bin/env zsh

function prompt::jobs() {
  if ! (( $#jobstates )) return 0

  local -ri 10 job_count=$#jobstates
  local -ri 10 job_colour=10

  prompt::colour $prev_bg $black      ; PS1+="$arrow"  # end previous segments
  prompt::colour $black   $job_colour ; PS1+="$arrow"  # start new segment

  case $#jobstates {
    ( 1 ) : ;;  # if there's only one job, just show an empty pink arrow
    ( 2 )       # if there are two jobs, show two arrows
      prompt::colour $job_colour $black; PS1+="$arrow"
      prompt::colour $black $job_colour; PS1+="$arrow"
    ;;
    # and if there's any more than 2, display the number in the pink arrow
    ( * ) PS1+=" $#jobstates " ;;
  }

  # make sure any subsequent commands know which colour to use
  prev_bg=$job_colour
}
