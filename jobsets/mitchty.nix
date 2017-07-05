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
      NSPlist
      PlistCpp
      ack
      adns
      ag
      apr
      aprutil
      aria
      asciidoc
      aspell
      autoconf
      autogen
      automake
      autoreconfHook
      bash
      bazaarTools
      binutils
      bison
      boehmgc
      boost
      bzip2
      c-ares
      cacert
      cairo
      clangAnalyzer
      cloc
      cmake
      coreutils
      cpio
      cscope
      ctags
      curl
      cyrus_sasl
      db
      dejavu_fonts
      diffutils
      docbook2x
      docbook5
      docbook_xml_xslt
      docutils
      duplicity
      duply
      ed
      emacs
      emacs25-nox
      emscriptenStdenv
      entr
      expat
      findXMLCatalogs
      findutils
      fixDarwinDylibNames
      flex
      fontconfig
      fontforge
      freetype
      gawk
      gcc
      gd
      gdbm
      gdk_pixbuf
      getopt
      gettext
      gettextWithExpat
      ghc
      ghostscript
      giflib
      gist
      git
      gitMinimal
      glib
      gmp
      gmp4
      gmpxx
      gnugrep
      gnulib
      gnum4
      gnumake
      gnupg
      gnupg1
      gnused
      gnustep-make
      gnutar
      gnutls
      gobjectIntrospection
      gperf
      gpgme
      graphite2
      graphviz-nox
      groff
      gts
      guile
      gzip
      harfbuzz
      help2man
      htop
      icu
      ijs
      ilmbase
      imagemagick
      indent
      intltool
      iperf
      jasper
      jbig2dec
      jq
      kerberos
      keychain
      lastpass-cli
      lcms
      lcms2
      less
      libarchive
      libassuan
      libatomic_ops
      libcxx
      libcxxabi
      libdevil-nox
      libedit
      libelf
      libev
      libevent
      libffi
      libgcrypt
      libgpgerror
      libgsf
      libiconv
      libidn
      libidn2
      libjpeg
      libksba
      libmng
      libmpc
      libpaper
      libpng
      libpng_apng
      librsvg
      librsync
      libssh2
      libtasn1
      libtiff
      libtool
      libungif
      libunistring
      libunwind
      libusb
      libusb1
      libuv
      libwebp
      libxml2
      libxslt
      libyaml
      llvm
      lua
      lzip
      lzma
      lzo
      man
      mercurial
      moreutils
      mosh
      mpfr
      mr
      multimarkdown
      multitail
      munge
      mutt
      ncftp
      ncurses
      nettle
      ninja
      nox
      npth
      oniguruma
      openexr
      openjpeg
      openldap
      opensp
      openssh
      openssl
      p11_kit
      p7zip
      pandoc
      patch
      patchutils
      pbzip2
      pcre
      perl
      perl524
      pigz
      pinentry_mac
      pixman
      pixz
      pkgconfig
      popt
      protobuf
      pth
      pugixml
      pv
      python
      python3
      re2c
      readline
      rhash
      rlwrap
      rsync
      rtags
      ruby
      scons
      serf
      sharutils
      sloccount
      sqlite
      sshpass
      stack
      subversion
      texinfo
      texinfo5
      tmux
      tree
      txt2man
      ucl
      unifdef
      unzip
      upx
      uthash
      w3m
      wakelan
      watch
      wget
      which
      xar
      xcbuild
      xib2nib
      xmlto
      zip
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
