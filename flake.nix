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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      zig,
      zls,
      zen-browser,
      ...
    }:
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

      mkHomeManagerModule = system: path: extraPkgs: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users."${user}" = import path;
          extraSpecialArgs = {
            inherit
              system
              user
              hostname
              extraPkgs
              ;
          };
        };
      };

      mkSystem =
        system: host:
        let
          extraPkgs = {
            zig = zig.packages.${system}.nightly;
            zls = zls.packages.${system}.zls;
            zenHomeModule = zen-browser.homeModules.beta;
          };
        in
        {
          inherit system;
          specialArgs = {
            inherit
              system
              user
              hostname
              ;
          };
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager."${host}Modules".home-manager
            (mkHomeManagerModule system ./hosts/${host}/home.nix extraPkgs)
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

      formatter = builtins.mapAttrs (_: pkgs: pkgs.nixfmt-tree) nixpkgs.legacyPackages;
    };
}
