{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" "x86_64-darwin" ]
, scrubJobs ? true
}:

with import <nixpkgs/pkgs/top-level/release-lib.nix> {
  inherit supportedSystems scrubJobs;
  packageSet = import nixpkgs;
};

let

  platformPackageSet = {
    gcc = linux;
    clang = darwin;
    darwin.cctools = darwin;
  };

  packageSet = {
    inherit (pkgs) stdenv coreutils bash perl python nix nix-repl git vim hello;
    # linux stdenv
    inherit (pkgs) bzip2 ed gawk glibc gmp gnutar gzip which xz zlib;
    # darwin stdenv
    inherit (pkgs) cmake cpio libiconv;
  };

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
  // (mapTestOn platformPackageSet)
  // (mapTestOn (packagePlatforms packageSet));

in

  jobs
