{
  boot.loader = {
    efi.canTouchEfiVariables = true;

    limine = {
      enable = true;
      maxGenerations = 10;
      enableEditor = false;
    };
  };
}
