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
      "gh"
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
      "tuios"
      "fastfetch"
      "mkcert"
    ];

    # ZenNotes is not in homebrew/cask; its official tap provides it.
    taps = [ "zennotes/tap" ];

    casks = [
      # Normie Apps
      "spotify"
      "obsidian"
      "zennotes/tap/zennotes"

      # Content Creation
      "artcraft-launcher"

      # Terminal Stuff
      "ghostty"
      "font-jetbrains-mono-nerd-font"

      # Coding
      "chatgpt"
      "claude"
      "claude-code"
      "zed"

      # Browsers
      "zen"
      "helium-browser"
      # The "chromium" cask is disabled (fails the Gatekeeper check).
      "ungoogled-chromium"
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
