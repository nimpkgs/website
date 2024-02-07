{
  description = "nimpkgs website";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs.lib) genAttrs;
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = f: genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nim
          nim-atlas
          watchexec
          nodePackages.pnpm
        ];
      };
    });
  };
}
