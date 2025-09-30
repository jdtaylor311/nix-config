export EDITOR="nvim"
export PAGER="less -R"
export HOMEBREW_NO_ENV_HINTS=1
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Images/:$PATH"

if command -v brew >/dev/null 2>&1; then
  eval "$($(brew --prefix)/bin/brew shellenv)"
fi

if [ -r /etc/bash_completion ]; then
  . /etc/bash_completion
elif [ -r "$(command -v brew >/dev/null 2>&1 && brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
fi

[ -f ~/.fzf.bash ] && . ~/.fzf.bash
[ -f ~/.config/fzf/key-bindings.bash ] && . ~/.config/fzf/key-bindings.bash
[ -f ~/.config/fzf/completion.bash ] && . ~/.config/fzf/completion.bash

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
