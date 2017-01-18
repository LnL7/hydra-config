{ nixpkgs ? <nixpkgs>, lib ? (import nixpkgs {}).lib
, packageList ? [ "nix" "nix-repl" "zsh" "silver-searcher" "jq" "fzf" "vim" "tmux" ]
, supportedSystems ? [ "x86_64-linux" "x86_64-darwin" ]
, scrubJobs ? true
}:

with lib;

let

  pkgs = allPackages {};

  packageSet = import nixpkgs;

  allPackages = args: packageSet (args // {
    config.allowUnfree = false;
    config.inHydra = true;
  });

  hydraJob' = if scrubJobs then hydraJob else id;

  pkgsFor = system: pkgsForSystems."${system}" or (abort "unsupported system type: ${system}");

  pkgsForSystems = {
    "x86_64-linux" = allPackages { system = "x86_64-linux"; };
    "x86_64-darwin" = allPackages { system = "x86_64-darwin"; };
  };

  forAllSupportedSystems = systems: f:
    genAttrs (filter (x: elem x supportedSystems) systems) f;

  testOn = systems: f: forAllSupportedSystems systems
    (system: hydraJob' (f (pkgsFor system)));

  mapTestOn = mapAttrsRecursive
    (path: systems: testOn systems (pkgs: getAttrFromPath path pkgs));

  packagePlatforms = mapAttrs (name: value:
    let res = builtins.tryEval (
      if isDerivation value then
        value.meta.hydraPlatforms or (value.meta.platforms or platforms.all)
      else
        packagePlatforms value);
    in if res.success then res.value else []);

  mapPlatformsOn = attrs: (mapTestOn (packagePlatforms attrs));

  filterRecursive = mapAttrs (name: value:
    let res = builtins.tryEval (
      if isDerivation value then
        value
      else if value.recurseForDerivations or false || value.recurseForRelease or false then
        filterRecursive value
      else
        {});
      in if res.success then res.value else {});

  filterAttrByPath = path: attr: setAttrByPath path (attrByPath path null attr);
  filterAttrsByPath = paths: attr: foldl' recursiveUpdate {} (map (x: filterAttrByPath x attr) paths);

  defaultPackages = {
    inherit (pkgs) stdenv;
  };

  extraPackages = {
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
  }
  // filterAttrsByPath (map (x: splitString "." x) packageList) pkgs;

  jobs = {

    unstable = pkgs.releaseTools.aggregate {
      name = "nixpkgs-${nixpkgsVersion}";
      constituents =
        [ jobs.stdenv.x86_64-linux or null
          jobs.stdenv.x86_64-darwin or null
        ];
    };

  }
  // (mapPlatformsOn (filterRecursive defaultPackages))
  // (mapPlatformsOn extraPackages);

in
  jobs
