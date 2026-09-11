class Keel < Formula
  desc "Create, understand, and maintain iOS projects from the terminal"
  homepage "https://github.com/GRimAce11/Keel"
  url "https://github.com/GRimAce11/Keel/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "6980b17bc15c7439bb3f123edf00d3403feae4e77546307c953929a5d56e2586"
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
    # `keel new` dying at run time on a bundle that was never copied, so the two
    # are installed together and bin gets a symlink to them.
    libexec.install ".build/release/keel"
    libexec.install ".build/release/Keel_KeelKit.bundle"
    bin.install_symlink libexec/"keel"
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
