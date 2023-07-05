#!/bin/bash

########################
# Eternal bash history.
# ---------------------
export HISTCONTROL=ignoreboth:erasedups
# HISTSIZE=1000
# HISTFILESIZE=20000
shopt -s histappend
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;} history -a; history -c; history -r"
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=1000000
export HISTSIZE=2000000
export HISTTIMEFORMAT="[%F %T] "
#export HISTIGNORE="ls:ps:history"
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
# export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
########################


{% if ansible_architecture=='arm64' %}
PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
{% endif %}

source {{ dotfiles_folder }}/colors.bashrc
# GIT_PROMPT_START="\[\033[01;34m\]\t\[\033[01;33m\] @\h\[\033[01;34m\] \w\[\033[01;33m\] \[\033[00m\]"
# GIT_PROMPT_END="\[\033[01;34m\] \n\$\[\033[00m\] "
GIT_PROMPT_START="${green}\t${bold_yellow}@\h${bold_blue} \w\[\033[00m\]"
get_GIT_PROMPT_END(){ # since end is dynamic (k8s-dependent), we need to update it on every prompt
  GIT_PROMPT_END=" ${cyan}$(kubectx -c):$(kubens -c)${bold_blue}\n\$\[\033[00m\] "
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;} get_GIT_PROMPT_END"

 if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
     source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
 fi

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# AUTOJUMP
# add the following line to your ~/.bash_profile or ~/.zshrc file (and remember
# to source the file to update your current session):
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# If you use the Fish shell then add the following line to your ~/.config/fish/config.fish:
#   [ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish



alias gs='git status'
alias gl='git ls'
alias gd='git diff'
alias gdt='git difftool'

# no more atom
#alias atom='/Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron'
# code have its own bin
#alias code='/Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron'

if [ -t 1 ]
then
    # we have a tty
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
fi

# Add the following lines to your ~/.bash_profile:
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    echo "Source brew bash completion"
    source $(brew --prefix)/etc/bash_completion
  fi

#You should set GROOVY_HOME:
# export GROOVY_HOME=/usr/local/opt/groovy/libexec
# export PATH="${PATH}:~/opt/bin/maestro-cli/bin"

# if [ -f /usr/libexec/java_home ]; then
#     export JAVA_HOME=$(/usr/libexec/java_home)
# fi


grepssh()
  {
    grep $1 -C 1 ~/.ssh/config --color
  }



alias ls='gls --color'
alias ll='gls -lh --time-style long-iso --color'

#grc
source {{ dotfiles_folder }}/grc.bashrc
# alias ll='gls -lh --time-style long-iso'
if [ -f $(which bat) ]; then
  alias cat='bat'
fi

if [ -f $(which exa) ]; then
  alias ll='exa --long --all'
fi

if [ -f $(which lsd) ]; then
  alias ll='lsd --long --all'
  alias ls='lsd'
fi

if [ -f $(which duf) ]; then
  alias df='duf'
fi

if [ -f $(which dust) ]; then
  alias du='dust'
fi

if [ -f $(which curlie) ]; then
  alias curl='curlie'
fi

# color man
export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode – red
export LESS_TERMCAP_md=$(printf '\e[01;35m') # enter double-bright mode – bold, magenta
export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode – yellow
export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;36m') # enter underline mode – cyan


setTerminalText () {
    # echo works in bash & zsh
    local mode=$1 ; shift
    echo -ne "\033]$mode;$@\007"
}
stt_both  () { setTerminalText 0 $@; }
stt_tab   () { setTerminalText 1 $@; }
stt_title () { setTerminalText 2 $@; }

stt_tab ""

diff_meld() {
open -W -a Meld --args $1 $2

}


#export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8

# suppress annoying zsh message in Catalina
export BASH_SILENCE_DEPRECATION_WARNING=1

eval "$(gh completion -s bash)"

alias d='docker'
complete -F _docker d

# caws == color aws
# this order - for easier modification of string `aws foo --bar` -> `caws foo --bar`
caws()
    {
        # TODO: do not redirect to yq if help is in parameters
        aws --output yaml $@ | yq eval --colors
    }

# https://stackoverflow.com/questions/56448535/bash-function-preserving-tab-completion
complete -C aws_completer caws
alias aws='aws --color on'

alias kubectl="kubecolor" # grc has kubectl alias, but kubecolor looks better, even if has some issues
alias k="kubectl"
alias kk="$(which kubectl)"
## add kubectl completion
# source <(kubectl completion bash) # does not work. making /usr/local/etc/bash_completion.d file instead
complete -o default -o nospace -F __start_kubectl k
complete -o default -o nospace -F __start_kubectl kk
complete -o default -o nospace -F __start_kubectl kubecolor
complete -o default -o nospace -F __start_kubectl kubectl

# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null

# fzf key bindings
# ------------
{% if ansible_architecture=='arm64' %}
source /opt/homebrew/opt/fzf/shell/key-bindings.bash
{% else %}
source "/usr/local/opt/fzf/shell/key-bindings.bash"
{% endif %}


{% for project in projects_data -%}
{% if project.bashrc %}
source {{ dotfiles_folder }}/projects/{{ project.name }}/project.bashrc
{% endif %}
{% endfor %}

# pip packages
export PATH="${PATH}:${HOME}/Library/Python/3.8/bin"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

