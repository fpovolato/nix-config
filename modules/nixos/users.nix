{ pkgs, ... }:

{
  # System-wide Fish registers it in /etc/shells and sets up completions and
  # the NixOS environment; Home Manager manages the user configuration.
  programs.fish.enable = true;

  users.users.xhan = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
}
