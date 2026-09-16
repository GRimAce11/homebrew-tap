class Keel < Formula
  desc "Create, understand, and maintain iOS projects from the terminal"
  homepage "https://github.com/GRimAce11/Keel"
  url "https://github.com/GRimAce11/Keel/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "f5b437f79179b317ba10dc4a4829160d443dcc01adc2e007b4f0853ef2363369"
  license "MIT"

  head "https://github.com/GRimAce11/Keel.git", branch: "main"

  bottle do
    root_url "https://github.com/GRimAce11/homebrew-tap/releases/download/bottle-1.3.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f1ed389a252d32934ff03bb5db949964de917a62aee3e6c5f0c44f3ffc6fece7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "00c41b87459077a4690d259c89c7ec982415f04e6d729005b476305c434fc2ff"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2d5f11cb76d0d747eb1840e286a5cb30a903387c145c9fdd42cf34e5c723c617"
  end


  # Swift 6.0 tools, which ship with Xcode 16.0. This said Xcode 16.3 and
  # :ventura for several releases, which promised an install that could not
  # work — 16.3 cannot be installed before macOS 15, so a Sonoma user got a
  # compile error rather than a binary. v1.2.1 lowered the tools version, and
  # this is the first formula that can honestly reach back to Sonoma.
  #
  # Keel runs on Ventura; it is the build that cannot happen there.
  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
    # --disable-sandbox: SwiftPM resolves swift-argument-parser and swift-syntax
    # over the network, which Homebrew's build sandbox blocks.
    system "swift", "build", "--disable-sandbox", "-c", "release"

    # Keel's templates ship inside a SwiftPM resource bundle, and Bundle.module
    # looks for it beside the executable. Installing the binary alone leaves
    # `keel new` dying at run time on a bundle that was never copied.
    #
    # They go in libexec together, reached through an exec script rather than a
    # symlink: Bundle.main resolves to the directory of the path that was
    # invoked, so a symlink in bin sends Keel looking for the bundle in bin,
    # where it is not. An exec script runs the real path instead.
    libexec.install ".build/release/keel"
    libexec.install ".build/release/Keel_KeelKit.bundle"
    bin.write_exec_script libexec/"keel"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/keel --version")

    # Generation is what is worth proving: a binary that runs but writes a
    # broken project would sail past a version check.
    system bin/"keel", "new", "BrewProbe", "--yes", "--minimal"
    assert_predicate testpath/"BrewProbe/BrewProbe.xcodeproj/project.pbxproj", :exist?

    # And that it can read back what it wrote.
    assert_match "BrewProbe", shell_output("#{bin}/keel inspect BrewProbe")
  end
end
