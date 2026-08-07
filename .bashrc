# ==============================
#  Basic Settings
# ==============================

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize

# ==============================
#  less / chroot
# ==============================

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


# ==============================
#  Prompt Settings
# ==============================

# Enable color prompt if supported
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "${force_color_prompt:-}" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (\[\033[01;33m\]%s\[\033[00m\])")\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(__git_ps1 " (%s)")\$ '
fi
unset color_prompt force_color_prompt

# Xterm title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac


# ==============================
#  Aliases - System
# ==============================

alias update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean"

# Alert after long-running command
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# using wsl
alias win-host='grep nameserver /etc/resolv.conf | awk "{print \$2}"'

# ==============================
#  Aliases - ls / grep
# ==============================

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ==============================
#  External Tools
# ==============================

# bash aliases file
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# mise
if [ -x "$HOME/dotfiles/bin/mise" ]; then
    eval "$("$HOME/dotfiles/bin/mise" activate bash)"
fi

# Zellij completion
if command -v zellij >/dev/null 2>&1; then
    source <(zellij setup --generate-completion bash)
    complete -F _zellij -o bashdefault -o default zj
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi
