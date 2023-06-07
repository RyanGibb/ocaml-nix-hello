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

  outputs = { self, nixpkgs, opam-nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (opam-nix.lib.${system})
          buildOpamProject
          materializedDefsToScope
          materializeOpamProject';
        package = "hello";
        query = {
          ocaml-base-compiler = "*";
        };
        overlay = final: prev: {
          "${package}" = prev.${package}.overrideAttrs (_: {
            # override derivation attributes, e.g. add additional dependacies
            buildInputs = [ ];
          });
        };
        resolved-scope =
          let scope = buildOpamProject { } package ./. query;
          in scope.overrideScope' overlay;
        materialized-scope =
          let scope = materializedDefsToScope
            { sourceMap.${package} = ./.; } ./package-defs.json;
          in scope.overrideScope' overlay;
      in rec {
        packages = {
          resolved = resolved-scope;
          materialized = materialized-scope;
          # to generate:
          #   cat $(nix eval .#package-defs --raw) > package-defs.json
          package-defs = materializeOpamProject' { } ./. query;
        };
        defaultPackage = packages.materialized.${package};
        devShells.default = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          buildInputs = [ packages."ocaml-lsp-server" ];
        };
      }
    );
}
