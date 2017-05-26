{ packageSet, supportedSystems, scrubJobs
, system ? "x86_64-linux"
}:

let

  inherit (pkgs) lib;
  pkgs = pkgsFor system;

  pkgsFor = system: pkgsForSystems."${system}" or (abort "unsupported system type: ${system}");

  pkgsForSystems = {
    "armv7l-linux" = allPackages { system = "armv7l-linux"; };
    "i686-linux" = allPackages { system = "i686-linux"; };
    "x86_64-linux" = allPackages { system = "x86_64-linux"; };
    "x86_64-darwin" = allPackages { system = "x86_64-darwin"; };
  };

  allPackages = args: packageSet (args // {
    config.allowUnfree = false;
    config.inHydra = true;
  });

  hydraJob' = if scrubJobs then lib.hydraJob else lib.id;

in

with lib;

rec {

  inherit lib pkgs pkgsFor allPackages;

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

  mapAttrByPath = path: attrs: setAttrByPath path (attrByPath path null attrs);
  filterAttrsByPath = paths: attrs: foldl' recursiveUpdate {} (map (x: mapAttrByPath x attrs) paths);

  filterPkgs = paths: pkgs: filterAttrsByPath (map (x: ["pkgs"] ++ splitString "." x) paths) pkgs;

}
