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

    zig = {
      url = "github:silversquirl/zig-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-flake.follows = "zig";
    };
  };

  outputs =
    {
      nix-darwin,
      nixpkgs,
      home-manager,
      zig,
      zls,
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
          pkgs = nixpkgs.legacyPackages."${system}" // {
            zig = zig.packages.${system}.nightly;
            zls = zls.packages.${system}.zls;
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
