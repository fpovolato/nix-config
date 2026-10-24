{
  description = "NixOS and macOS configuration";

  inputs = {
    # NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # macOS
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Homebrew installation manager
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-darwin,
    nix-homebrew,
    ...
  }: {
    # NixOS desktop
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/nixos
      ];
    };

    # MacBook Pro M2
    darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        ./hosts/macbook
      ];
    };
  };
}
