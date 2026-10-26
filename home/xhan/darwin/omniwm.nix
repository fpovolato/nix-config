{ config, lib, ... }:

let
  # Versioned OmniWM settings. OmniWM validates this file strictly, so it is
  # captured from the app's own canonical output instead of written by hand.
  settingsFile = ./omniwm/settings.toml;
in
{
  # Link to the working tree rather than the Nix store, so changes saved from
  # OmniWM's Settings window land in the repository and show up in `git diff`.
  # The link is only created once the file is tracked in the repository.
  home.file.".config/omniwm/settings.toml" = lib.mkIf (builtins.pathExists settingsFile) {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/home/xhan/darwin/omniwm/settings.toml";
    # Replace the regular file OmniWM writes before the link exists.
    force = true;
  };
}
