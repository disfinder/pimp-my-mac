.PHONY: all bash brew projects_brew ssh git screenshots vscode_extensions debug help

default: help

help:
	@echo "Available targets:"
	@echo "  make all               run the full playbook"
	@echo "  make bash              configure bash environment (dotfiles, symlinks)"
	@echo "  make brew              install all brew repositories, packages, and casks"
	@echo "  make projects_brew     install project-specific brew repos, packages, and casks"
	@echo "  make ssh               configure SSH (~/.ssh/config)"
	@echo "  make git               configure git dotfiles"
	@echo "  make screenshots       set macOS screenshot save folder"
	@echo "  make vscode_extensions install/uninstall VSCode extensions"
	@echo "  make debug             list all available playbook tags"

all:
	./playbook-init.yml
	@bash -l -i -c 'notify "ALL is done" "pimp-my-mac"'

bash:
	./playbook-init.yml --tags bash
	@bash -l -i -c 'notify "bash is done" "pimp-my-mac"'

brew:
	./playbook-init.yml --tags brew
	@bash -l -i -c 'notify "brew is done" "pimp-my-mac"'

projects_brew:
	./playbook-init.yml --tags projects_brew
	@bash -l -i -c 'notify "projects brew is done" "pimp-my-mac"'

ssh:
	./playbook-init.yml --tags ssh_config
	@bash -l -i -c 'notify "SSH config is done" "pimp-my-mac"'

git:
	./playbook-init.yml --tags git
	@bash -l -i -c 'notify "git is done" "pimp-my-mac"'

screenshots:
	# --skip-tags always suppresses project-discovery overhead for this lightweight one-shot target
	./playbook-init.yml --tags macos_defaults --skip-tags always

vscode_extensions:
	./playbook-init.yml --tags vscode_extensions
	@bash -l -i -c 'notify "VSCode extensions done" "pimp-my-mac"'

debug:
	./playbook-init.yml --list-tags
	@bash -l -i -c 'notify "debug is done" "pimp-my-mac"'
