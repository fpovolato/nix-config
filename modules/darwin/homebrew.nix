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
      "tmux"
    ];

    casks = [
      # Normie Apps
      "spotify"
      "obsidian"

      # Content Creation
      "artcraft-launcher"

      # Terminal Stuff
      "ghostty"
      "font-jetbrains-mono-nerd-font"

      # Coding
      "chatgpt"
      "claude"
      "zed"

      # Browsers
      "zen"
      "helium-browser"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
