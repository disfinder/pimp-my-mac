#!/usr/bin/env sh

echo "Installing homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


(echo; echo 'eval "\$(${HOMEBREW_PREFIX}/bin/brew shellenv)"') >> /Users/$USER/.zprofile
eval "\$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

echo "Installing Ansible..."
brew install ansible

./playbook-init.yml
