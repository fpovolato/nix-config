{
  # PipeWire provides audio for the desktop; wpctl (volume keys) and the
  # Quickshell volume widget talk to it through WirePlumber.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
}
