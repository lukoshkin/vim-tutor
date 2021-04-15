#!/bin/bash

main () {
  case $1 in
    compete) _compete $2 ;;
    stencil) shift; _stencil $@ ;;
    learn) _learn $2 ;;
    *) help_msg ;;
  esac
}


#####################################
# --------- functionality --------- #
#####################################

_compete () {
  local prefix=${1%/}
  local tmp=$(echo $prefix/tasks.*)
  local ext=${tmp##*.}
  local dir=$(dirname $0)

  safecheck

  clear -x
  print_instructions

  export vc_rules_prefix=$prefix
  install -m 664 "$prefix/tasks."* "/tmp/answers-$USER.$ext"
  local elapsed_time=$(timeit)

  local vimdiff='vimdiff'
  type nvim &> /dev/null && vimdiff='nvim -d'
  $vimdiff +"source $dir/rules.vim" -W "/tmp/vc-sol-$USER" \
    "/tmp/answers-$USER.$ext" "$prefix/answers."*

  unset vc_rules_prefix
  elapsed_time=$(bc -l <<< "$(timeit) - $elapsed_time" )

  cmp -s "/tmp/answers-$USER.$ext" "$prefix/answers."* \
    && print_user_score || print_early_exit
}


_stencil () {
  local params short=a:,p: long=rules,author:,problem:
  local problem=$(mangle_name ${1##*/}) author=$USER create_rules=false
  params=$(getopt -u -o $short -l $long --name "$0" -- "$@")

  [[ $? -ne 0 ]] && exit 1
  set -- $params

  while : 
  do
    case "$1" in
      -a|--author) author=$2; shift 2 ;;
      -p|--problem) problem=$(mangle_name $2); shift 2 ;;
      -r|--rules) create_rules=true; shift ;;
      --) shift; break ;;
      *) echo "Not implemented option: $1" >&2; exit 1 ;;
    esac
  done

  if [[ -z $1 ]]
  then
    echo Specify a name for a new or existing directory.
    exit 1
  fi

  mkdir -p $1
  [[ -n $(ls -A "$1") ]] && { echo "$1 is not empty!"; exit 1; }

  $create_rules && touch "$1/rules.vim"
  echo -e "# $problem\n" > "$1/tasks.md"
  echo "Author: $author" >> "$1/tasks.md"
  echo -e "\n---\n" >> "$1/tasks.md"
  cp "$1/tasks.md" "$1/answers.md"
  ln -s "tasks.md" "$1/README.md"
}


_learn () {
  echo Not implemented yet.
}


help_msg () {
  echo -e 'Usage: ./tutor.sh <cmd> </path/to/dir/with/tasks/and/answers>\n'
  echo -e 'Commands:\n'

  printf '  %-18s Begin the specified competition.\n' 'compete'
  printf '  %-18s Start creating your own competition with a stencil.\n' 'stencil'
  printf '  %-18s Not implemented yet.\n' 'learn'
  exit
}


############################################
# --------- 'compete' components --------- #
############################################

print_instructions () {
  center_text 'Welcome to Vim-competition!'
  local author=$(sed -n '/^Author/p' $prefix/tasks.$ext)
  local problem=$(sed 's/^# \(.\+\)/\1/;q' $prefix/tasks.$ext)

  [[ -n "$author" ]] && center_text "$author"
  [[ -n "$problem" ]] && center_text "$problem"
  echo
  center_text '***'

  echo
  center_text 'You will be offered to solve one or more tasks' \
    'using the best of your vim skills.'
  center_text 'The challenge is to make the split on the left' \
    'look the same as the one on the right.'
  center_text 'After the work is done,' \
    'save your results and exit from all buffers.'

  echo
  center_text 'Remember, the fewer the number of keystrokes,' \
    'and the less time per task, the higher the score.'
  center_text "And please, don't try to cheat."
  echo
  center_text '***'
  printf '\n'

  local action1='PRESS <ENTER> TO CONTINUE'
  center_text $action1

  local action2='(or CTRL-C to exit)'
  local cols=$(( ($(tput cols) - ${#action2}) / 2 ))
  printf '%*s' $cols ''

  read -sp "$action2"$'\n\n\n'
}


print_user_score () {
  local kslen=$(( $(wc -c < "/tmp/vc-sol-$USER") - 1 ))
  compensate_navigation_keys

  local hit_score time_score score
  hit_score=$(bc -l <<< "1/(1+.1*$kslen)")
  time_score=$(bc -l <<< "1/(1+l(1+$elapsed_time))")
  score=$(bc <<< "90*$hit_score + 9*$time_score + 1")
  LC_NUMERIC="en_US.UTF-8" score=$(printf %.3f $score)

  local grats='Congratulations! Your score is'
  local strlen=$(( ${#grats} + ${#score} + 1 ))

  printf "%*s" $(( ($(tput cols) - $strlen) / 2 ))
  echo -e "$grats $(tput bold)$score$(tput sgr0)\n"

  center_text 'Verification codes:'
  center_text "$(md5sum $0)"
  center_text "$(md5sum $dir/rules.vim)"
  center_text "$(md5sum $prefix/answers.$ext)"
}

compensate_navigation_keys () {
  grep -oE '([hjkl])\1\1\1+' "/tmp/vc-sol-$USER" > "/tmp/krr-trace-$USER"
  vim "/tmp/krr-trace-$USER" +"execute 'normal ggVGgJ'" +wq &> /dev/null

  local nklen=$(wc -c < "/tmp/krr-trace-$USER")
  [[ $nklen -gt 0 ]] && kslen=$(bc <<< "$kslen - .5*($nklen-1)")
  rm -f "/tmp/krr-trace-$USER"
}


print_early_exit () {
  center_text "You've left the competition unfinished."
  center_text "Unfortunately, intermediate results aren't saved."
  center_text 'Next time you will start it from the beginning.'
}


safecheck () {
  local msg sen code=0
  [[ -d "$prefix" ]] || { echo No such directory: $prefix; exit; }

  preamble="Checking '$prefix' directory for required components:"

  [[ -f "$prefix/tasks.$ext" ]] \
    || { msg+="\n  tasks.$ext doesn't exist"; (( code++)); }
  [[ -f "$prefix/answers.$ext" ]] \
    || { msg+="\n  answers.$ext doesn't exist"; (( code++)); }

  [[ $code -gt 0 ]] && { echo -e "$preamble$msg"; exit; }
}


#################################
# --------- auxiliary --------- #
#################################

# NOTE: a bit inaccurate time measurements for macOS
timeit () {
  if [[ $(uname) != Darwin ]]
  then
    echo $(date +%s.%N)
  else
    echo $(date +%s)
  fi
}


mangle_name () {
  local name=$1
  name=${name//-/ }
  name=${name//_/ }
  echo $name
}


center_text () {
  local str="$@"
  printf "%*s" $(( ($(tput cols) - ${#str}) / 2 ))
  printf "$str\n"
}


break_clipboard () {
  msg='No clipboard allowed!'
  [[ $(uname) != Darwin ]] \
    && clipper='xclip -selection clipboard' \
    || clipper=pbcopy

  while :
  do
    echo $msg | $clipper
    sleep .01
  done
}



###################################
# --------- 'main' call --------- #
###################################

[[ $# -eq 0 ]] && help_msg
break_clipboard &
pid=$!

trap "kill -9 $pid" EXIT
main $@

