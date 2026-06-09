#!/usr/bin/env zsh

function prompt::tiny() {
  # if `$? == 0/1`, don't do anything. otherwise, dispay the error code in red
  PS1+='%(?::%1(?::%1F%?%f ))'

  # if there was an error, colour the following char red
  #  otherwise, if we're in `sudo` mode, colour the following char blue
  #  if we're in normal mode, colour it indigo
  PS1+='%(?:%(!:%4F:%105F):%1F)'

  # if we're in `sudo` mode, display a `#`, otherwise, display `$`
  PS1+='%(!:#:$)'

  # reset the colouring and add a trailing space
  PS1+='%f '
}
