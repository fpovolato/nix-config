{ lib, ... }:

let
  # File extension -> bundle ID of the default app that opens it.
  associations = {
    # OmniShell widgets (Luau), which macOS knows only as a dynamic type.
    ".luau" = "dev.zed.Zed";
  };

  duti = "/opt/homebrew/bin/duti";
in
{
  # macOS has no declarative setting for default apps. duti, installed through
  # Homebrew before Home Manager runs, registers them with Launch Services.
  home.activation.setFileAssociations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x ${duti} ]; then
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (extension: bundleId: ''
        run ${duti} -s ${lib.escapeShellArg bundleId} ${lib.escapeShellArg extension} all
      '') associations)}
    else
      warnEcho "duti is not installed; skipping default app associations."
    fi
  '';
}
