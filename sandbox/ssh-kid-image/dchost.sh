# Docker Container Host Utils

confugure_ssh () { # {{{1
  local home=$1 user=$2 src='configure-ssh/kid-git-role'
  mkdir $home/.ssh; chmod 700 $home/.ssh; chown -R $user:$user $home/.ssh
  cp $src/$user/id_ed25519* $src/authorized_keys $home/.ssh
}

irr4r () { # Init Remote Repositiry For Role {{{1
  #
  # Usage example:
  #
  #   git init; git commit -am 'Add files'
  #   irr4r m1 alec
  #   git push m1 main

  local remote=$1 # docker,       u20,    m1, ...
  local role=$2   # devops, prod, ubuntu, alec
  local repo=$(pwd)
  repo=${repo#/*/*/}
  git remote rm $remote
  local home=$(rhome $remote $role)
  git remote add $remote "ssh://$role@$remote:$home/$repo"
  git remote -v | grep $remote
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R $remote > /dev/null
  ssh-keyscan $remote 2>/dev/null | grep 'ed25519' > $HOME/.ssh/known_hosts 2>/dev/null
  local input='/tmp/input'
  echo "mkdir -p $repo; cd $repo" > $input
  echo 'git config --global init.defaultBranch main; git init --bare' >> $input
  ssh $role@$remote < $input 2>&1 # | tail -n +12
}

jail () { # {{{1
#
# Usage:
#
#   sudo ./dchost.sh jail <user> <cmd1> ...
#
#
# Thanks to:
# - https://unix.stackexchange.com/questions/542440/how-does-chrootdirectory-and-a-users-home-directory-work-together/542507#542507
# - https://www.howtogeek.com/441534/how-to-use-the-chroot-command-on-linux/
#
  local user=$1; shift # see cmds definition below
  mkdir -p /jail/$user
  chown root:root /jail/$user; chmod 755 /jail/$user
  useradd -rmd /jail/$user/home -s /bin/bash $user
  chown $user: /jail/$user/home; chmod 750 /jail/$user/home

  confugure_ssh /jail/$user/home $user

  local current_dir=$(pwd)
  cd /jail/$user; ln -s . jail; ln -s . $user
  mkdir dev
  cd dev
  mknod -m 666 null c 1 3
  mknod -m 666 tty c 5 0
  mknod -m 666 zero c 1 5
  mknod -m 666 random c 1 8
  cd ..
  local deps cmds=$@
  echo "- User $user: '$cmds'"
  for c in $cmds; do
    cp --parents "/bin/$c" .
    deps="$(ldd /bin/$c | egrep -o '/lib.*\.[0-9]')"
    for d in $deps; do cp --parents "$d" .; done
  done
  cd $current_dir
}
rhome () { # Remote Home {{{1
  local remote=$1
  local role=$2
  case $remote in
    m1) echo "/Users/$role";;
    docker) echo "/home";;
    *) echo "/home/$role";;
  esac
}

sdc () { # SSH to Docker Container {{{1
  ssh-keygen -f "/home/alik/.ssh/known_hosts" -R "docker"
  ssh-keyscan docker 2>/dev/null | grep 'ed25519' > $HOME/.ssh/known_hosts
  ssh $1@docker
}

CMD=$1; shift; $CMD $@ # {{{1

