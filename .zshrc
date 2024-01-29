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

export EDITOR="hx"
export VISUAL="hx"

# aliases

alias zshconf="hx ~/.zshrc"
alias tmux="tmux -u"
alias hl="hx -c $HOME/.config/helix-lite/config.toml"

# initialize p10k

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# nvm

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
