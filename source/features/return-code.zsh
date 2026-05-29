#!/usr/bin/env zsh

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

# spell:ignore spipe signl cancl noerr
# spell:ignoreRegExp /[pn]{1,2}max/g

