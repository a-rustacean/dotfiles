# p10k instant prompt

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zsh path

export ZSH="$HOME/.oh-my-zsh"

# theme

ZSH_THEME="powerlevel10k/powerlevel10k"

# plugins

plugins=(git zsh-autosuggestions node nvm npm rust)

# initialize omz

source $ZSH/oh-my-zsh.sh

# editor

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='hx'
else
  export EDITOR='vi'
fi

# aliases

alias zshconf="hx ~/.zshrc"
alias tmux="tmux -u"

# initialize p10k

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# nvm

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
