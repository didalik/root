#!/usr/bin/env bash
# Copyright (c) 2023-present, Дід Alik and the Kids {{{1
#
# This script is licensed under the Apache License, Version 2.0, found in the
# LICENSE file in the root directory of this source tree.
##

# This script, ./aim/bin/test.sh, is referenced by ./package.json {{{1
#
##

. dak/util/org/lib/util.sh # {{{1

## cmd do_bats: run the BATS test suite {{{1
#
do_bats () { 
  echo "- bats $#: $@"
  exit
}

## cmd init: init git repo and push it to a remote location {{{1
#
# (re-)Init the git repository at $1, add a $1-remote, and push it there.
#
# For example: init dak/util/org ubuntu u20
#
init () {
  echo "- init $#: $@"
  local repo=$1
  local user=$2
  local host=$3

  cd $repo
  git init; git add -A; git commit -am 'Add files'
  irra $host $user
  git push $host main
  exit
}

## cmd npack: create/update an NPM package (package.json, ...) {{{1
#
# SYNOPSIS
#  npack <package-dir> [<setup-cmd>]
#   
# For example: npack dak/hex/test clear
#
npack () {
  echo "- npack $#: $@"
  local path=$1 pre=$2
  shift 2
  [[ ${#pre} > 0 ]] && npack_make $pre
  npack_make
  exit 0
}

## cmd test: testing the 'npm test' script {{{1
#
test () {
  echo "- test $#: $@"
  exit
}

[ $npm_config_bats ] && do_bats $@ || # {{{1
  [[ $# > 0 ]] && { CMD=$1; shift; $CMD $@; } || cat << USAGE

 Usage examples:

  npm test --bats=true # to run the BATS test suite
  npm test test me     # to run the 'test' command

 Commands:

USAGE
cat $0 | grep '## cmd ' | head -n -1
