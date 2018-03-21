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
      bashInteractive
      binutils
      boehmgc
      boost
      bundix
      bundler
      bzip2
      cabal2nix
      cacert
      cargo
      clang
      clang_39
      cmake
      consul
      coreutils
      curl
      elixir
      emacs
      emacs25Macport
      erlang
      expat
      fzf
      gawk
      gcc
      gdbm
      gettext
      gfortran
      ghc
      git
      gmp
      gmpxx
      gnugrep
      gnumake
      gnum4
      gnupg
      gnutls
      go
      gocode
      godef
      gzip
      htop
      iana_etc
      icu
      ipfs
      jq
      kerberos
      khd
      kwm
      libarchive
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
      lua
      lzma
      mosh
      mypy
      nano
      ncurses
      nix
      nix-index
      nix-repl
      nixStable
      nixUnstable
      nox
      npm2nix
      oniguruma
      openssh
      openssl
      pcre
      perl
      pinentry_mac
      postgresql
      postgresql96
      protobuf
      python
      python3
      readline
      reattach-to-user-namespace
      redis
      ripgrep
      rtags
      ruby
      rustc
      rustracerd
      screen
      shellcheck
      sqlite
      texinfoInteractive
      tmux
      vault
      vaultenv
      vimHugeX
      wxmac
      ycmd
      zlib
      znc
      zsh;
    haskell = pkgs.recurseIntoAttrs {
      packages = pkgs.recurseIntoAttrs {
        ghc7103 = pkgs.recurseIntoAttrs {
          inherit (pkgs.haskell.packages.ghc7103) ghc;
        };
        ghc802 = pkgs.recurseIntoAttrs {
          inherit (pkgs.haskell.packages.ghc802) ghc;
        };
        ghc822 = pkgs.recurseIntoAttrs {
          inherit (pkgs.haskell.packages.ghc802) ghc;
        };
      };
    };
    haskellPackages = pkgs.recurseIntoAttrs {
      inherit (pkgs.haskellPackages) alex cabal-install happy;
    };
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
        Babel
        PyStemmer
        alabaster
        apipkg
        backports_abc
        backports_ssl_match_hostname
        boost
        bootstrapped-pip
        certifi
        chardet
        configparser
        docutils
        enum34
        execnet
        flake8
        flaky
        funcsigs
        html5lib
        hypothesis
        idna
        imagesize
        jinja2
        libxml2
        libxslt
        linecache2
        markupsafe
        mccabe
        mock
        pbr
        pip
        psutil
        py
        pycodestyle
        pyflakes
        pygments
        pysocks
        pysqlite
        pytest
        pytest-expect
        pytest-forked
        pytest_xdist
        pytestrunner
        python
        pytz
        requests
        setuptools
        setuptools_scm
        simplejson
        singledispatch
        six
        snowballstemmer
        sphinx
        sphinxcontrib-websupport
        sqlalchemy
        tornado
        traceback2
        typing
        u-msgpack-python
        unittest2
        urllib3
        webencodings
        whoosh;
    };
    python35Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.python35Packages)
        bootstrapped-pip
        characteristic
        click
        dogpile_cache
        dogpile_core
        lxml
        pip
        requests2
        setuptools
        typed-ast;
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
