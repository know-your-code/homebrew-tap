# homebrew-tap

[Homebrew](https://brew.sh) tap for installing
[Know Your Code](https://knowyourco.de) on macOS and Linux.

## Install

```sh
brew install know-your-code/tap/kyc
```

(or `brew tap know-your-code/tap` once, then `brew install kyc`.)

First-time install triggers the RFC 8628 device-code sign-in flow:
brew opens a sign-in URL printed in the terminal, the user enters
the displayed code on `knowyourco.de/verify`, and brew picks up the
issued license file from the backend before linking the binary.
See the install copy on [knowyourco.de/download](https://knowyourco.de/download).

## Layout

| Path | What |
|---|---|
| `Formula/kyc.rb` | The `kyc` formula. Pinned to a specific release tarball + sha256 from `id.knowyourco.de/release/...`. |
| `lib/kyc_license_download_strategy.rb` | Custom Homebrew download strategy that attaches the `Authorization: Kyc-License` header on resource download. Without this, brew can't fetch the tarball (the worker 401s anonymous requests). |

## Updating the formula

`know-your-code`'s release workflow opens a PR against this tap when
a new tag is cut. The PR bumps the URL + sha256 for both arm64 and
x86_64 mac bottles. Review + merge; users pick up the new version on
their next `brew upgrade`.

The PR is generated from a template in `know-your-code`'s
`.github/workflows/release.yml`; the formula header lives there.
Don't edit `Formula/kyc.rb` directly unless you're patching the
strategy or fixing an out-of-band issue — your edit will be
overwritten by the next release PR.

## Trust model

The tarball at `id.knowyourco.de/release/<version>/<archive>` is
behind a license check (Ed25519-verified bearer credential). brew
itself doesn't see the verification — that happens in the
`KycLicenseDownloadStrategy`. The verifying pubkey is baked into the
released `kyc` binary; the strategy doesn't independently verify.

For the apt distribution path (Debian/Ubuntu), see
[`know-your-code/kyc-apt-transport`](https://github.com/know-your-code/kyc-apt-transport)
which has its own GPG-based trust anchor.

## Related

- [`know-your-code/know-your-code`](https://github.com/know-your-code/know-your-code) — main Rust monorepo. The release workflow there opens PRs here.
- [`know-your-code/cloudflare-keygen-worker`](https://github.com/know-your-code/cloudflare-keygen-worker) — issues the bearer credential the strategy attaches.
