# Code Hygiene Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix typos, remove dead code, replace DMG installs with brew casks, automate VSCode extension management, and improve Makefile and README for easier onboarding.

**Architecture:** All changes are confined to existing files — no new modules or roles. The monolithic playbook structure is intentional and preserved. Verification after each task uses `ansible-lint`.

**Tech Stack:** Ansible, Homebrew, bash, Make.

---

### Task 1: Fix typos in `playbook-init.yml`

**Files:**
- Modify: `playbook-init.yml` (lines 10, 200, 209, 331, 347, 348)

**Step 1: Run ansible-lint to capture baseline**

```bash
ansible-lint playbook-init.yml
```

Expected: some warnings, note the count. This is your before snapshot.

**Step 2: Fix `ignore_brew_erorrs` — variable declaration**

In `playbook-init.yml` line 10, change:
```yaml
    - ignore_brew_erorrs: yes
```
to:
```yaml
    # Set to `yes` so brew tasks do not abort the run for already-installed packages;
    # brew exits non-zero in that case, which would otherwise be treated as a failure.
    - ignore_brew_errors: yes
```

**Step 3: Fix `ignore_brew_erorrs` — all usages**

Replace every remaining occurrence of `ignore_brew_erorrs` with `ignore_brew_errors`.
There are four more: lines 200, 209, 331, 348.

```yaml
# line 200 — brew packages task
      failed_when: not ignore_brew_errors

# line 209 — brew casks task
      failed_when: not ignore_brew_errors

# line 331 — project brew packages
          failed_when: not ignore_brew_errors # do not fail

# line 348 — project brew casks
          failed_when: not ignore_brew_errors # do not fail
```

**Step 4: Fix `brew_cascs` tag**

Line 347, change:
```yaml
          tags: projects_brew_cascs
```
to:
```yaml
          tags: projects_brew_casks
```

**Step 5: Run ansible-lint**

```bash
ansible-lint playbook-init.yml
```

Expected: same or fewer warnings than baseline — no new ones.

**Step 6: Commit**

```bash
git add playbook-init.yml
git commit -m "fix: correct typos ignore_brew_errors and brew_casks tag"
```

---

### Task 2: Fix typos in documentation files

**Files:**
- Modify: `README.md` (line 3)
- Modify: `projects/personal/README.md` (line 1 or wherever "projec-related" appears)

**Step 1: Fix `README.md`**

Line 3, change:
```
Ansible playbook for consistent yet flexible congfiguration of your Mac machines.
```
to:
```
Ansible playbook for consistent yet flexible configuration of your Mac machines.
```

**Step 2: Fix `projects/personal/README.md`**

Change:
```
projec-related
```
to:
```
project-related
```

**Step 3: Commit**

```bash
git add README.md projects/personal/README.md
git commit -m "fix: correct spelling in README files"
```

---

### Task 3: Fix hardcoded `/Users/disfinder/` paths

**Files:**
- Modify: `projects/personal/project.bashrc` (lines 21–22, comments on 30–32)

**Step 1: Fix SDKMAN lines**

Lines 21–22, change:
```bash
export SDKMAN_DIR="/Users/disfinder/.sdkman"
[[ -s "/Users/disfinder/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/disfinder/.sdkman/bin/sdkman-init.sh"
```
to:
```bash
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

**Step 2: Clean up stale iTerm2 comments**

Lines 29–33 contain an auto-generated comment block left over from the iTerm2 shell integration installer. It references `/Users/disfinder/` in a comment and is no longer informative. Remove lines 29–33:

```bash
# To make it work right now, do:
#   source /Users/disfinder/.iterm2_shell_integration.bash

# This line was also added to /Users/disfinder/.bash_profile, so the next time you log in it will be loaded automatically.
```

The `test -e "${HOME}/.iterm2_shell_integration.bash"` line above it already handles the integration correctly and can stay.

**Step 3: Commit**

```bash
git add projects/personal/project.bashrc
git commit -m "fix: replace hardcoded home path with \$HOME"
```

---

### Task 4: Migrate DMG and application entries to brew casks

All five apps previously listed under `dmg_files` and `applications` are available as Homebrew casks. CheatSheet no longer works on macOS 14+ Sonoma; its free replacement is KeyClu.

**Files:**
- Modify: `projects/personal/project_vars.yaml`

**Step 1: Add casks to personal project**

In `projects/personal/project_vars.yaml`, the current `brew_casks` block is:
```yaml
brew_casks:
  - intellij-idea-ce
  - krita
  - pycharm-ce
```

Replace with:
```yaml
brew_casks:
  - choosy
  - intellij-idea-ce
  - keyclu      # replacement for CheatSheet (discontinued, broken on macOS 14+)
  - krita
  - pycharm-ce
  - teamviewer
  - telegram
  - vox
```

**Step 2: Commit**

```bash
git add projects/personal/project_vars.yaml
git commit -m "feat: migrate dmg/app installs to brew casks in personal project"
```

---

### Task 5: Remove dead `dmg_files` and `applications` blocks from playbook

**Files:**
- Modify: `playbook-init.yml`

**Step 1: Remove the `dmg_files` variable block**

Find and remove the entire block (currently lines 92–102):
```yaml
    - dmg_files:
        - name: Idea
          url: https://download.jetbrains.com/idea/ideaIC-2019.3.4-jbr8.dmg
          filename: ideaIC-2019.3.4-jbr8.dmg
        - name: Telegram
          url: https://telegram.org/dl/desktop/mac
          filename: telegram_latest.dmg
        - name: teamviewer
        - name: VOX
        - name: krita
          website: https://krita.org/en/
```

**Step 2: Remove the `applications` variable block**

Find and remove the entire block (currently lines 103–110):
```yaml
    - applications:
        # - name: CheatSheet
        #   url: https://www.mediaatelier.com/CheatSheet/
        #   filename: tbd
        # application gone, replacement needed
        - name: Choosy
          url: https://choosy.app/
          filename: tbd
```

**Step 3: Remove the two download tasks**

Find and remove the "Download applications" task block:
```yaml
    - name: Download applications
      tags: never
      get_url:
        url: "{{ item.url }}"
        dest: "{{ temp_folder }}/{{ item.filename }}"
      loop: "{{ applications }}"
      loop_control:
        label: "{{ item.name }}"
```

Find and remove the "Download dmg_files" task block:
```yaml
    - name: Download dmg_files
      tags: never
      get_url:
        url: "{{ item.url }}"
        dest: "{{ temp_folder }}/{{ item.filename }}"
      loop: "{{ dmg_files }}"
      loop_control:
        label: "{{ item.name }}"
```

**Step 4: Run ansible-lint**

```bash
ansible-lint playbook-init.yml
```

Expected: no errors referencing `dmg_files` or `applications`.

**Step 5: Commit**

```bash
git add playbook-init.yml
git commit -m "refactor: remove dead dmg_files and applications blocks"
```

---

### Task 6: Add VSCode extension installation task

**Files:**
- Modify: `playbook-init.yml`

**Step 1: Add the task block**

After the "Configure GitHub cli" task block (near the end of the playbook), add:

```yaml
    - name: Manage VSCode extensions
      # Requires VSCode to already be installed (brew_casks runs first under the brew tag).
      # `ignore_errors` is needed because `code` exits non-zero for already-installed
      # or already-absent extensions, which would otherwise abort the play.
      tags: vscode_extentions
      block:
        - name: Install enabled VSCode extensions
          command: "code --install-extension {{ item }}"
          loop: "{{ vscode_extentions }}"
          ignore_errors: yes

        - name: Uninstall disabled VSCode extensions
          command: "code --uninstall-extension {{ item }}"
          loop: "{{ vscode_extentions_disabled }}"
          ignore_errors: yes
```

**Step 2: Run ansible-lint**

```bash
ansible-lint playbook-init.yml
```

Expected: no new warnings.

**Step 3: Commit**

```bash
git add playbook-init.yml
git commit -m "feat: automate VSCode extension install/uninstall via ansible"
```

---

### Task 7: Add inline comments to non-obvious playbook sections

**Files:**
- Modify: `playbook-init.yml`

**Step 1: Comment the `never` tag convention above the debug3 task**

Find the "Debug projects data" task (currently around line 276):
```yaml
    - name: Debug projects data
      tags:
        - never
        - debug3
```

Add a comment immediately above it:
```yaml
    # Tasks tagged `never` are opt-in: they do not run during a normal play.
    # To invoke them explicitly: ./playbook-init.yml --tags debug3
    - name: Debug projects data
      tags:
        - never
        - debug3
```

**Step 2: Comment the project discovery chain**

Find the "Collect projects folders" task (currently around line 222):
```yaml
    - name: Collect projects folders
```

Add a comment block immediately above it:
```yaml
    # --- Project discovery ---
    # Projects are self-contained directories under projects/.
    # Each project can provide: project_vars.yaml, gitconfig, project.bashrc, ssh_config.
    # The three tasks below wire them up:
    #   1. find discovers project directories.
    #   2. set_fact builds a list of dicts with per-project file paths.
    #   3. include_vars loads each project_vars.yaml into a namespaced variable.
    # Downstream tasks then look up those vars by project name.
    - name: Collect projects folders
```

**Step 3: Commit**

```bash
git add playbook-init.yml
git commit -m "docs: add inline comments for non-obvious playbook sections"
```

---

### Task 8: Update Makefile

**Files:**
- Modify: `Makefile`

**Step 1: Rewrite the Makefile**

Replace the entire file with:

```makefile
.PHONY: all bash brew projects_brew ssh git screenshots vscode_extentions debug help

default: help

help:
	@echo "Available targets:"
	@echo "  make all              run the full playbook"
	@echo "  make bash             configure bash environment (dotfiles, symlinks)"
	@echo "  make brew             install all brew repositories, packages, and casks"
	@echo "  make projects_brew    install project-specific brew repos, packages, and casks"
	@echo "  make ssh              configure SSH (~/.ssh/config)"
	@echo "  make git              configure git dotfiles"
	@echo "  make screenshots      set macOS screenshot save folder"
	@echo "  make vscode_extentions install/uninstall VSCode extensions"
	@echo "  make debug            list all available playbook tags"

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
	./playbook-init.yml --tags macos_defaults --skip-tags always

vscode_extentions:
	./playbook-init.yml --tags vscode_extentions
	@bash -l -i -c 'notify "VSCode extensions done" "pimp-my-mac"'

debug:
	./playbook-init.yml --list-tags
	@bash -l -i -c 'notify "debug is done" "pimp-my-mac"'
```

**Step 2: Verify make help output**

```bash
make help
```

Expected output:
```
Available targets:
  make all              run the full playbook
  make bash             configure bash environment (dotfiles, symlinks)
  make brew             install all brew repositories, packages, and casks
  make projects_brew    install project-specific brew repos, packages, and casks
  make ssh              configure SSH (~/.ssh/config)
  make git              configure git dotfiles
  make screenshots      set macOS screenshot save folder
  make vscode_extentions install/uninstall VSCode extensions
  make debug            list all available playbook tags
```

**Step 3: Commit**

```bash
git add Makefile
git commit -m "feat: update Makefile with all targets and vscode_extentions target"
```

---

### Task 9: Expand README with Projects pattern section

**Files:**
- Modify: `README.md`

**Step 1: Replace the "custom settings" section**

Find the current `### custom settings` section and replace it with the expanded version below. This keeps all existing content and adds the projects schema, git_includeif explanation, and a minimal example.

Replace:
```markdown
### custom settings

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

> [!WARNING]
> `/` at the path's end is crucial for `dir:` value.
```

With:
```markdown
### Custom settings — the projects/ pattern

The `projects/` directory lets you maintain per-context configuration alongside the
main playbook without forking it. Each subdirectory of `projects/` is a **project**.

The playbook discovers projects automatically — no registration required. Just create
a directory and populate whichever files you need.

#### Files a project can provide

| File | Purpose |
|---|---|
| `project_vars.yaml` | Variables: brew packages, brew casks, brew repos, git includeif paths |
| `gitconfig` | Git identity and settings for this project's directories |
| `project.bashrc` | Shell customisations sourced after the main bash profile |
| `ssh_config` | SSH host entries merged into `~/.ssh/config` |

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
```

**Step 2: Run a quick sanity check**

```bash
grep -n "congfiguration\|projec-related\|/Users/disfinder" README.md projects/personal/README.md
```

Expected: no output (all fixed instances from earlier tasks are gone).

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: expand README with projects/ pattern reference"
```

---

### Final verification

```bash
ansible-lint playbook-init.yml
make help
grep -rn "/Users/disfinder/" bash/ projects/
```

Expected:
- `ansible-lint`: no errors, warnings same or fewer than baseline.
- `make help`: lists all 9 targets.
- `grep`: no output (no remaining hardcoded home paths in templated files).
