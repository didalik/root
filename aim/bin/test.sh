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

## cmd do_bats: run the BATS test suites {{{1
#
do_bats () { 
  echo "- do_bats $#: $@"
  pushd dak/svc/index;npm test;popd
  pushd dak/svc/hex;  npm test;popd
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

## cmd init_dak_util_svc: add the leaf below as git submodule {{{1
# .
# ├── dak
# │   └── util
# │       └── svc
#
# Copy .gitignore and LICENSE to it from the root. Submodule dak/util/public into it. 
#
# See also:
# https://vsupalov.com/git-fix-submodule/
# https://stackoverflow.com/questions/1260748/how-do-i-remove-a-submodule?rq=3
# https://stackoverflow.com/questions/73725003/how-to-remove-unwanted-inadvertent-git-submodules-in-new-repositories
#
init_dak_util_svc () {
  echo "- init_dak_util_svc $#: $@"
  #mkdir -p dak/util/svc
  #cp .gitignore dak/util/svc
  #cp LICENSE dak/util/svc
  #init dak/util/svc ubuntu u20
  #git submodule add ssh://ubuntu@u20:/home/ubuntu/people/didalik/dak/util/svc dak/util/svc
  pushd dak/util/svc
  #git clone --recurse-submodules git@github.com:didalik/svc.git dak/util/public
  #cd dak/util/public/bash-tpl;git checkout main;cd -
  #git submodule add git@github.com:didalik/svc.git dak/util/public
  popd
}

## cmd npack: create/update an NPM package (package.json, ...) {{{1
#
# SYNOPSIS
#  npack <package-dir> <package-name> [<setup-recipe>]
#   
# For example: npack dak/hex/test test-package clear
#
npack () {
  echo "- npack $#: $@"
  local path=$1 name=$2 pre=$3
  shift 3
  . env.$name
  [[ ${#pre} > 0 ]] && npack_make $pre
  npack_make
  exit 0
}

## cmd npack_aux: add the leaf below as an NPM package and git submodule {{{1
# .                                 {{{2
# └── aux
#
# }}}2
npack_aux () {
  echo "- npack_aux $#: $@"
  #echo 'export desc="Generated on $(date). This is a description of $name."' > env.aux
  #npack aux aux # {{{2
  #init aux ubuntu u20
  #git submodule add ssh://ubuntu@u20:/home/ubuntu/people/didalik/aux aux
  #cd aux;git remote rename u20 origin;cd - # }}}2
}

## cmd npack_hex: add all the leaves below as NPM packages and git submodules {{{1
# .                                 {{{2
# ├── dak
# │   ├── hex
# │   │   ├── agent
# │   │   └── user                   # DONE
# │   └── svc
# │       └── hex                    # DONE
#
# Make submodule `./dak/hex/user` public.
# }}}2
npack_hex () {
  echo "- npack_hex $#: $@"
  #npack dak/hex/agent dak-hex-agent # {{{2
  #init dak/hex/agent ubuntu u20
  #git submodule add ssh://ubuntu@u20:/home/ubuntu/people/didalik/dak/hex/agent dak/hex/agent
  #cd dak/hex/agent;git remote rename u20 origin;cd -
  #npack dak/hex/user dak-hex-user
  #init dak/hex/user ubuntu u20
  #cd dak/hex/user;git remote rename u20 origin;cd -
  #cd dak/hex/user
  #git remote add public git@github.com:didalik/dak-hex-user.git
  #git branch -M main
  #git push -u public main
  #cd -
  #git submodule add -b main git@github.com:didalik/dak-hex-user.git dak/hex/user
  #npack dak/svc/hex dak-svc-hex
  #init dak/svc/hex ubuntu u20
  #git submodule add ssh://ubuntu@u20:/home/ubuntu/people/didalik/dak/svc/hex dak/svc/hex
  #cd dak/svc/hex;git remote rename u20 origin;cd -
  #cd dak/hex/user;git remote add dak.hex.user git@github.com:didalik/dak.hex.user.git;git push dak.hex.user main;cd -
  #git submodule set-url dak/hex/user git@github.com:didalik/dak.hex.user.git # }}}2
}

## cmd submodule_remove: remove submodule(s) from $repository {{{1
#
# SYNOPSIS
#  submodule_remove <repository> <submodule> ...
#
submodule_remove () {
  echo "- submodule_remove $#: $@"
  local repository=$1
  shift
  cd $repository
  for p in $@; do
    echo "  - removing $p..."
    git rm -f $p
    rm -rf .git/modules/$p
    git config --remove-section submodule.$p
    echo '  + removed'
  done
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

  npm test --bats  # to run the BATS test suite
  npm test test me # to run the 'test' command

 Commands:

USAGE
cat $0 | grep '## cmd ' | head -n -1
