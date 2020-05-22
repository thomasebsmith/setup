#!/bin/sh

TRUE="0"
FALSE="1"

red="$(tput setaf 1 2>/dev/null)"
green="$(tput setaf 2 2>/dev/null)"
reset="$(tput sgr0 2>/dev/null)"

feature_sep="&&"

features=""

append() {
  list="$1"
  word="$2"
  if [ "$list" = "" ]; then
    echo "$word"
  else
    echo "$list $word"
  fi
}

contains() {
  string="$1"
  word="$2"
  word_1=" $word "
  word_2=" $word"
  word_3="$word "
  case "$string" in
    *"$word_1"*|*"$word_2"|"$word_3"*|"$word")
      return "$TRUE";;
    *)
      return "$FALSE";;
  esac
}

has_feature() {
  contains "$features" "$1"
  return "$?"
}

verify_dependencies() {
  # $1 contains a space-separated list of dependent features.
  # $2 is modified to contain the list of features to add.
  set -- "$1" ""
  while read -r line <&8; do
    feature_list=""
    fulfilled="$FALSE"
    for possible_feature in $(echo "$line"); do
      if has_feature "$possible_feature"; then
        fulfilled="$TRUE"
        break
      else
        # If this feature is depended on by itself, don't install it.
        if contains "$1" "$possible_feature"; then
          continue
        fi
        # Features must not be the feature separator &&
        if [ "$possible_feature" = "$feature_sep" ]; then
          return 1
        fi
        feature_list="$(append "$feature_list" "$possible_feature")"
      fi
    done
    if [ "$fulfilled" = "$FALSE" ]; then
      if [ "$2" = "" ]; then
        set -- "$1" "$feature_list"
      else
        set -- "$1" "$2 $feature_sep $feature_list"
      fi
    fi
  done 8<dependencies
  fulfilled="$FALSE"
  for feature in $(echo "$2"); do
    if [ "$fulfilled" = "$TRUE" ]; then
      if [ "$feature" = "$feature_sep" ]; then
        fulfilled="$FALSE"
      fi
      continue
    fi
    if [ "$feature" = "$feature_sep" ]; then
      return 1
    fi
    if install_feature "$feature" "$1 $feature"; then
      fulfilled="$TRUE"
    fi
  done
  return "$fulfilled"
}

# install_feature expects to be in the "features" directory
install_feature() {
  # If a second argument is passed, it should contain a space-separated list
  #  of features that are dependent on this feature.
  cd "$1" || return 1
  if [ "$#" -eq 3 ]; then
    for feature in $(echo "$2"); do
      if [ "$feature" = "$1" ]; then
        return 1
      fi
    done
    verify_dependencies "$2" || return 1
  else
    verify_dependencies "" || return 1
  fi
  ./run.sh || return 1
  features="$(append "$features" "$1")"
  cd .. || return 1
  return 0
}

to_install=""
get_default_features() {
  while read -r line <&8; do
    to_install="$(append "$to_install" "$line")"
  done 8<default_features
}

install_all() {
  cd features || return 1
  for feature_to_install in $(echo "$to_install"); do
    if has_feature "$feature_to_install"; then
      printf "${green}✓${reset} %s already installed\n" "$feature_to_install"
      continue
    fi
    if install_feature "$feature_to_install"; then
      printf "${green}✓${reset} %s installed\n" "$feature_to_install"
    else
      printf "${red}✗${reset} %s installation failed\n" "$feature_to_install"
    fi
  done
}

# Change the current directory to the cloned source.
cd "$(dirname "$0")" || exit 1
cd "$1" || exit 1

features="$2"
get_default_features
install_all || return 1
