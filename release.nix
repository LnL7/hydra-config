{ packageAttrs ? [ "hello" ], literalPackageAttrs ? []
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
    inherit (pkgs) stdenv
      autoconf automake bison bzip2 clang cmake coreutils cpio ed findutils flex gawk gettext gmp
      gnugrep gnum4 gnumake gnused groff gzip help2man libcxx libcxxabi libedit libffi libtool
      libxml2 llvm ncurses patch pcre perl pkgconfig python unzip xz zlib;
    darwin = pkgs.recurseIntoAttrs {
      inherit (pkgs.darwin)
        CF CarbonHeaders CommonCrypto Csu IOKit Libinfo Libm Libnotify Libsystem adv_cmds
        architecture bootstrap_cmds bsdmake cctools configd copyfile dyld eap8021x launchd
        libclosure libdispatch libiconv libpthread libresolv libutil objc4 ppp removefile xnu;
    };
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
