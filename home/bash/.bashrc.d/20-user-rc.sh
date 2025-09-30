# ~/.bashrc
export BASH_SILENCE_DEPRECATION_WARNING=1

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Homebrew bash-completion v2
if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
  . /opt/homebrew/etc/profile.d/bash_completion.sh
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash


eval "$(fnm env --use-on-cd --shell bash)"