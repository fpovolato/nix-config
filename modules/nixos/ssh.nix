{
  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [ "xhan" ];
    };
  };

  users.users.xhan.openssh.authorizedKeys.keyFiles = [
    ../../keys/macbook.pub
  ];
}
