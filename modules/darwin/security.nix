{
  # Use the macOS Touch ID PAM module for sudo authentication.
  security.pam.services.sudo_local.touchIdAuth = true;

  # Require authentication immediately after the screen saver or display sleep.
  system.defaults.screensaver = {
    askForPassword = true;
    askForPasswordDelay = 0;
  };
}
