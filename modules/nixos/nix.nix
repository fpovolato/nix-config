{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    max-jobs = "auto";
    cores = 0;

    http-connections = 50;
    max-substitution-jobs = 32;
  };
}
