#!/usr/bin/env bash
set -euo pipefail
repo=$(git rev-parse --show-toplevel)
cd "$repo"
# Scan tracked and untracked, non-ignored working-tree files. Deleted tracked
# files are absent here but remain covered by the history scan below.
snapshot=$(mktemp -d)
trap 'rm -rf "$snapshot"' EXIT
mkdir "$snapshot/source"
git ls-files --cached --others --exclude-standard -z > "$snapshot/paths"
while IFS= read -r -d '' file; do
  if [[ -e "$file" || -L "$file" ]]; then
    mkdir -p "$snapshot/source/$(dirname "$file")"
    # Copy symlinks as links, never the external files they may refer to.
    cp -P "$file" "$snapshot/source/$file"
  fi
done < "$snapshot/paths"
gitleaks dir --config "$repo/.gitleaks.toml" --redact "$snapshot/source"
# Include all local branches and tags; CI checks out full history.
gitleaks git --config "$repo/.gitleaks.toml" --redact --log-opts=--all .
