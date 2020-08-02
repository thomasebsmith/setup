#!/bin/sh

# TRUE and FALSE are defined this way to allow for use of boolean functions
# in if statements (since a 0 return code indicates success).
TRUE=0
FALSE=1

red="$(tput setaf 1 2>/dev/null)"
green="$(tput setaf 2 2>/dev/null)"
reset="$(tput sgr0 2>/dev/null)"

# Default commands to check for.
commands="bash brew bzip2 cargo clang curl csh dash dig emacs ftp g++ gcc\
 gem git go gunzip gzip ifconfig ksh ld less lynx\
 make md5 mount nano node npm java perl ping pip pod python python3 ruby rustc\
 ssh su sudo swift swiftc tac tar tcsh tree unzip vim wget which zip zsh"

features=""

# command_exists(command): Determines whether <command> is in the user's PATH
# or otherwise accessible.
command_exists() {
  cmd="$1"
  type "$cmd" >/dev/null 2>&1
  return "$?"
}

# add_feature(feature_name): Adds <feature_name> to the list of installed
# features.
add_feature() {
  feature="$1"
  if [ "$features" = "" ]; then
    features="$feature"
  else
    features="$features $feature"
  fi
}

# has_feature(feature_name): Determines whether a feature with name
# <feature_name> has been added to the list of installed features.
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

# check_features(): Checks for a default list of features, and adds installed
# ones to the list of installed features. Also prints whether each feature is
# installed.
check_features() {
  # Check commands
  for command in $(echo "$commands"); do
    if command_exists "$command"; then
      printf "${green}✓${reset} %s command\n" "$command"
      add_feature "command-$command"
    else
      printf "${red}✗${reset} %s command\n" "$command"
    fi
  done

  # Check other features
  if [ -t 1 ]; then
    add_feature "terminal-out"
    printf "${green}✓${reset} terminal output\n"
  else
    printf "${red}✗${reset} terminal output\n"
  fi
  if [ -n "$(tput colors 2>/dev/null)" ]; then
    add_feature "terminal-colors"
    printf "${green}✓${reset} terminal colors\n"
  else
    printf "${red}✗${reset} terminal colors\n"
  fi
}

# prompt_to_continue(msg, default): Prompts the user to continue with an action,
# displaying <msg> as the action to continue and using <default> as the default
# choice if the user does not decide.
# Returns whether the user chose to continue.
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

# get_source(url, source_folder): Clones the repository at <url> into
# <source_folder>. Then, installs all features in the source repository.
get_source() {
  url="$1"
  source_folder="$2"
  if prompt_to_continue "Attempting to install from $url." "y"; then
    git clone "$url" "$source_folder"
    ./install_source.sh "$source_folder" "$features"
    # TODO: Get newly installed features from ./install_source.sh
  fi
}

# read_sources(): Executes installations for all source repositories found in
# `sources`.
read_sources() {
  i=0
  while read -r line <&9; do
    get_source "$line" "$i"
    i="$((i + 1))"
  done 9<sources
}

cd "$(dirname "$0")" || exit 1
check_features
read_sources
