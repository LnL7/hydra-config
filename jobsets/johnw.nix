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
      verasco
      SDL
      adns
      ag
      apr
      aprutil
      aria
      aspell
      atk
      autoconf
      automake
      bash
      bazaar
      bind
      binutils
      binutils-raw
      blas
      boehmgc
      boost
      bundler
      bzip2
      c-ares
      cabal2nix
      cacert
      cairo
      cloog
      clucene_core_2
      cmake
      compcert
      contacts
      coq
      coreutils
      csdp
      ctags
      curl
      cvs
      cyrus_sasl
      db
      dejavu_fonts
      diffstat
      diffutils
      dnsutils
      docutils
      dovecot
      doxygen
      ed
      emacs
      exiv2
      expat
      fetchmail
      ffmpeg
      findutils
      fontconfig
      freetype
      gd
      gdbm
      gdk_pixbuf
      gettext
      gfortran
      ghc
      ghostscriptX
      giflib
      gist
      git
      git-lfs
      glib
      global
      gmp
      gmpxx
      gnugo
      gnugrep
      gnum4
      gnumake
      gnupg
      gnuplot
      gnused
      gnutar
      gnutls
      go
      graphite2
      graphviz
      gsasl
      gss
      gtk-mac-integration
      gts
      gzip
      harfbuzz
      harfbuzz-icu
      host
      html-tidy
      httrack
      iana_etc
      icu
      idutils
      ijs
      ilmbase
      imagemagick_light
      imapfilter
      iperf
      isl_0_14
      jasper
      jbig2dec
      jdk
      jq
      jquery
      jre
      kerberos
      lame
      lcms
      lcms2
      leafnode
      less
      libarchive
      libassuan
      libatomic_ops
      libcxx
      libcxxabi
      libdevil
      libedit
      libevent
      libffi
      libgcrypt
      libgpgerror
      libiconv
      libidn
      libidn2
      libjpeg
      libksba
      libmng
      libmpc
      libogg
      libopus
      libpaper
      libpng
      libpng_apng
      libsodium
      libssh2
      libtasn1
      libtheora
      libtiff
      libtool
      libunistring
      libunwind
      libusb
      libusb1
      libuv
      libvdpau
      libvorbis
      libwebp
      libxml2
      libyaml
      llvm
      lua
      lzma
      lzo
      mercurial
      mesa
      mesa_drivers
      mesa_glu
      mesa_noglu
      mpfr
      msmtp
      mtr
      multitail
      ncurses
      nettle
      ninja
      nix
      nix-prefetch-bzr
      nix-prefetch-cvs
      nix-prefetch-git
      nix-prefetch-hg
      nix-prefetch-scripts
      nix-prefetch-svn
      nixStable
      nodejs
      nodejs-6_x
      npth
      ocaml
      oniguruma
      openexr
      openjdk
      openjpeg
      openldap
      openssh
      openssh_with_kerberos
      openssl
      p11_kit
      parallel
      patch
      patchutils
      pcre
      pcsclite
      pdnsd
      perl
      perl522
      pflogsumm
      pinentry
      pinentry_mac
      pixman
      pkgconfig
      poppler_min
      popt
      postgresql96
      potrace
      prooftree
      pth
      pv
      python
      python3
      readline
      ripgrep
      rlwrap
      rsync
      ruby
      sbcl
      screen
      serf
      setJavaClassPath
      sloccount
      socat2pre
      soxr
      sqlite
      stow
      subversion
      subversionClient
      tcl
      texinfo
      time
      tk
      tmux
      tree
      unbound
      universal-ctags
      unzip
      watch
      wget
      x264
      x265
      yuicompressor
      z3
      zip
      zlib
      znc
      zsh
      zziplib;

    texlive = pkgs.recurseIntoAttrs {
      combined = pkgs.recurseIntoAttrs { inherit (pkgs.texlive.combined) scheme-full; };
    };
    gitAndTools = pkgs.recurseIntoAttrs {
      inherit (pkgs.gitAndTools)
        gitFull
        gitflow
        hub;
    };
    gnome2 = pkgs.recurseIntoAttrs {
      inherit (pkgs.gnome2)
        gtk
        gtksourceview
        libart_lgpl
        libglade
        libgnomecanvas
        pango;
    };
    haskellPackages = pkgs.recurseIntoAttrs {
      inherit (pkgs.haskellPackages)
        alex
        cabal-install
        ghc
        ghc-mod
        happy
        hlint;
    };
    ocamlPackages = pkgs.recurseIntoAttrs {
      inherit (pkgs.ocamlPackages)
        findlib
        menhir
        zarith;
    };
    perlPackages = pkgs.recurseIntoAttrs {
      inherit (pkgs.perlPackages)
        BitVector
        CGI
        CarpClan
        DBDSQLite
        DBI
        DateCalc
        EncodeLocale
        FileListing
        HTMLParser
        HTMLTagset
        HTTPCookies
        HTTPDaemon
        HTTPDate
        HTTPMessage
        HTTPNegotiate
        IOHTML
        LWP
        LWPMediaTypes
        NetHTTP
        SubUplevel
        TermReadKey
        TestException
        URI
        WWWCurl
        WWWRobotRules;
    };
    python2Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.python2Packages)
        appnope
        backports_shutil_get_terminal_size
        boost
        cffi
        cryptography
        decorator
        docopt
        dulwich
        enum34
        hg-git
        idna
        ipaddress
        ipython
        ipython_genutils
        libxml2
        paramiko
        pathlib2
        pathpy
        pexpect
        pickleshare
        prompt_toolkit
        ptyprocess
        pyasn1
        pyasn1-modules
        pycparser
        pygments
        python
        pytz
        requests2
        setuptools
        simplegeneric
        six
        traitlets
        wcwidth;
    };
    python3Packages = pkgs.recurseIntoAttrs {
      inherit (pkgs.python3Packages)
        appnope
        decorator
        docopt
        docutils
        ipython
        ipython_genutils
        pathpy
        pexpect
        pickleshare
        prompt_toolkit
        ptyprocess
        pygments
        requests2
        setuptools
        simplegeneric
        six
        traitlets
        wcwidth;
    };
    xorg = pkgs.recurseIntoAttrs {
      inherit (pkgs.xorg)
        libICE
        libSM
        libX11
        libXau
        libXaw
        libXdmcp
        libXext
        libXft
        libXi
        libXmu
        libXpm
        libXrandr
        libXrender
        libXt
        libXtst
        libxcb
        pixman
        recordproto
        xauth
        xhost
        xproto;
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
