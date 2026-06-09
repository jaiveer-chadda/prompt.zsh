#!/usr/bin/env zsh

function prompt::jobs() {
  if ! (( $#jobstates && do_jobs )) return 0

  local -ri 10 job_count=$#jobstates
  local -ri 10 job_colour=10

  prompt::colour $black $job_colour; PS1+="$arrow"  # start segment

  case $job_count {
    ( 1 ) : ;;  # if there's only one job, just show an empty pink arrow
    ( 2 )       # if there are two jobs, show two arrows
      prompt::colour $job_colour $black; PS1+="$arrow"
      prompt::colour $black $job_colour; PS1+="$arrow"
    ;;
    # and if there's any more than 2, display the number in the pink arrow
    ( * ) PS1+=" $job_count " ;;
  }

  prompt::colour $job_colour $black; PS1+="$arrow"  # end segment
}
