{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" "x86_64-darwin" ]
}:

with import <nixpkgs/pkgs/top-level/release-lib.nix> {
  inherit supportedSystems;
  packageSet = import nixpkgs {};
};

let

  pkgs = import nixpkgs {};

  packageSet = {
    inherit (pkgs) stdenv coreutils bash perl python nix nix-repl git vim hello;
    # linux stdenv
    inherit (pkgs) bzip2 ed gawk gcc glibc gmp gnutar gzip which xz zlib;
    # darwin stdenv
    inherit (pkgs) clang cmake cpio libiconv;
    inherit (pkgs.darwin) cctools;
  };

  jobs = {

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-${pkgs.lib.nixpkgsVersion}";
      constituents =
        [ jobs.stdenv.x86_64-linux
          jobs.stdenv.x86_64-linux
        ];
      meta.description = "Release-critical builds for the Nixpkgs unstable channel";
    };

  } // (mapTestOn (packagePlatforms packageSet));

in

  jobs
