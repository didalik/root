Build and run docker image with three accounts:

- kid;
- devops; and
- prod.

The last two accounts have separate git repositories, and the 'kid' account has SSH access to both of them.

When completed, the SSH configuration and the configuration of the repo accounts will be copied to u20. These accounts will define the kid's roles.

Build the image with

```
:!clear; make clean; make
```

Run the image interactively with

```
:!clear; cd configure-ssh/kid-git-role; sudo docker run -it role-based-repos bash
```

SSH from dockerhost to container and back:

```
sudo docker ps -a
sudo docker inspect heuristic_benz | grep "IPAddress"
ssh -R 0:127.0.0.1:22 kid@172.17.0.2
...
ssh -p 12345 alik@localhost
```
