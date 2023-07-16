#!/usr/bin/env bash

cfw-deploy () { # {{{1
  echo '- cfw-deploy started'
  [ -e dist.ts ] || {
    echo '- cfw-deploy: no dist.ts, deploying...'
    wrangler deploy && touch dist.ts
    echo '- wait for 5 seconds...'; sleep 5;
    echo '- cfw-deploy done'
    return 0
  }
  for file in src/*; do
    [ $file -nt dist.ts ] && {
      echo "- cfw-deploy: $file updated, deploying..."
      [ -z "$(git status --porcelain)" ] || git commit -am "Update $file"
      wrangler deploy && touch dist.ts
      echo '- wait for 5 seconds...'; sleep 5;
      echo '- cfw-deploy done'
      return 0
    }   
  done
  echo '- cfw-deploy stopped'
}

docker_delete_all () { # delete all containers and images {{{1
  sudo docker rm $(sudo docker ps -a | awk '{ print $1}' | tail -n +2)
  sudo docker rmi -f $(sudo docker images | awk '{ print $3}' | tail -n +2)
} # TODO remove, use ../util.sh instead

irra () { # (re-)Init Remote Repositiry for Account {{{1
  #
  # Usage example:
  #
  #   git init; git add -A; git commit -am 'Add files'
  #   irra m1 alec
  #   git push m1 main

  local remote=$1  # docker,       u20,    m1, ...
  local account=$2 # devops, prod, ubuntu, alec
  local repo=$(pwd)
  repo=${repo#/*/*/}
  git remote rm $remote
  local home=$(rhome $remote $account)
  git remote add $remote "ssh://$account@$remote:$home/$repo"
  git remote -v | grep $remote
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R $remote > /dev/null
  ssh-keyscan $remote 2>/dev/null | grep 'ed25519' > $HOME/.ssh/known_hosts 2>/dev/null
  local input='/tmp/input'
  echo "rm -rf $repo; mkdir -p $repo; cd $repo" > $input
  echo 'git config --global init.defaultBranch main; git init --bare' >> $input
  ssh $account@$remote < $input 2>&1
}

generate () { # {{{1
  echo -en "- generate: target $1\t"
  local target=$1 hosts=()
  case $target in
    ./config/Makefile) # {{{2
      echo #'TODO implement root Makefile';;
      cp ./src/Makefile ./config/Makefile
      ;;
    ./config/kids/*/utils.sh) # {{{2
      for role in "${roles[@]}"; do
        local h4r="$role[@]"
        for h in "${!h4r}"; do
          for host in "${hosts[@]}"; do
            [ "$h" == "$host" ] && continue 2
          done
          hosts+=($h)
        done
      done
      echo -n "declare -a" > $target
      for host in "${hosts[@]}"; do
        echo -n " $host=()" >> $target
      done
      echo -en "\n\naddrole2host () {\n\tlocal role=\$1 host=\$2\n\tcase \$host in" >> $target
      for host in "${hosts[@]}"; do
        echo -en "\n\t\t$host) $host+=(\$role);;" >> $target
      done
      echo -e "\n\t\t*) echo "UNEXPECTED host \$host";;\n\tesac\n}" >> $target;;
    ./config/kids/*/images/bootstrap/Makefile) # {{{2
      echo #"TODO implement target $target!";;
      cp ./src/images/bootstrap/* $(dirname $target)
      cp ./src/images/bootstrap.etc.ssh/* $(dirname $target)
      echo "$ssh_pk" >> $(dirname $target)/authorized_keys
      ;;
    ./config/kids/*/images/*/Makefile) # {{{2
      echo #"TODO implement target $target!";;
      id_ed25519 $(dirname $target)
      cp ./src/images/bootstrap/Makefile $(dirname $target)
      cp ./src/images/etc.ssh/* $(dirname $target)
      ;;
    *) # {{{2 
      echo "TODO implement UNKNOWN target $target";; # }}}2
  esac
}

hosts4role () { # {{{1
  local h4r="$1[@]"
  echo -e "- role $1\thosts=(${!h4r})"
  for h in "${!h4r}"; do
    phost $h
  done
}

id_ed25519 () { # {{{1
  cd $1
  . users.sh
  for user in "${users[@]}"; do
    echo "# id_ed25519: host $1, user $user"
    mkdir $user
    ssh-keygen -t ed25519 -f id_ed25519 -P '' > /dev/null
    mv id_ed25519 id_ed25519.pub $user
    cat $user/id_ed25519.pub >> ../bootstrap/authorized_keys
  done
  ssh-keygen -t ed25519 -f id_ed25519 -P '' > /dev/null
  cat id_ed25519.pub >> ../bootstrap/authorized_keys
  cd -
}

isSubDir () { # {{{1
  local sd="$(realpath $1)"; 
  local d="$(realpath $2)";
  [ "${sd:0:${#d}}" = "$d" ] || return
  echo "INVALID SVC_PATH: subdir of $PWD"
  exit 2
};

putenv () { # {{{1
  local key=$1 value=$2 env=$3
  if [ -z "$env" ]; then
    env="$HOME/.shared-services.env"
  fi
  cat $env | grep -v $key > $env.tmp
  echo "export $key=$value" >> $env.tmp
  mv $env.tmp $env
}

phost () { # {{{1
  local host=$1
  local r=$host[@]
  addrole2host $role $host
  for m in "${hosts[@]}"; do # env var 'h' is already declared, hence using 'm'
    [ "$m" == "$host" ] && return
  done
  hosts+=($1)
}

rhome () { # Remote Home {{{1
  local remote=$1
  local account=$2
  case $remote in
    m1) echo "/Users/$account";;
    docker) echo "/home";;
    *) echo "/home/$account";;
  esac
}

vault_url () { # svc/gen URL {{{1
  #echo $@ 1>&2
  local user=$1 host=$2 path=$(realpath $3)
  path=${path#/*/*/}
  echo "ssh://${user}@${host}:/home/${user}/${path}"
}

#command=$1; shift; $command $@ # for inline use, e.g., with sudo  {{{1

