# Prerequisites
Install xcode cli development tools (you will need this anyhow).
To initiante request for installation, run `git` command in your terminal.

# How to start

Run this command in your terminal
```bash
mkdir -p ~/develop/com.github.gist/disfinder/pimp_my_mac/ && cd "$_" && git clone https://github.com/disfinder/pimp-my-mac.git .
```
## custom settings
### playbook values
Create `project_vars.yaml` - this file intentionally omitted from git (and included in .gitignore to prevent committing) - here you can put your own values.

Example:
```yaml
---
git_username: username
git_email: user@example.com
```
### bash values
Put anything project-specific bash configs (variables, aliases, etc) into file `project.bashrc`. It will be templated to your home directory (as `.project.bashrc`) and sourced in bashrc.
