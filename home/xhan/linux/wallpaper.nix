{ ... }:

{
  # hyprpaper draws the shared wallpaper on every monitor. It runs as a user
  # service started with the Hyprland session.
  services.hyprpaper = {
    enable = true;

    settings = {
      splash = false;

      wallpaper = [
        {
          # An empty monitor matches every output.
          monitor = "";
          path = "${../../../wallpapers/nixos-wallpaper-catppuccin-mocha.png}";
          fit_mode = "cover";
        }
      ];
    };
  };
}
