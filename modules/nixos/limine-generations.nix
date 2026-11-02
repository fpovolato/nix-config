{ config, lib, modulesPath, pkgs, ... }:

# Limine menu layout: the newest NixOS generation is a top-level entry and the
# older ones are grouped in a collapsed "Previous generations" submenu.
#
# The NixOS Limine module has no option for this, so its install script is
# patched with ./limine/generations.patch. The script, with the JSON
# configuration already substituted, is taken from the upstream module itself,
# so all boot.loader.limine options keep working. After a Nixpkgs update, a
# patch that no longer applies fails the build instead of the boot menu.
let
  upstream = import "${modulesPath}/system/boot/loader/limine/limine.nix" {
    inherit config lib pkgs;
  };

  # Find system.build.installBootLoader among the module's mkMerge/mkIf blocks.
  upstreamInstaller =
    let
      blocks = map (block: block.content or block) upstream.config.contents;
      withInstaller = lib.findFirst (block: block ? system.build.installBootLoader) (throw
        "limine-generations.nix: installBootLoader not found in the NixOS Limine module"
      ) blocks;
    in
    withInstaller.system.build.installBootLoader;
in
{
  system.build.installBootLoader = lib.mkForce (
    pkgs.runCommand "limine-install" { nativeBuildInputs = [ pkgs.patch ]; } ''
      cp ${upstreamInstaller} $out
      chmod u+w $out
      patch --no-backup-if-mismatch $out ${./limine/generations.patch}
      chmod +x $out
    ''
  );
}
