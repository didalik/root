#!/usr/bin/env bash

putenv () { # {{{1
  local key=$1 value=$2 env=$3
  if [ -z "$env" ]; then
    env="$HOME/.shared-services.env"
  fi
  cat $env | grep -v $key > $env.tmp
  echo "export $key=$value" >> $env.tmp
  mv $env.tmp $env
}

export HERE=$PWD/.wrangler/state # {{{1
putenv PORT_registry 8788
. $HOME/.shared-services.env
cd $SVC_PATH_registry
echo "- PWD $PWD, HERE $HERE"
npm run dev --port=$PORT_registry --persist2=$HERE
