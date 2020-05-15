#!/bin/sh

TRUE=0
FALSE=1

red="\033[0;31m"
green="\033[0;32m"
nocolor="\033[0m"

commands="bash clang dash g++ gcc git python python3 vim zsh"

features=""

command_exists() {
  cmd="$1"
  type "$cmd" >/dev/null 2>&1
  return "$?"
}

add_feature() {
  feature="$1"
  if [ "$features" = "" ]; then
    features="$feature"
  else
    features="$features $feature"
  fi
}

has_feature() {
  feature_to_test="$1"
  ftt_1=" $feature_to_test "
  ftt_2=" $feature_to_test"
  ftt_3="$feature_to_test "
  case "$features" in
    *"$ftt_1"*|*"$ftt_2"|"$ftt_3"*|"$feature_to_test")
      return "$TRUE";;
    *)
      return "$FALSE";;
  esac
}

check_features() {
  # Check commands
  for command in $(echo "$commands"); do
    if command_exists "$command"; then
      printf "${green}✓${nocolor} %s command\n" "$command"
      add_feature "command-$command"
    else
      printf "${red}✗${nocolor} %s command\n" "$command"
    fi
  done
}

prompt_to_continue() {
  prompt_msg="$1"
  prompt_default="$2"
  prompt_default_is_no="$FALSE"
  prompt_default_is_none="$FALSE"
  case "$prompt_default" in
    [Yy]|[Yy][Ee][Ss])
      prompt_choices="[Yn]";;
    [Nn]|[Nn][Oo])
      prompt_choices="[yN]"
      prompt_default_is_no="$TRUE";;
    *)
      prompt_choices="[yn]"
      prompt_default_is_none="$TRUE";;
  esac
  printf "%s Continue? %s " "$prompt_msg" "$prompt_choices"
  read -r prompt_choice
  while true; do
    case "$prompt_choice" in
      [Yy]|[Yy][Ee][Ss])
        choice_bool="$TRUE"
        break;;
      [Nn]|[Nn][Oo])
        choice_bool="$FALSE"
        break;;
      "")
        if [ "$prompt_default_is_none" -eq "$TRUE" ]; then
          printf "Please answer yes or no. %s " "$prompt_choices"
          read -r prompt_choice
        elif [ "$prompt_default_is_no" -eq "$TRUE" ]; then
          choice_bool="$FALSE"
          break
        else # prompt default is yes
          choice_bool="$TRUE"
          break
        fi
        ;;
      *)
        if [ "$prompt_default_is_none" -eq "$TRUE" ]; then
          printf "Please answer yes or no. %s " \
            "$prompt_choices"
        elif [ "$prompt_default_is_no" -eq "$TRUE" ]; then
          printf "Please answer yes or no, or press return to abort. %s " \
            "$prompt_choices"
        else # prompt default is yes
          printf "Please answer yes or no, or press return to continue. %s " \
            "$prompt_choices"
        fi
        read -r prompt_choice;;
    esac
  done
  return "$choice_bool"
}

get_source() {
  url="$1"
  source_folder="$2"
  if prompt_to_continue "Attempting to install from $url." "y"; then
    git clone "$url" "$source_folder"
  fi
}

read_sources() {
  i=0
  while read -r line <&9; do
    get_source "$line" "$i"
    i="$((i + 1))"
  done 9<sources
}

check_features
read_sources
