{ packageAttrs ? [], systemPackageAttrs ? {}
, nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-darwin" ]
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
    inherit pkgs;
    inherit (pkgs) stdenv
      autoconf automake bison bzip2 clang cmake coreutils cpio ed findutils flex gawk gettext gmp
      gnugrep gnum4 gnumake gnused groff gzip help2man libcxx libcxxabi libedit libffi libtool
      libxml2 llvm ncurses patch pcre perl pkgconfig python unzip xz zlib;
    perlPackages = pkgs.recurseIntoAttrs { inherit (pkgs.perlPackages) LocaleGettext; };
  };

  # prefix attribute paths with pkgs to avoid overriding defaults
  extraPackages = {
    darwin = darwinPkgs.recurseIntoAttrs darwinPkgs.darwin;
  }
  // (optionalAttrs (systemPackageAttrs ? "x86_64-linux") (filterPkgs systemPackageAttrs.x86_64-linux (pkgsFor "x86_64-linux")))
  // (optionalAttrs (systemPackageAttrs ? "i686-linux") (filterPkgs systemPackageAttrs.i686-linux (pkgsFor "i686-linux")))
  // (optionalAttrs (systemPackageAttrs ? "x86_64-darwin") (filterPkgs systemPackageAttrs.x86_64-darwin (pkgsFor "x86_64-darwin")))
  // filterPkgs packageAttrs pkgs;

  jobs = {

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-${nixpkgsVersion}";
      constituents =
        [ jobs.stdenv.x86_64-linux or null
          jobs.stdenv.x86_64-darwin

          jobs.coreutils.x86_64-darwin
          jobs.llvm.x86_64-darwin
          jobs.clang.x86_64-darwin
          jobs.cmake.x86_64-darwin
          jobs.perl.x86_64-darwin
          jobs.python.x86_64-darwin

          jobs.darwin.CF
          jobs.darwin.Libsystem
          jobs.darwin.bootstrap_cmds
        ];
    };

  }
  // mapTestOn (packagePlatforms defaultPackages)
  // mapTestOn (packagePlatforms extraPackages);

in
  jobs
