#!/bin/bash

# cirque du twerque-ify text. Default prints text in this format:
# Thanks for letting us know
# h
# a
# n
# k
# s
#
# f
# o
# r
#
# l
# e
# t
# t
# i
# n
# g
#
# u
# s
#
# k
# n
# o
# w
#
# If the --box flag is supplied, it prints it in a box-like format.
# If the --space flag is supplied, it prints the string with spaces between
# each character.

twerque () {
  local style=default
  if [ "$1" ]
  then
    case $1 in
      -b | --box)
        style=box
        ;;
      -s | --space)
        style=space
        ;;
      -t | --thanks)
        echo Thanks for letting me know | twerque
        return $?
        ;;
      -h | --help)
        echo "usage: twerque [[-b --box] [-s --space] [-t --thanks] [-h --help]]"
        return 0
        ;;
      *)
        (>&2 echo "invalid flag $1")
        return 1
        ;;
    esac
  fi
  # set IFS to empty so it doesn't strip out whitespace
  local IFS=''
  while read line
  do
    local i
    for (( i=0; i<${#line}; i++ ))
    do
      case $style in
        default)
          if [ $i -eq 0 ]
          then
            echo "$line"
          else
            echo "${line:$i:1}"
          fi
          ;;
        box)
          # echo the rotated string without spaces between
          echo "${line:$i}""${line:0:$i}"
          ;;
        space)
          local whitespace=' '
          if [ $i -eq $((${#line} - 1)) ]
          then
            whitespace=$'\n'
          fi
          printf "%c%c" "${line:$i:1}" "$whitespace"
      esac
    done
  done
}

_twerque () {
  local cur=${COMP_WORDS[COMP_CWORD]}
  if [ $COMP_CWORD -eq 1 ]
  then
    COMPREPLY=( $(compgen -W "-b --box -s --space -t --thanks -h --help" -- $cur) )
  fi
}

complete -o filenames -F _twerque twerque
