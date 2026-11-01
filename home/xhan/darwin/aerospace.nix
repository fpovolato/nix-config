# AeroSpace user configuration. See docs/aerospace.md before changing it.
{ ... }:

{
  # Copied into the Nix store; apply changes with activation, then
  # `aerospace reload-config` (or Option+Shift+; Esc).
  xdg.configFile."aerospace/aerospace.toml".source = ./aerospace/aerospace.toml;
}
