{ supportedSystems, scrubJobs
, packageSet ? import nixpkgs, nixpkgs ? <nixpkgs>
, # Attributes passed to nixpkgs. Don't build packages marked as unfree.
  nixpkgsArgs ? { config = { allowUnfree = false; inHydra = true; }; }
}:

with import (nixpkgs + "/lib");

let
  releaseLib = import (nixpkgs + "/pkgs/top-level/release-lib.nix") {
    inherit supportedSystems packageSet scrubJobs nixpkgsArgs;
  };

  mapAttrByPath = path: attrs: setAttrByPath path (attrByPath path null attrs);
  filterAttrsByPath = paths: attrs: foldl' recursiveUpdate {} (map (x: mapAttrByPath x attrs) paths);
in

releaseLib // rec {
  filterPkgs = paths: pkgs: filterAttrsByPath (map (x: splitString "." x) paths) pkgs;
}
