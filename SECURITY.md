# Security and publication

## Secret handling

Do not commit private keys, access tokens, passwords, credential files or
plaintext password hashes. Public SSH keys may be versioned; their comments
and fingerprints can still link machines or accounts.

Keep plaintext secrets outside the repository and the Nix store. Ignoring a
file in Git is not an access-control boundary. Nix store contents are readable
by local users; a private input repository alone does not make secrets safe.
The private `nix-secrets` input supplies SSH public keys and has tooling for
encrypted credentials. Runtime credential decryption is not integrated yet.
See the [Nix secrets guidance](https://nix.dev/manual/nix/stable/store/secrets).

## Automated checks

Gitleaks is declared through Homebrew on macOS and Nixpkgs on NixOS.
The repository extends its default rules without broad exclusions.

Enable the local hook in each clone:

```sh
git config --local core.hooksPath .githooks
```

The pre-commit hook scans staged content with `--redact`, using the policy
staged in `.gitleaks.toml`. It fails if scanning fails. It does not install
itself automatically in new clones, and Git hooks can be bypassed; CI is a
second check, not prevention of a secret reaching GitHub.

Run the full local check:

```sh
bash scripts/check-secrets.sh
```

Before activation, use the flake's pinned project tool instead:

```sh
nix shell --inputs-from . nixpkgs#gitleaks --command bash scripts/check-secrets.sh
```

The script scans current tracked and untracked, non-ignored files via a temporary
snapshot, then all locally reachable Git history (`--all`). Ignored runtime
state is excluded from the snapshot. History still includes files that were
previously committed and later ignored or deleted. External symlinks are not
copied by dereferencing them. Reports redact matching secret values.

GitHub Actions checks pushes and pull requests with a full-history checkout,
read-only repository permissions and no persisted checkout credentials.
Gitleaks 8.30.1 is downloaded with a fixed SHA-256 checksum; the checkout action
is pinned to a commit. Update versions and verified checksums together.
The CI job is named `gitleaks`; making it a required check needs a GitHub
branch rule and is not configured by merely adding this workflow.

Scanners do not detect every secret or personal identifier. Review diffs,
authors, commit messages, image metadata, generated files and application state.
Do not add blanket allowlists to silence a finding; verify and narrowly scope
any genuine false positive.

## Host security defaults

- NixOS SSH permits the configured user, forbids root login, and disables both
  password and keyboard-interactive authentication. It opens TCP port 22 in the
  host firewall. Review network reachability and restrict it to a trusted
  interface or VPN if appropriate for your network.
- macOS starts its screen saver and sleeps the display after five idle minutes;
  computer sleep is fifteen minutes. The password grace period is zero.
  Validate behavior on the installed macOS version after activation.
- FileVault must be enabled separately; this flake does not enforce it.
- OmniWM configuration is linked to the working tree and reloads live. Review
  patches and branch changes before applying them to a checkout used by the
  running application. See [docs/omniwm.md](docs/omniwm.md).

## Before making a repository public

1. Run both scans and review all branches and tags intended for publication.
2. Review commit author/committer identities and messages. A `noreply` Git
   address does not hide the author's name or rewrite previous commits.
3. Decide whether usernames, hostnames, hardware identifiers and public-key
   fingerprints are acceptable to publish. They are not authentication secrets.
4. Review GitHub-only branches, PRs, issues, releases, artifacts and Actions
   history separately; a local clone cannot establish that these are clean.
5. Verify licenses and third-party notices, then review the final diff.
6. If history was rewritten, coordinate the remote update and other clones
   before publication. Do not merge the old history back or push recovery refs.

A local rewrite does not remove data from GitHub, other clones, existing forks
or cached PR views. Recovery bundles contain the old data and must stay private.
Do not include them in release archives or upload them to the repository.

If a real credential is exposed, revoke or rotate it first; then assess history
cleanup. See [GitHub's removal guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
and [visibility-change guidance](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/setting-repository-visibility).

## Reporting

Do not paste credentials or private data into a public issue. If the repository
has GitHub private vulnerability reporting enabled, use its Security tab to
report privately. Otherwise contact the maintainer through an established
private channel. Private reporting is a GitHub setting, not enabled by this file.
