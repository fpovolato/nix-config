{ ... }:

{
  # Install Homebrew through Nix
  nix-homebrew = {
    enable = true;
    user = "xhan";
  };

  # Manage applications through Homebrew Bundle
  homebrew = {
    enable = true;

    enableZshIntegration = true;

    brews = [
      "git"
      "fish"
      "eza"
      "bat"
      "ripgrep"
      "fd"
    ];

    casks = [
      "ghostty"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
