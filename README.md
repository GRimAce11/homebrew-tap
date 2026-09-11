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

The formula builds from source. There are no bottles, so the first install
compiles Keel and its two dependencies, which takes a few minutes.

## License

The formula is MIT, matching Keel itself.
