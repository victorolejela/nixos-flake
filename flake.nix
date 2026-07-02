{
  description = "NixOS config with Home Manager + DevShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      };

      burpsuitepro = {
      type = "github";
      owner = "xiv3r";
      repo = "Burpsuite-Professional";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, burpsuitepro, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.venom = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
        ./forensics/default.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.venom = import ./home.nix;

	   
          environment.systemPackages = [
            inputs.burpsuitepro.packages.${system}.default
          ];
        }
      ];
    };

    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      buildInputs = [
        nixpkgs.legacyPackages.${system}.nodejs_20
        nixpkgs.legacyPackages.${system}.nodePackages.npm
        nixpkgs.legacyPackages.${system}.prisma-engines
        nixpkgs.legacyPackages.${system}.openssl
        nixpkgs.legacyPackages.${system}.pkg-config
      ];

      shellHook = ''
        export PRISMA_CLI_QUERY_ENGINE_TYPE=binary
        export PRISMA_ENGINES_CHECKSUM_IGNORE_MISSING=1
        echo "Prisma ready"
      '';
    };
  };
}
