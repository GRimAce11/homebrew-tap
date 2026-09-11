class Keel < Formula
  desc "Create, understand, and maintain iOS projects from the terminal"
  homepage "https://github.com/GRimAce11/Keel"
  url "https://github.com/GRimAce11/Keel/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "28ec69f803a8104b3f4efda1d28246f9e19ffd74cc4641f66ddf1e3c9109eef4"
  license "MIT"
  head "https://github.com/GRimAce11/Keel.git", branch: "main"

  # Package.swift declares swift-tools-version 6.1, which ships with Xcode 16.3.
  depends_on xcode: ["16.3", :build]
  depends_on macos: :ventura

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
