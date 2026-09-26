cask "libremerge" do
  os macos: "dmg", linux: "AppImage"

  version "0.9.4"
  sha256 arm:          "7f4ae9c25f093d4c34b7e6bdc634d67c9f49796907ac448a68d1d89799d97f15",
         intel:        "7f4ae9c25f093d4c34b7e6bdc634d67c9f49796907ac448a68d1d89799d97f15",
         arm64_linux:  "3c4fce65fbded711448db1c13da708d6e414bcdc4521662a4da726bb4a7daaec",
         x86_64_linux: "7609f1d406d246ef8f1b6b4778c87489245d3002e3d975b6b617ec93e59a21c9"

  on_macos do
    depends_on macos: :monterey

    app "LibreMerge.app"

    zap trash: [
      "~/Library/Preferences/com.libremerge.LibreMerge.plist",
      "~/Library/Preferences/org.libremerge.LibreMerge.plist",
      "~/Library/Saved Application State/org.libremerge.LibreMerge.savedState",
    ]

    caveats <<~EOS
      LibreMerge is not notarized by Apple yet. If macOS blocks the first
      launch, right-click LibreMerge.app and choose Open, or clear the
      download quarantine once:
        xattr -d com.apple.quarantine /Applications/LibreMerge.app
    EOS
  end
  on_linux do
    arch arm: "-aarch64", intel: "-x86_64"

    app_image "LibreMerge-#{version}#{arch}.AppImage", target: "LibreMerge.AppImage"

    zap trash: "~/.config/LibreMerge"

    caveats <<~EOS
      The AppImage needs glibc 2.36 or newer (Debian 12+, Ubuntu 24.04+,
      Fedora 37+, Arch). Homebrew places it in ~/Applications and does not
      add a menu entry; run it as:
        ~/Applications/LibreMerge.AppImage
    EOS
  end

  url "https://github.com/iagodpassos/libremerge/releases/download/v#{version}/LibreMerge-#{version}#{arch}.#{os}"
  name "LibreMerge"
  desc "Diff and merge tool for files, folders and CSV tables (WinMerge engine, Qt UI)"
  homepage "https://github.com/iagodpassos/libremerge"
end
