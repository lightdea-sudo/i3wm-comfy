#
# ~/.bashrc
#

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# prompt (two lines, bordered)
PS1='\[\e[36m\]╭─\[\e[0m\][\[\e[32m\]\u@\h\[\e[0m\]]─[\[\e[34m\]\w\[\e[0m\]]\n\[\e[36m\]╰─\[\e[32m\]❯\[\e[0m\] '

# fastfetch banner when a terminal opens in alacritty
if [ "$TERM" = "alacritty" ] && command -v fastfetch >/dev/null; then
  fastfetch
  echo
fi

# clear, then show the banner again
alias clear='command clear && fastfetch && echo'
