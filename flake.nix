{
  description = "NixOS and Nix-Darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.55.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig = {
      url = "github:silversquirl/zig-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-flake.follows = "zig";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      user = "dilshad";
      hostname = "work";

      mkSystem = system: host: {
        inherit system;
        specialArgs = {
          inherit
            system
            user
            hostname
            inputs
            ;
        };
        modules = [
          ./hosts/${host}
          home-manager."${host}Modules".home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./hosts/${host}/home.nix;
              extraSpecialArgs = {
                inherit
                  user
                  hostname
                  inputs
                  system
                  ;
              };
            };
          }
        ];
      };
    in
    {
      packages = builtins.mapAttrs (system: pkgs: {
        nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem (mkSystem system "nixos");
        darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem (mkSystem system "darwin");

        nixosConfigurations.live = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              user
              hostname
              inputs
              system
              ;
          };
          modules = [
            (
              { modulesPath, ... }:
              {
                imports = [
                  (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
                  ./hosts/nixos/configuration.nix
                ];
              }
            )
          ];
        };
      }) nixpkgs.legacyPackages;

      formatter = builtins.mapAttrs (_: pkgs: pkgs.nixfmt-tree) nixpkgs.legacyPackages;
    };
}
