#!/bin/sh

TRUE=0
FALSE=1

red="\033[0;31m"
green="\033[0;32m"
nocolor="\033[0m"

commands="bash gcc g++ python python3 vim zsh"

command_exists() {
  local cmd="$1"
  type "$cmd" &> /dev/null
  return "$?"
}

check_features() {
  # Check commands
  for cmd in $commands; do
    if command_exists "$cmd"; then
      printf "${green}✓${nocolor} %s command\n" "$cmd"
    else
      printf "${red}✗${nocolor} %s command\n" "$cmd"
    fi
  done
}

get_source() {
  local url="$1"
  local i="$2"
}

read_sources() {
  local i=0
  while read line; do
    get_source "$line" "$i"
    i="$((i+1))"
  done < sources
}

check_features
read_sources
