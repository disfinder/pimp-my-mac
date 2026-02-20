# Pimp my Mac

Ansible playbook for consistent yet flexible configuration of your Mac machines.

## Prerequisites

Install xcode cli development tools (you will need this anyhow).
To initiante request for installation, run `git` command in your terminal.

## How to start

Run this command in your terminal

```shell
# introduce java-like reversed domain name notation for saving git repositories locally
mkdir -p ~/develop/com.github/disfinder/pimp-my-mac/ && cd "$_" && git clone https://github.com/disfinder/pimp-my-mac.git .
```

### Custom settings — the projects/ pattern

The `projects/` directory lets you maintain per-context configuration alongside the
main playbook without forking it. Each subdirectory of `projects/` is a **project**.

The playbook discovers projects automatically — no registration required. Just create
a directory and populate whichever files you need.

#### Files a project can provide

| File                | Purpose                                                                      |
| ------------------- | ---------------------------------------------------------------------------- |
| `project_vars.yaml` | Variables: brew packages, brew casks, brew repositories, git includeif paths |
| `gitconfig`         | Git identity and settings for this project's directories                     |
| `project.bashrc`    | Shell customisations sourced after the main bash profile                     |
| `ssh_config`        | SSH host entries merged into `~/.ssh/config`                                 |

All files are optional. A project with only `project_vars.yaml` is valid.

#### `project_vars.yaml` schema

```yaml
# Routes git identity to specific working directories.
# The trailing / on dir: values is required by git's includeIf directive.
git_includeif:
  - dir:  ~/develop/com.github/PROJECTNAME/
    path: ~/opt/dotfiles/projects/PROJECTNAME/gitconfig

# Optional brew additions — merged with all other projects before installation.
brew_repositories: []
brew_packages:
  - some-tool
brew_casks:
  - some-app
```

#### Minimal example

```
projects/
└── mywork/
    ├── project_vars.yaml   # sets git_includeif + brew_packages
    ├── gitconfig           # name/email for work commits
    ├── project.bashrc      # work-specific aliases
    └── ssh_config          # SSH hosts for work servers
```

> [!WARNING]
> The trailing `/` on every `dir:` value under `git_includeif` is required.
> Without it git's `includeIf` will not activate for that directory.

## Notes

### ansible-vault git diff

To make this work, add into `.gitattributes`

```ini
# or *.vault.yml, or *-vault.yml, or whatever convention you use for vaults
vault.yml diff=ansible-vault
```

[Honorable link](https://gist.github.com/leedm777/7776a91088aa176f6ad5) with quote:
> git runs this ansible-vault command from the root directory of the repository (irrespective of where you run git diff from). Therefore you will need to have an ansible.cfg file there that defines where the vault password file is relative to that directory. If your existing ansible.cfg with vault_password_file is lower in your tree, you will  need to make another one in root of repo for this diffing to work.  
Once I got that sorted, this gist was very helpful in getting my vault diffii ng to work. Thanks muchly.

## Todo

- [x] https://github.com/ahmetb/kubectx
- [x] https://github.com/ahmetb/kubectx#interactive-mode
- [ ] https://github.com/ahmetb/kubectl-aliases
