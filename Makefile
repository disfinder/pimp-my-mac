.PHONY: git
default: help
help:
	@echo "Available targets:"
	@echo "  make screenshots:   configure screenshots folder"
	@echo "  make brew: 	     install all brew repositories, packages, casks"
	@echo "  make projects_brew: install only projects-based brew repos, packages, casks"

.PHONY: screenshots brew projects_brew ssh bash debug

all:
	./playbook-init.yml
	@bash -l -i -c 'notify "ALL is done" "pimp-my-mac"'

bash:
	./playbook-init.yml --tags bash
	@bash -l -i -c 'notify "bash is done" "pimp-my-mac"'

screenshots:
	./playbook-init.yml --tags macos_defaults --skip-tags always

brew:
	./playbook-init.yml --tags brew
	@bash -l -i -c 'notify "brew is done" "pimp-my-mac"'

projects_brew:
	./playbook-init.yml --tags projects_brew
	@bash -l -i -c 'notify "projects brew is done" "pimp-my-mac"'

ssh:
	./playbook-init.yml --tags ssh_config
	@bash -l -i -c 'notify "SSH config is done" "pimp-my-mac"'

debug:
	./playbook-init.yml --list-tags
	@bash -l -i -c 'notify "debug is done" "pimp-my-mac"'

git:
	./playbook-init.yml --tags git
	@bash -l -i -c 'notify "git is done" "pimp-my-mac"'
