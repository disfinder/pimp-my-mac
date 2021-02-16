#!/usr/bin/env sh

echo "Installing Ansible..."
pip install ansible

echo "Installing homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

./playbook-init.yml
