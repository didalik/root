docker_delete_all () { # delete all containers and images {{{1
  sudo docker rm $(sudo docker ps -a | awk '{ print $1}' | tail -n +2)
  sudo docker rmi -f $(sudo docker images | awk '{ print $3}' | tail -n +2)
}

irra () { # Init Remote Repositiry for Account {{{1
  #
  # Usage example:
  #
  #   git init; git commit -am 'Add files'
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
  echo "mkdir -p $repo; cd $repo" > $input
  echo 'git config --global init.defaultBranch main; git init --bare' >> $input
  ssh $account@$remote < $input 2>&1 # | tail -n +12
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

