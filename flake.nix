{
  description = "Darwin + Linux (non-nixOS) configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { home-manager, nix-darwin, nixpkgs, ... }: {
    # For Darwin, use nix-darwin and import Home Manager as a module.
    darwinConfigurations.work = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./darwin/configuration.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.config.allowUnfree = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.dilshad = import ./darwin/home.nix;
          };
        }
      ];
    };
    # For Linux (non-nixOS) use Home Manager directly.
    homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      pkgs = import nixpkgs { config.allowUnfree = true; };
      configuration = import ./linux/home.nix;
    };
  };
}
