{
  description = "NixOS config with Home Manager + Node/Prisma devShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {

    # 🖥️ NixOS system config
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
        }
      ];
    };

    # 🧪 Dev environment (Node + Prisma FIXED)
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        pkgs.nodejs_20
        pkgs.nodePackages.npm
        pkgs.prisma-engines
        pkgs.openssl
        pkgs.pkg-config
      ];

      shellHook = ''
  # Force Prisma to use binary mode
  export PRISMA_CLI_QUERY_ENGINE_TYPE=binary

  # These are optional; binary mode will pick up the correct engines from Nix
  export PRISMA_ENGINES_CHECKSUM_IGNORE_MISSING=1

  echo "✅ Prisma fully fixed for NixOS (binary mode)"
'';
    };
  };
}
