{
  config,
  pkgs,
  lib,
  system,
  ...
}:

{
  home = {
    stateVersion = "26.05";

    shellAliases = {
      tmux = "${config.programs.tmux.package}/bin/tmux -u";
    };

    packages = with pkgs; [
      # Font
      nerd-fonts.jetbrains-mono
      # LSPs
      typescript-language-server
      vscode-langservers-extracted
      nil
      bash-language-server
      nixd
      just-lsp
      taplo
      # Tools
      fastfetch
      typos
      xclip
      htop
      rsync
      util-linux
      ripgrep
      hexyl
      tree
      gnumake
      gcc
      cmake
      docker
      ffmpeg
      wget
      inetutils
      openblas
      llvmPackages_20.clang-tools
      llvm
      lld
      protobuf
      xz
      # JS/TS
      nodejs_24
      typescript
      bun
      deno
      pnpm
      oxlint
      # Rust
      rustup
      # Python
      ruff
      python313
      uv
      # Git
      git-lfs
      # zig
      zig
      zls
    ];

    file = {
      ".p10k.zsh".source = ../p10k-zsh;
      ".omz-custom/themes/powerlevel10k" = {
        source = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
        recursive = true;
      };
      ".omz-custom/plugins/zsh-autocomplete" = {
        source = "${pkgs.zsh-autocomplete}/share/zsh-autocomplete";
        recursive = true;
      };
      ".omz-custom/plugins/zsh-autosuggestions" = {
        source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
        recursive = true;
      };
      ".omz-custom/plugins/zsh-autopair/zsh-autopair.plugin.zsh".source = "${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };
  programs.gpg.enable = true;
  programs.gitui.enable = true;
  programs.git = import ./git.nix { inherit config; };
  programs.alacritty = import ./alacritty.nix { inherit system; };
  programs.helix = import ./helix.nix { inherit pkgs; };
  programs.tmux = import ./tmux.nix { };
  programs.zsh = import ./zsh.nix { inherit config lib; };
  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };
}
