{
  description = "NixOS and Nix-Darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nix-darwin,
      nixpkgs,
      home-manager,
      zen-browser,
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

      mkHomeManagerModule = system: path: {
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
              ;
          };
        };
      };

      mkSystem = system: host: {
        inherit system;
        specialArgs = {
          inherit
            inputs
            system
            user
            hostname
            ;
        };
        modules = [
          ./hosts/${host}/configuration.nix
          home-manager."${host}Modules".home-manager
          (mkHomeManagerModule system ./hosts/${host}/home.nix)
        ];
      };
    in
    {
      packages =
        nixpkgs.lib.genAttrs darwinSystems (system: {
          darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem (mkSystem "${system}" "darwin");
        })
        // nixpkgs.lib.genAttrs linuxSystems (system: {
          nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem (mkSystem "${system}" "nixos");
        });

      formatter = builtins.listToAttrs (
        map (system: {
          name = system;
          value = nixpkgs.legacyPackages.${system}.nixfmt-tree;
        }) systems
      );
    };
}
