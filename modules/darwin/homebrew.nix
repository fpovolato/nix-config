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
      "gitleaks"
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
      "fastfetch"
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
      # Uninstall formulae and casks missing from this file, after installing
      # the listed ones. "zap" is avoided: it would also trash app data such as
      # ~/.config/omniwm, which links into this repository.
      cleanup = "uninstall";
    };
  };
}
