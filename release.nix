{ nixpkgs ? <nixpkgs>
, packageList ? [ "nix" "nix-repl" "git" "vim" "tmux" ]
, supportedSystems ? [ "x86_64-linux" "x86_64-darwin" ]
, scrubJobs ? true
}:

let

  inherit (pkgs.lib) isDerivation isAttrs foldl' mapAttrs mapAttrsRecursive;
  inherit (release) mapTestOn pkgs packagePlatforms;

  filterAttrByPath = path: attr: pkgs.lib.setAttrByPath path (pkgs.lib.attrByPath path null attr);
  filterAttrsByPath = paths: attr: foldl' pkgs.lib.recursiveUpdate {} (map (x: filterAttrByPath x attr) paths);

  release = import <nixpkgs/pkgs/top-level/release-lib.nix> {
    inherit supportedSystems scrubJobs;
    packageSet = import nixpkgs;
  };

  filteredPackageSet = mapAttrs (n: v:
    if isDerivation v then v else pkgs.recurseIntoAttrs v
  ) (filterAttrsByPath (map (x: pkgs.lib.splitString "." x) packageList) pkgs);

  packageSet = {
    inherit (pkgs) stdenv;
  }
  // filteredPackageSet;

  jobs = {

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-${pkgs.lib.nixpkgsVersion}";
      constituents =
        [ jobs.stdenv.x86_64-linux
          jobs.stdenv.x86_64-darwin
        ];
      meta.description = "Release-critical builds for the Nixpkgs unstable channel";
    };

  }
  // (mapTestOn (packagePlatforms packageSet));

in

  jobs
