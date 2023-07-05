# Prerequisites
Install xcode cli development tools (you will need this anyhow).
To initiante request for installation, run `git` command in your terminal.

# How to start

Run this command in your terminal
```bash
mkdir -p ~/develop/com.github.gist/disfinder/pimp_my_mac/ && cd "$_" && git clone https://github.com/disfinder/pimp-my-mac.git .
```
## custom settings

Playbook will search for anything inside `projects` folder and process discovered data.
Multiproject configuration support:
- git configuration
- bash configuration
- variable configuration
- ssh configuration

`projects/PROJECTNAME/project_vars.yaml` must list git includedirs, if gitconfig usage is expected for the project:
```yaml
git_includeif:
  - dir:  ~/develop/com.github/PROJECTNAME/
    path: ~/opt/dotfiles/projects/PROJECTNAME/gitconfig
```

# Notes
## ansible-vault git diff
To make this work, add into `.gitattributes`
```
# or *.vault.yml, or *-vault.yml, or whatever convention you use for vaults
vault.yml diff=ansible-vault
```
[Honorable link](https://gist.github.com/leedm777/7776a91088aa176f6ad5) with quote:
> git runs this ansible-vault command from the root directory of the repository (irrespective of where you run git diff from). Therefore you will need to have an ansible.cfg file there that defines where the vault password file is relative to that directory. If your existing ansible.cfg with vault_password_file is lower in your tree, you will  need to make another one in root of repo for this diffing to work.  
Once I got that sorted, this gist was very helpful in getting my vault diffii ng to work. Thanks muchly.


# Todo
- https://github.com/ahmetb/kubectx
- https://github.com/ahmetb/kubectl-aliases
- https://github.com/ahmetb/kubectx#interactive-mode


