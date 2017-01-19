{ packageAttrs ? [], literalPackageAttrs ? []
, nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" "x86_64-darwin" ]
, scrubJobs ? true
, packageList ? [ "nix" "nix-repl" "zsh" "silver-searcher" "jq" "fzf" "vim" "tmux" ]
}:

with import ./release-lib.nix {
  inherit supportedSystems scrubJobs;
  packageSet = import nixpkgs;
};

with lib;

let

  extraPackages = filterPkgs packageAttrs;
  overridePackages = filterPkgs literalPackageAttrs;

  jobs = mapPlatformsOn (filterRecursive pkgs) // mapPlatformsOn extraPackages // {

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-${nixpkgsVersion}";
      constituents =
        [ jobs.stdenv.x86_64-linux or null
          jobs.stdenv.x86_64-darwin or null
        ];
    };

  } // overridePackages;

in
  jobs
