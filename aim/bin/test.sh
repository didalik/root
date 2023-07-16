#!/usr/bin/env bash

. dak/util/org/lib/util.sh

## cmd init: init git repo and push it to a remote location {{{1
#
# (re-)Init the git repository at $PWD, add a $PWD-remote,
# and push it there.
#
# For example: init u20 ubuntu
#
init () {
  echo "- init $#: $@"
  local host=$1
  local user=$2
  git init; git add -A; git commit -am 'Add files'
  irra $host $user
  git push $host main
}

echo "- $0 $#: $@" # {{{1
[[ $# > 0 ]] && { CMD=$1; shift; $CMD $@; } || cat << USAGE

  Usage:

$0 <cmd> <args>

  Commands:

USAGE
cat $0 | grep cmd | head -n -2
