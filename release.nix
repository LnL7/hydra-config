{ packageAttrs ? [ "hello" ], systemPackageAttrs ? {}
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
    inherit pkgs;
    inherit (pkgs) stdenv
      bash bison bzip2 coreutils ed findutils gawk gmp gettext gnugrep
      gnum4 gnumake gnused gzip ncurses patch pcre perl unzip xz zlib;
    perlPackages = pkgs.recurseIntoAttrs { inherit (pkgs.perlPackages) LocaleGettext; };
  }
  // optionalAttrs (elem "x86_64-linux" supportedSystems) {
    inherit (pkgs) gcc
      acl binutils busybox diffutils glibc isl libelf libmpc
      libsigsegv linuxHeaders m4 mpfr patchelf paxctl texinfo which;
  }
  // optionalAttrs (elem "x86_64-darwin" supportedSystems) {
    inherit (pkgs) clang
      autoconf automake cmake cpio flex groff help2man libcxx
      libcxxabi libedit libffi libtool libxml2 llvm pkgconfig python
      unzip;
  };

  defaultSystemPackages = {
  };

  extraPackages = {
  }
  // filterPkgs packageAttrs pkgs;

  overridePackages = {
    bootstrapTools = testOn supportedSystems (pkgs: pkgs.stdenv.bootstrapTools // { meta.platforms = platforms.all; });
    cc = testOn supportedSystems (pkgs: pkgs.stdenv.cc);
    cc-unwrapped = testOn supportedSystems (pkgs: pkgs.stdenv.cc.cc);
  }
  // optionalAttrs (elem "x86_64-darwin" supportedSystems) {
    darwin = {
      inherit (darwinPkgs.darwin)
        CF CarbonHeaders CommonCrypto Csu IOKit Libinfo Libm Libnotify Libsystem
        architecture bootstrap_cmds bsdmake cctools configd copyfile dyld eap8021x launchd
        libclosure libdispatch libiconv libpthread libresolv libutil objc4 ppp removefile xnu;
    };
  }
  // optionalAttrs (systemPackageAttrs ? "x86_64-linux") (filterPkgs systemPackageAttrs.x86_64-linux (pkgsFor "x86_64-linux"))
  // optionalAttrs (systemPackageAttrs ? "i686-linux") (filterPkgs systemPackageAttrs.i686-linux (pkgsFor "i686-linux"))
  // optionalAttrs (systemPackageAttrs ? "x86_64-darwin") (filterPkgs systemPackageAttrs.x86_64-darwin (pkgsFor "x86_64-darwin"));

  jobs = {

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
