# Locals {{{1
SHELL := bash
RECIPES = clean go-configure-ssh push2hub util-auth-as-kid util-delete-all
.PHONY: $(RECIPES)

# Configure and run SSH for the role-based-repos image {{{1
go-configure-ssh:
	@$(MAKE) -C configure-ssh

clean: # {{{1
	@$(MAKE) -C configure-ssh clean

push2hub: # {{{1
	@$(MAKE) -C configure-ssh push2hub

# Authenticate alik@thisVM as kid on docker, localhost, m1 and u20 - authorize kid {{{1
# The kid has both devops and prod roles - is authorized to SSH to both devops and prod accounts.
KID_PK := configure-ssh/kid-git-role/kid/id_ed25519.pub
KID_SK := configure-ssh/kid-git-role/kid/id_ed25519
util-auth-as-kid:
	@export pk=$$(cat $(KID_PK));\
		echo -e "\n# kid in the role-based-repos image:\n$$pk" >> $$HOME/.ssh/authorized_keys;\
		ssh alec@m1 "echo -e '\n# kid in the role-based-repos image:\n$$pk' >> .ssh/authorized_keys";\
		ssh ubuntu@u20 "echo -e '\n# kid in the role-based-repos image:\n$$pk' >> .ssh/authorized_keys";\
		cp $(KID_SK) $$HOME/.ssh

# Delete ALL docker containers and images {{{1
util-delete-all:
	@sudo docker rm $$(sudo docker ps -a | awk '{ print $$1}' | tail -n +2)
	@sudo docker rmi -f $$(sudo docker images | awk '{ print $$3}' | tail -n +2)
