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
      ag
      bash
      binutils
      binutils-raw
      boehmgc
      boost
      bundler
      bzip2
      cabal2nix
      cacert
      coreutils
      curl
      elixir
      emacs25Macport
      erlang
      expat
      fzf
      gawk
      gdbm
      gettext
      ghc
      git
      gmp
      gmpxx
      gnugrep
      gnum4
      go
      gocode
      godef
      gzip
      iana_etc
      icu
      ipfs
      jq
      kerberos
      khd
      kwm
      libatomic_ops
      libcxx
      libcxxabi
      libedit
      libevent
      libffi
      libiconv
      libjpeg
      libpng
      libpng_apng
      libsodium
      libssh2
      libtiff
      libunwind
      libxml2
      libyaml
      llvm
      llvm_39
      lua
      lzma
      mosh
      ncurses
      nix
      nix-repl
      nix-zsh-completions
      nixStable
      nox
      npm2nix
      oniguruma
      openssh
      openssl
      pcre
      perl
      perl522
      protobuf
      python
      python3
      readline
      reattach-to-user-namespace
      ruby
      rustracerd
      sqlite
      tmux
      vimHugeX
      wxmac
      ycmd
      zlib
      zsh;
    lua51Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.lua51Packages) lua;
    };
    perlPackages = pkgs.recurseIntoAttrs {
      inherit (pkgs.perlPackages)
        CGI
        DBDSQLite
        DBI
        HTMLParser
        HTMLTagset
        IOTty
        WWWCurl;
    };
    python27Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.python27Packages)
        boost
        libxml2
        python;
    };
    python35Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.python35Packages)
        characteristic
        click
        dogpile_cache
        dogpile_core
        requests2
        setuptools;
    };
    vimPlugins = pkgs.recurseIntoAttrs {
      inherit (pkgs.vimPlugins)
        Gist
        ReplaceWithRegister
        Solarized
        Syntastic
        WebAPI
        YouCompleteMe
        commentary
        fugitive
        fzf-vim
        fzfWrapper
        polyglot
        repeat
        surround
        vim-addon-manager
        vim-eunuch
        vim-indent-object
        vim-nix
        vim-sort-motion;
    };
  };

  defaultSystemPackages = {
  };

  extraPackages = filterPkgs packageAttrs pkgs;
  overridePackages = optionalAttrs (elem "x86_64-darwin" supportedSystems) {
  }
  // optionalAttrs (systemPackageAttrs ? "x86_64-linux") (filterPkgs systemPackageAttrs.x86_64-linux (pkgsFor "x86_64-linux"))
  // optionalAttrs (systemPackageAttrs ? "i686-linux") (filterPkgs systemPackageAttrs.i686-linux (pkgsFor "i686-linux"))
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
