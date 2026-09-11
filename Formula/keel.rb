class Keel < Formula
  desc "Create, understand, and maintain iOS projects from the terminal"
  homepage "https://github.com/GRimAce11/Keel"
  url "https://github.com/GRimAce11/Keel/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "f25b84151199c0f96e5fee56725bafad9e2a6eb489699a4278dcfb349d8e19d4"
  license "MIT"
  head "https://github.com/GRimAce11/Keel.git", branch: "main"

  # Package.swift declares swift-tools-version 6.1, which ships with Xcode 16.3.
  depends_on xcode: ["16.3", :build]
  depends_on macos: :ventura

  def install
    # --disable-sandbox: SwiftPM resolves swift-argument-parser and swift-syntax
    # over the network, which Homebrew's build sandbox blocks.
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/keel"
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
