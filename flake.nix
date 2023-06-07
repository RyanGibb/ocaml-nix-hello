{
  inputs.opam-nix.url = "github:tweag/opam-nix";

  outputs = { self, opam-nix }:
    let
      system = "x86_64-linux";
      inherit (opam-nix.lib.${system}) buildOpamProject;
      package = "hello";
      overlay = final: prev: {
        "${package}" = prev.${package}.overrideAttrs (_: {
          # override derivation attributes, e.g. add additional dependacies
          buildInputs = [ ];
        });
      };
      overlayed-scope = let
        scope = buildOpamProject { } package ./. {
          ocaml-base-compiler = "*";
        };
        in scope.overrideScope' overlay; 
    in rec {
      packages.${system} = overlayed-scope;
      defaultPackage.${system} = packages.${system}.${package};
    };
}
