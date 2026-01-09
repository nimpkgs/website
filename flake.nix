{
  description = "nimpkgs website";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs.lib) genAttrs;
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = f: genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nim
          nimble
          watchexec
          pkgs.bun
        ];
      };
    });
  };
}
