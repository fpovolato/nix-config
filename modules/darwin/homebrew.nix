{ ... }:

{
  nix-homebrew = {
    enable = true;
    user = "xhan";
  };

  homebrew = {
    enable = true;

    enableZshIntegration = true;
    enableFishIntegration = true;

    brews = [
      "git"
      "fish"
      "eza"
      "bat"
      "ripgrep"
      "fd"
      "jq"
      "fzf"
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
