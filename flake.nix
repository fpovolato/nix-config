{
  description = "NixOS and macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-darwin.url =
      "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-secrets = {
      url = "git+ssh://git@github.com/fpovolato/nix-secrets.git?ref=main";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-darwin,
    nix-homebrew,
    nix-secrets,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs.privateFiles = nix-secrets;
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/nixos
      ];
    };

    darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
        ./hosts/macbook
      ];
    };
  };
}
