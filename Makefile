default: help
help:
	@echo "Available targets:"
	@echo "  make screenshots:   configure screenshots folder"
	@echo "  make brew: 	     install all brew repositories, packages, casks"
	@echo "  make projects_brew: install only projects-based brew repos, packages, casks"

.PHONY: screenshots brew projects_brew

screenshots:
	./playbook-init.yml --tags macos_defaults --skip-tags always

brew:
	./playbook-init.yml --tags brew
projects_brew:
	./playbook-init.yml --tags projects_brew
