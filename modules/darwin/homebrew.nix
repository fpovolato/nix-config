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
      "starship"
      "eza"
      "bat"
      "ripgrep"
      "fd"
      "jq"
      "fzf"
      "neovim"
    ];

    casks = [
      # Terminal Stuff
      "ghostty"
      "font-jetbrains-mono-nerd-font"

      # Coding
      "chatgpt"

      # Browsers
      "zen"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
