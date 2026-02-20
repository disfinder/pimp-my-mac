# Code Hygiene Design

**Date:** 2026-02-20
**Scope:** Typo fixes, hardcoded paths, DMG → brew cask migration, VSCode extension automation, Makefile improvements, documentation.

## Goals

- Fix spelling mistakes in variable names, tags, and documentation.
- Replace hardcoded user paths with portable equivalents.
- Replace the dead `dmg_files`/`applications` mechanism with brew casks.
- Automate VSCode extension installation via Ansible.
- Make `make help` accurate and complete.
- Improve README and add inline comments for new adopters.

## Out of Scope

- Ansible roles (monolithic design is intentional).
- zsh support.
- macOS defaults expansion.
- Version pinning for brew packages.

---

## Section 1: Typo and Variable Name Fixes

| File | Current | Fixed |
|---|---|---|
| `playbook-init.yml` (var + `failed_when` references) | `ignore_brew_erorrs` | `ignore_brew_errors` |
| `playbook-init.yml` (tag on brew_casks task) | `brew_cascs` | `brew_casks` |
| `README.md` | `congfiguration` | `configuration` |
| `projects/personal/README.md` | `projec-related` | `project-related` |

Note: `vscode_extentions` spelling is retained intentionally for consistency with existing tags.

---

## Section 2: DMG Files and Applications → Brew Casks

All entries in `dmg_files` and `applications` are available as Homebrew casks. No download machinery needed.

### Mapping

| Old entry | Destination | Brew cask |
|---|---|---|
| Telegram | `projects/personal/project_vars.yaml` brew_casks | `telegram` |
| TeamViewer | `projects/personal/project_vars.yaml` brew_casks | `teamviewer` |
| VOX | `projects/personal/project_vars.yaml` brew_casks | `vox` |
| Choosy | `projects/personal/project_vars.yaml` brew_casks | `choosy` |
| CheatSheet (commented) | replace with free alternative | `keyclu` |
| Krita | already in `projects/personal` | no change |
| IntelliJ IDEA CE | already in `projects/personal` | no change |

CheatSheet stopped working on macOS 14 Sonoma. KeyClu is its free, actively maintained replacement (brew cask: `keyclu`).

### Removals from `playbook-init.yml`

- `dmg_files` variable block.
- `applications` variable block.
- "Download applications" task (was tagged `never`).
- "Download dmg_files" task (was tagged `never`).

---

## Section 3: Hardcoded User Paths

Two files reference `/Users/disfinder/` directly, breaking portability when adopted by another user.

| File | Replace with |
|---|---|
| `bash/bash.bashrc` (Python PATH additions) | `$HOME` |
| `projects/personal/project.bashrc` (iTerm2 integration) | `$HOME` |

---

## Section 4: VSCode Extension Installation

Add an Ansible task block to install/uninstall extensions using the `code` CLI, which ships with VSCode.

```yaml
- name: Install VSCode extensions
  tags: vscode_extentions
  block:
    - name: Install enabled extensions
      command: "code --install-extension {{ item }}"
      loop: "{{ vscode_extentions }}"
      ignore_errors: yes

    - name: Uninstall disabled extensions
      command: "code --uninstall-extension {{ item }}"
      loop: "{{ vscode_extentions_disabled }}"
      ignore_errors: yes
```

`ignore_errors: yes` is appropriate here because `code` returns non-zero for already-installed or already-absent extensions.

---

## Section 5: Makefile Improvements

Current `make help` only lists 3 of 8 targets. Update to list all targets with aligned descriptions, and add the new `vscode_extentions` target.

Targets after change: `all`, `bash`, `brew`, `projects_brew`, `ssh`, `git`, `screenshots`, `vscode_extentions`, `debug`.

---

## Section 6: README and Inline Comments

### README additions

Add a **Projects pattern** section covering:
- What the `projects/` directory is for.
- Which files a project can contain (`project_vars.yaml`, `gitconfig`, `project.bashrc`, `ssh_config`).
- The `project_vars.yaml` schema (supported keys: `git_includeif`, `brew_packages`, `brew_casks`, `brew_repositories`).
- How `git_includeif` routes git identity by working directory.
- A minimal example project.

### Inline comments in `playbook-init.yml`

- `ignore_brew_errors`: explain why it is `yes` (brew exits non-zero for already-installed packages).
- `never` tag convention: explain that tasks tagged `never` are opt-in and must be called explicitly.
- ansible-vault diff block: link to the README note explaining the `.gitattributes` requirement.
- Project discovery block: short comment explaining the find → set_fact → include_vars chain.
- `vscode_extentions` block: note that VSCode must already be installed (`brew_casks` runs first).

---

## Acceptance Criteria

- [ ] `ansible-lint` passes with no new warnings.
- [ ] `make help` lists every target.
- [ ] `make vscode_extentions` installs all extensions on a machine with VSCode present.
- [ ] No occurrences of `/Users/disfinder/` outside of `projects/` content files.
- [ ] No occurrences of `dmg_files` or `applications` variables in `playbook-init.yml`.
