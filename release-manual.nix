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

    manual = import (nixpkgs.path + "/doc") {};
    nixos = import (nixpkgs.path + "/nixos/doc/manual") {} // {
      recurseForDerivations = true;
    };

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-unstable-${nixpkgsVersion}";
      constituents = [ ];
    };

    tested = pkgs.releaseTools.aggregate {
      name = "nixpkgs-tested-${nixpkgsVersion}";
      constituents =
        [ jobs.stdenv.x86_64-linux
          jobs.stdenv.x86_64-darwin
          jobs.cc.x86_64-linux
          jobs.cc.x86_64-darwin
          jobs.cc-unwrapped.x86_64-linux
          jobs.cc-unwrapped.x86_64-darwin

          jobs.tests.cc-wrapper.x86_64-linux
          jobs.tests.cc-wrapper.x86_64-darwin
          jobs.tests.stdenv-inputs.x86_64-linux
          jobs.tests.stdenv-inputs.x86_64-darwin
        ]
        ++ collect isDerivation jobs.makeBootstrapTools;
    };

    makeBootstrapTools =
      genAttrs supportedSystems
        (system: {
          inherit (import (nixpkgs + "/pkgs/stdenv/linux/make-bootstrap-tools.nix") { inherit system; })
            dist test;
        })
      # darwin is special in this
      // optionalAttrs (builtins.elem "x86_64-darwin" supportedSystems) {
        x86_64-darwin =
          let
            bootstrap = import (nixpkgs + "/pkgs/stdenv/darwin/make-bootstrap-tools.nix") { system = "x86_64-darwin"; };
          in {
            # Lightweight distribution and test
            inherit (bootstrap) dist test;
            # Test a full stdenv bootstrap from the bootstrap tools definition
            inherit (bootstrap.test-pkgs) stdenv;
          };
        };
  }
  // mapTestOn (packagePlatforms defaultPackages)
  // mapTestOn (packagePlatforms extraPackages)
  // overridePackages;

in
  jobs
