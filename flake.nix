{
  inputs.opam-nix.url = "github:tweag/opam-nix";

  outputs = { self, opam-nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        system = "x86_64-linux";
        inherit (opam-nix.lib.${system}) buildOpamProject;
        package = "hello";
      in rec {
        packages.${system} = buildOpamProject { } package ./. {
          ocaml-base-compiler = "*";
        };
        defaultPackage.${system} = packages.${system}.${package};
      }
    );
}
