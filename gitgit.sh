#! /usr/bin/env bash

set -euo pipefail

if [[ ${DEBUG-} =~ ^1|yes|true$ ]]; then
  set -o xtrace
fi

readonly prog_name=$(basename "${0}" | cut -d. -f1)
readonly author_name=$(git config user.name)
readonly author_email=$(git config user.email)
readonly git_remote_url=$(
  git config --get remote.origin.url |
    sed -r "s:git@([^/]+)\:(.*\.git):https\://\1/\2:g"
)
readonly prog_version="1.0"

show_help() {
  echo -e "Usage: ${prog_name} [<options>] [<argument> ...]"
  echo -e ""
  echo -e "Special options:"
  echo -e "  -h    Show this help and exit"
  echo -e "  -v    Show version number and exit"
  echo -e ""
  echo -e "Full documentation available at: ${git_remote_url}"
}

show_version() {
  local build_arch=$(arch)
  local system_model=$(sysctl -n machdep.cpu.brand_string)
  local os_type=$(uname -or | sed "s/ //g")
  local formatted_output=$(
    echo -e "(${build_arch}-${system_model}-${os_type})" |
      tr "[:upper:]" "[:lower:]" |
      sed "s/ /-/g"
  )
  echo -e "${prog_name} ${prog_version} ${formatted_output}"
}

invalid_option() {
  echo -e "${prog_name}: invalid option ${@}"
  exit 1
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

# Based on this StackOverflow answer: https://stackoverflow.com/a/5230306
args=$(getopt -o :hv --long :help,version -- "$@")

while [ $# -gt 0 ]; do
  case $1 in
  -h | --help) show_help ;;
  -v | --version) show_version ;;
  --)
    shift
    break
    ;;
  -*)
    invalid_option $1
    ;;
  *) break ;;
  esac
  shift
done
