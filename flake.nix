{
  description = "My personal NUR repository";
  inputs.nixpkgs = {
    url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  inputs.mvn2nix.url = "github:fzakaria/mvn2nix";
  outputs = { self, nixpkgs, mvn2nix, ... } @inputs:
    let
      pkgsForSystem = system: import nixpkgs {
        # ./overlay.nix contains the logic to package local repository
        overlays = [ mvn2nix.overlay (import ./overlay.nix) ];
        inherit system;
      };
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      packages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; }; };
        nixpkgs = nixpkgs;
        mvn2nix = mvn2nix;
        inherit system;
      });
      nixpkgs = nixpkgs;
    };
}
