{ lib, ... }:

let
  # File extension (without the dot) -> bundle ID of the default app that opens it.
  associations = { };

  setDefaultApps = ./file-associations/set-default-apps.swift;
in
{
  # macOS has no declarative setting for default apps. A Swift script, run by
  # the Command Line Tools' swift, registers them through NSWorkspace. duti was
  # used before, but macOS 27 rejects its handler calls for dynamic types.
  # Skipped while no association is declared.
  home.activation.setFileAssociations = lib.mkIf (associations != { }) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if /usr/bin/xcode-select -p >/dev/null 2>&1; then
      run /usr/bin/swift ${setDefaultApps} ${
        lib.escapeShellArgs (lib.concatLists (lib.mapAttrsToList (extension: bundleId: [
          extension
          bundleId
        ]) associations))
      } || warnEcho "Some default app associations could not be set."
    else
      warnEcho "Command Line Tools are not installed; skipping default app associations."
    fi
  '');
}
