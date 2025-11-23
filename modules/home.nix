{
  config,
  pkgs,
  lib,
  inputs,
  pkgs-old,
  system,
  ...
}:

{
  home = {
    stateVersion = "25.05";

    shellAliases = {
      tmux = "${config.programs.tmux.package}/bin/tmux -u";
    };

    packages = with pkgs; [
      # Font
      nerd-fonts.jetbrains-mono
      # LSPs
      marksman
      typescript-language-server
      vscode-langservers-extracted
      nil
      bash-language-server
      # Tools
      neofetch
      typos
      xclip
      htop
      rsync
      util-linux
      ripgrep
      hexyl
      tree
      cmake
      docker
      ffmpeg
      wget
      inetutils
      # JS/TS
      nodejs_22
      typescript
      bun
      deno
      nodePackages.pnpm
      # Rust
      rustup
      # Python
      ruff
      python313
      uv
      # Git
      git-lfs
      act
      # Apps
      inputs.zen-browser.packages."${system}".default
      zed-editor
      vscode
      discord
      utm
      # gRPC
      protobuf
      grpcurl
      # AI stuff
      gemini-cli
      warp-terminal
    ];

    file =
      let
        zsh-theme-power-level-10k = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "3e2053a9341fe4cf5ab69909d3f39d53b1dfe772";
          sha256 = "sha256-6tWuayZgQd9pUrD3xKlUSmOFQCgZ96G3DB8ojgZ/a78=";
        };
        zsh-plugin-autosuggestions = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "0e810e5afa27acbd074398eefbe28d13005dbc15";
          sha256 = "sha256-85aw9OM2pQPsWklXjuNOzp9El1MsNb+cIiZQVHUzBnk=";
        };
      in
      {
        ".p10k.zsh".source = ../p10k-zsh;
        ".omz-custom/themes/powerlevel10k" = {
          source = "${zsh-theme-power-level-10k}";
          recursive = true;
        };
        ".omz-custom/plugins/zsh-autosuggestions" = {
          source = "${zsh-plugin-autosuggestions}";
          recursive = true;
        };
      };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };
  programs.gpg.enable = true;
  programs.git = import ./git.nix { inherit config; };
  programs.gh = import ./gh.nix { inherit pkgs; };
  programs.alacritty = import ./alacritty.nix { };
  programs.helix = import ./helix.nix { };
  programs.tmux = import ./tmux.nix { };
  programs.zsh = import ./zsh.nix { inherit config lib; };
  programs.gitui = {
    enable = true;
    package = pkgs-old.gitui;
  };
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };
}
