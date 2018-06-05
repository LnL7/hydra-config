{ packageAttrs ? [], systemPackageAttrs ? {}
, nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" "x86_64-darwin" ]
, scrubJobs ? true
}:

with import ./release-lib.nix {
  inherit supportedSystems scrubJobs;
  packageSet = import nixpkgs;
};

with lib;

let

  darwinPkgs = pkgsFor "x86_64-darwin";

  defaultPackages = {
  };

  defaultSystemPackages = {
  };

  extraPackages = {
  }
  // filterPkgs packageAttrs pkgs;

  overridePackages = {
  }
  // optionalAttrs (systemPackageAttrs ? "x86_64-linux") (filterPkgs systemPackageAttrs.x86_64-linux (pkgsFor "x86_64-linux"))
  // optionalAttrs (systemPackageAttrs ? "i686-linux") (filterPkgs systemPackageAttrs.i686-linux (pkgsFor "i686-linux"))
  // optionalAttrs (systemPackageAttrs ? "x86_64-darwin") (filterPkgs systemPackageAttrs.x86_64-darwin (pkgsFor "x86_64-darwin"));

  jobs = {

    manual = import (nixpkgs.path + "/doc") {};
    nixos = import (nixpkgs.path + "/nixos/doc/manual") {} // {
      recurseForDerivations = true;
    };

    tested = pkgs.releaseTools.aggregate {
      name = "nixpkgs-tested-${nixpkgsVersion}";
      constituents =
        [ jobs.manual
          jobs.nixos.manual
          jobs.nixos.manualEpub
        ];
    };
  }
  // mapTestOn (packagePlatforms defaultPackages)
  // mapTestOn (packagePlatforms extraPackages)
  // overridePackages;

in
  jobs
