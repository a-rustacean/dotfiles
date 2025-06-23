{ config, lib }:

{
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;

  oh-my-zsh = {
    enable = true;
    custom = "${config.home.homeDirectory}/.omz-custom";
    theme = "powerlevel10k/powerlevel10k";
    plugins = [ "git" "zsh-autosuggestions" "node" "nvm" "npm" "rust" ];
  };

  initContent = lib.mkBefore ''
    # p10k instant prompt

    if [[ -r "$''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$''${(%):-%n}.zsh" ]]; then
      source "$''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$''${(%):-%n}.zsh"
    fi

    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    export PATH="$PATH:$HOME/.cargo/bin"
  '';
}
