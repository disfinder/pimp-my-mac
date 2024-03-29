# lets use grc-provided features
GRC_ALIASES=true
[ -f /opt/homebrew/etc/grc.sh ] && source /opt/homebrew/etc/grc.sh
return 0

GRC="$(type -p grc)"
if [ "$TERM" != dumb ] && [ -n "$GRC" ]; then
    alias colourify="$GRC -es --colour=auto"

    # alias ll='colourify ls -lh -G'
    # alias ls='colourify ls -G'
    #alias ll='colourify gls -lh --time-style long-iso --colo'
    #alias mtr='colourify mtr'
    alias as='colourify as'
    alias blkid='colourify blkid'
    alias configure='colourify ./configure'
    alias df='colourify df'
    alias diff='colourify diff'
    alias dig='colourify dig'
    alias docker-machine='colourify docker-machine'
    alias docker='colourify docker'
    alias du='colourify du'
    alias env='colourify env'
    alias free='colourify free'
    alias g++='colourify g++'
    alias gas='colourify gas'
    alias gcc='colourify gcc'
    alias getsebool='colourify setsebool'
    alias head='colourify head'
    alias ifconfig='colourify ifconfig'
    alias ip='colourify ip'
    alias iptables='colourify iptables'
    alias ld='colourify ld'
    alias ll='colourify gls -lh --time-style long-iso --color'
    alias ls='colourify gls --color -g'
    alias lsblk='colourify lsblk'
    alias lspci='colourify lspci'
    alias make='colourify make'
    alias mount='colourify mount'
    alias mvn='colourify mvn'
    alias netstat='colourify netstat'
    alias ping='colourify ping'
    alias ps='colourify ps'
    alias semanage='colourify semanage'
    alias tail='colourify tail'
    alias traceroute='colourify traceroute'
    alias traceroute6='colourify traceroute6'
fi
