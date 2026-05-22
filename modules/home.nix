{
  config,
  pkgs,
  lib,
  user,
  extraPkgs,
  ...
}:

{
  imports = [ extraPkgs.zenHomeModule ];

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
      bash-language-server
      nixd
      just-lsp
      taplo
      # Tools
      fastfetch
      typos
      xclip
      htop
      btop
      rsync
      util-linux
      ripgrep
      hexyl
      tree
      gnumake
      gcc
      cmake
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
      extraPkgs.zig
      extraPkgs.zls
      # cloudflare
      cloudflared
      cloudflare-warp
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
      ".omz-custom/plugins/zsh-autopair/zsh-autopair.plugin.zsh".source =
        "${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };
  programs.gpg.enable = true;
  programs.gitui.enable = true;
  programs.git = import ./git.nix { inherit config; };
  programs.alacritty = import ./alacritty.nix { inherit pkgs; };
  programs.helix = import ./helix.nix { inherit pkgs; };
  programs.zsh = import ./zsh.nix { inherit config lib; };
  programs.zen-browser = import ./zen.nix { inherit pkgs; };
  programs.nh = rec {
    enable = true;
    clean.enable = true;
    flake = if pkgs.stdenv.isDarwin then "/Users/${user}/.config/nix" else "/home/${user}/.config/nix";
    darwinFlake = flake;
    osFlake = flake;
  };
}
