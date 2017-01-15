{ nixpkgs ? <nixpkgs>
, packageList ? [ "nix" "nix-repl" "zsh" "silver-searcher" "jq" "fzf" "vim" "tmux" ]
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
    inherit (pkgs)
      autoconf automake bison bzip2 clang cmake coreutils cpio ed findutils flex gawk gettext gmp
      gnugrep gnum4 gnumake gnused groff gzip help2man libcxx libcxxabi libedit libffi libtool
      libxml2 llvm ncurses patch pcre perl pkgconfig python unzip xz zlib;
    perlPackages = { inherit (pkgs.perlPackages) LocaleGettext; };
    darwin = {
      inherit (pkgs.darwin)
        CF CarbonHeaders CommonCrypto Csu IOKit Libinfo Libm Libnotify Libsystem adv_cmds
        architecture bootstrap_cmds bsdmake cctools configd copyfile dyld eap8021x launchd
        libclosure libdispatch libiconv libpthread libresolv libutil objc4 ppp removefile xnu;
    };

    inherit (pkgs) stdenv bash openssl curl git;
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
