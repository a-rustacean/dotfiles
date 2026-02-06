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

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls-overlay = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig-overlay";
    };
  };

  outputs =
    {
      nix-darwin,
      nixpkgs,
      home-manager,
      zig-overlay,
      zls-overlay,
      ...
    }@inputs:
    let
      user = "dilshad";
      hostname = "work";

      darwinSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      systems = darwinSystems ++ linuxSystems;

      mkHomeManagerModule = system: path: pkgs: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users."${user}" = import path;
          extraSpecialArgs = {
            inherit
              inputs
              system
              user
              hostname
              pkgs
              ;
          };
        };
      };

      mkSystem =
        system: host:
        let
          zig = zig-overlay.packages.${system}.master;
          zls = zls-overlay.packages.${system}.zls.overrideAttrs (old: {
            nativeBuildInputs = [ zig ];
          });
          overlays = [
            (final: prev: {
              inherit zig zls;
            })
          ];
          pkgs = import nixpkgs {
            inherit system;
            inherit overlays;
          };
        in
        {
          inherit system;
          specialArgs = {
            inherit
              inputs
              system
              user
              hostname
              pkgs
              ;
          };
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager."${host}Modules".home-manager
            (mkHomeManagerModule system ./hosts/${host}/home.nix pkgs)
          ];
        };
    in
    {
      packages =
        nixpkgs.lib.genAttrs darwinSystems (system: {
          darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem (mkSystem system "darwin");
        })
        // nixpkgs.lib.genAttrs linuxSystems (system: {
          nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem (mkSystem system "nixos");
        });

      formatter = builtins.listToAttrs (
        map (system: {
          name = system;
          value = nixpkgs.legacyPackages.${system}.nixfmt-tree;
        }) systems
      );
    };
}
