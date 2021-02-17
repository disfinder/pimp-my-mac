#!/usr/bin/env sh

echo "Installing homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing Ansible..."
brew install ansible

./playbook-init.yml
