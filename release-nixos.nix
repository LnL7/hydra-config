{ packageAttrs ? [], systemPackageAttrs ? {}
, nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" ]
, scrubJobs ? true
}:

with import ./release-lib.nix {
  inherit supportedSystems scrubJobs;
  packageSet = import nixpkgs;
};

with lib;

let
  removeMaintainers = set: if builtins.isAttrs set
    then if (set.type or "") == "derivation"
      then set // { meta = builtins.removeAttrs (set.meta or {}) [ "maintainers" ]; }
      else pkgs.lib.mapAttrs (n: v: removeMaintainers v) set
    else set;

  darwinPkgs = pkgsFor "x86_64-darwin";

  defaultPackages = {
    inherit pkgs;
    inherit (pkgs) stdenv;
  };

  # prefix attribute paths with pkgs to avoid overriding defaults
  extraPackages = filterAttrsByPath (map (x: ["pkgs"] ++ splitString "." x) packageAttrs) pkgs;
  overridePackages = {
  }
  // (optionalAttrs (systemPackageAttrs ? "x86_64-linux") (filterPkgs systemPackageAttrs.x86_64-linux (pkgsFor "x86_64-linux")))
  // (optionalAttrs (systemPackageAttrs ? "i686-linux") (filterPkgs systemPackageAttrs.i686-linux (pkgsFor "i686-linux")));

  jobs = {

    nixos = removeMaintainers (import ./release.nix {
      inherit nixpkgs supportedSystems;
    });

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-${nixpkgsVersion}";
      constituents = [ ];
    };

  }
  // mapPlatformsOn (filterRecursive defaultPackages)
  // mapPlatformsOn extraPackages
  // overridePackages;

in
  jobs
