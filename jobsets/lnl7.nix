{ packageAttrs ? [ ], systemPackageAttrs ? {}
, nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-darwin" ]
, scrubJobs ? true
}:

with import ../release-lib.nix {
  inherit nixpkgs supportedSystems scrubJobs;
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
      cmake
      consul
      coreutils
      curl
      elixir
      emacs
      emacsMacport
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
      neovim
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
      skhd
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
    haskellPackages = pkgs.recurseIntoAttrs {
      inherit (pkgs.haskellPackages) alex cabal-install happy;
    };
    luaPackages = pkgs.recurseIntoAttrs {
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
    python2Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.python2Packages)
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
    python3Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.python3Packages)
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
      LanguageClient-neovim = pkgs.vimPlugins.LanguageClient-neovim // {
        meta.platforms = platforms.all;
      };
      YouCompleteMe = pkgs.vimPlugins.YouCompleteMe // {
        meta.platforms = platforms.all;
      };
      inherit (pkgs.vimPlugins)
        Gist
        # LanguageClient-neovim
        ReplaceWithRegister
        Solarized
        Syntastic
        WebAPI
        # YouCompleteMe
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
  // mapTestOn (packagePlatforms defaultPackages)
  // mapTestOn (packagePlatforms extraPackages)
  // overridePackages;

in
  jobs
