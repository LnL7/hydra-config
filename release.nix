{ packageAttrs ? [], literalPackageAttrs ? []
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

  defaultPackages = {
    inherit pkgs;
    inherit (pkgs) stdenv;
  };

  extraPackages = filterPkgs packageAttrs;
  overridePackages = filterPkgs literalPackageAttrs;

  jobs = mapPlatformsOn (filterRecursive defaultPackages) // mapPlatformsOn extraPackages // {

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-${nixpkgsVersion}";
      constituents =
        [ jobs.stdenv.x86_64-linux
          jobs.stdenv.x86_64-darwin
        ];
    };

  } // overridePackages;

in
  jobs
