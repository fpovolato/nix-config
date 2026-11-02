{ zen-browser, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Flake inputs used by the user configuration.
    extraSpecialArgs = { inherit zen-browser; };

    users.xhan = import ../../home/xhan;
  };
}
