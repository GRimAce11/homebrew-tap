# homebrew-tap

Homebrew formulae for [Keel](https://github.com/GRimAce11/Keel).

```bash
brew install GRimAce11/tap/keel
```

Or tap first, if you would rather see what you are adding:

```bash
brew tap GRimAce11/tap
brew info keel
brew install keel
```

## Why a tap

Homebrew's core repository has notability requirements — stars, forks, watchers,
and a release history — that a young project does not meet. A tap has none, so
this is where Keel lives until core is a realistic option.

## Updating the formula for a new release

```bash
VERSION=1.0.3
curl -sL -o /tmp/keel.tar.gz \
  "https://github.com/GRimAce11/Keel/archive/refs/tags/v${VERSION}.tar.gz"
shasum -a 256 /tmp/keel.tar.gz
```

Put the tag in `url` and that digest in `sha256`. Both must change together: a
version bump with a stale digest fails the download, and a new digest against an
old tag installs the wrong thing.

## Bottles

A bottle is a precompiled binary Homebrew downloads instead of building.
Installing Keel from source takes about three minutes, and roughly 88% of that
is swift-syntax — 187,000 lines of generated code, optimised in release. Keel
itself is 3% of what compiles.

Bottles are built by the **Bottle** workflow rather than on anybody's machine:

```bash
gh workflow run bottle.yml -f version=1.2.0 --repo GRimAce11/homebrew-tap
```

Two reasons it lives in CI. Bottles are per-macOS-version *and* per
architecture, so one machine yields one bottle and covering the matrix needs
runners. And `brew bottle` is a developer command that has broken a working
Homebrew install before now.

The workflow builds on each runner, proves the bottled binary can actually
generate a project — not just report its version — publishes the bottles to a
`bottle-<version>` release here, and prints the `bottle do` block to paste into
the formula.

**Update the formula on a branch.** A malformed `bottle do` block breaks
installs for everyone until it is reverted.

A formula with no matching bottle still builds from source, so a user on an
uncovered platform is never stuck — they just wait the three minutes.

## License

The formula is MIT, matching Keel itself.
