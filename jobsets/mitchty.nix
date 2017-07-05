{ packageAttrs ? [ ], systemPackageAttrs ? {}
, nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-darwin" ]
, scrubJobs ? true
}:

with import ../release-lib.nix {
  inherit supportedSystems scrubJobs;
  packageSet = import nixpkgs;
};

with lib;

let

  defaultPackages = {
    inherit pkgs;
    inherit (pkgs) stdenv
      ack
      aria
      aspell
      bazaarTools
      cacert
      clang
      clang-analyzer
      cloc
      cscope
      ctags
      curl
      diffutils
      docbook5
      duply
      emacs
      entr
      gcc
      gdbm
      ghostscript
      gist
      gmp
      gnumake
      gnupg
      gnupg1compat
      gnutar
      gnutls
      graphviz-nox
      htop
      imagemagick
      iperf
      jq
      keychain
      lastpass-cli
      less
      llvm
      mercurial
      moreutils
      mosh
      mr
      multimarkdown
      multitail
      munge
      mutt
      nox
      openssl
      p7zip
      pandoc
      patchutils
      pbzip2
      pigz
      pixz
      pkgconfig
      pv
      rlwrap
      rsync
      rtags
      silver-searcher
      sloccount
      sqlite
      sshpass
      stack
      tmux
      tree
      unzip
      upx
      wakelan
      watch
      wget
      xz
      zlib;

    gitAndTools = pkgs.recurseIntoAttrs {
      inherit (pkgs.gitAndTools)
        git-extras
        gitFull;
    };
    haskellPackages = pkgs.recurseIntoAttrs {
      inherit (pkgs.haskellPackages)
        ghc-mod
        hasktags
        hindent
        hspec;
    };
    idrisPackages = pkgs.recurseIntoAttrs {
      inherit (pkgs.idrisPackages)
        idris;
    };
    python27Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.python27Packages)
        flake8
        howdoi
        pip
        pyflakes
        pylint
        virtualenv;
    };
    texlive = pkgs.recurseIntoAttrs {
      combined = pkgs.recurseIntoAttrs { inherit (pkgs.texlive.combined) scheme-full; };
    };
  };

  defaultSystemPackages = {
  };

  extraPackages = filterPkgs packageAttrs pkgs;
  overridePackages = optionalAttrs (elem "x86_64-darwin" supportedSystems) {
  }
  // optionalAttrs (systemPackageAttrs ? "x86_64-darwin") (filterPkgs systemPackageAttrs.x86_64-darwin (pkgsFor "x86_64-darwin"));

  jobs = {

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-${nixpkgsVersion}";
      constituents =
        [ jobs.stdenv.x86_64-darwin
        ];
    };

  }
  // mapPlatformsOn (filterRecursive defaultPackages)
  // mapPlatformsOn extraPackages
  // overridePackages;

in
  jobs
