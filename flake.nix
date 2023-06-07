{
  inputs.opam-nix.url = "github:tweag/opam-nix";

  outputs = { self, opam-nix, ... }:
    let
      system = "x86_64-linux";
      inherit (opam-nix.lib.${system})
        buildOpamProject
        materializedDefsToScope
        materializeOpamProject';
      package = "hello";
      query = {
        ocaml-base-compiler = "*";
      };
      resolved-scope = buildOpamProject { } package ./. query;
      materialized-scope = materializedDefsToScope
        { sourceMap.${package} = ./.; } ./package-defs.json;
    in rec {
      packages = {
        resolved = resolved-scope;
        materialized.${system} = materialized-scope;
        # to generate:
        #   cat $(nix eval .#package-defs --raw) > package-defs.json
        ${system}.package-defs = materializeOpamProject' { } ./. query;
      };
      defaultPackage.${system} = packages.materialized.${system}.${package};
    };
}
