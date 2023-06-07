{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    opam-nix.url = "github:tweag/opam-nix";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    opam-nix.inputs.opam-repository.follows = "opam-repository";
    opam-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, opam-nix, ... }:
    let
      system = "x86_64-linux";
      inherit (opam-nix.lib.${system}) buildOpamProject;
      package = "hello";
    in rec {
      packages.${system} = buildOpamProject { } package ./. {
        ocaml-base-compiler = "*";
      };
      defaultPackage.${system} = packages.${system}.${package};
    };
}
