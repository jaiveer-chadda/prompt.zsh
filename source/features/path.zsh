#!/usr/bin/env zsh

function prompt::path() {
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

  prompt::colour $prev_bg $black; PS1+="$arrow"
}
