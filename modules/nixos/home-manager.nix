{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.xhan = import ../../home/xhan;
  };
}
