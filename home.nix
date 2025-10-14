{
  config,
  pkgs,
  lib,
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
      # Tools
      neofetch
      typos
      xclip
      htop
      rsync
      util-linux
      ripgrep
      rar
      hexyl
      tree
      cmake
      docker
      ffmpeg
      wget
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
      gitui
      # Bash
      bash-language-server
      # Apps
      discord
      utm
      # gRPC
      protobuf
      grpcurl
      # gradle
      gradle
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
        ".p10k.zsh".source = ./p10k-zsh;
        ".omz-custom/themes/powerlevel10k" = {
          source = "${zsh-theme-power-level-10k}";
          recursive = true;
        };
        ".omz-custom/plugins/zsh-autosuggestions" = {
          source = "${zsh-plugin-autosuggestions}";
          recursive = true;
        };
      };

    activation =
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      {
        copyApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          SOURCE_DIR=${apps}/Applications
          TARGET_DIR="$HOME/Applications/Home Manager Apps (Copied)"
          /usr/bin/sudo rm -rf "$TARGET_DIR"
          mkdir "$TARGET_DIR"
          ls "$TARGET_DIR"
          for SOURCE_FILE in $SOURCE_DIR/*; do
            TARGET_FILE="$TARGET_DIR/$(basename "$SOURCE_FILE")"
            $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$SOURCE_FILE" "$TARGET_FILE"
            $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$TARGET_FILE"
          done
        '';
      };
  };

  programs.ssh.enable = true;
  programs.gpg.enable = true;
  programs.home-manager.enable = true;
  programs.git = import ./programs/git.nix { inherit config; };
  programs.gh = import ./programs/gh.nix { inherit pkgs; };
  programs.alacritty = import ./programs/alacritty.nix { };
  programs.helix = import ./programs/helix.nix { };
  programs.tmux = import ./programs/tmux.nix { };
  programs.zsh = import ./programs/zsh.nix { inherit config lib; };
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
