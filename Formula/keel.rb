class Keel < Formula
  desc "Create, understand, and maintain iOS projects from the terminal"
  homepage "https://github.com/GRimAce11/Keel"
  url "https://github.com/GRimAce11/Keel/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "f5b437f79179b317ba10dc4a4829160d443dcc01adc2e007b4f0853ef2363369"
  license "MIT"

  head "https://github.com/GRimAce11/Keel.git", branch: "main"


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
