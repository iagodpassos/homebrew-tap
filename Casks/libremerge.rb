cask "libremerge" do
  version "0.9.3"
  sha256 "7d7e606ba381d7146e993a4e128da3e0c3b186892ec8cac670bd8f67efe56615"

  url "https://github.com/iagodpassos/libremerge/releases/download/v#{version}/LibreMerge-#{version}.dmg"
  name "LibreMerge"
  desc "Diff and merge tool for files, folders and CSV tables (WinMerge engine, Qt UI)"
  homepage "https://github.com/iagodpassos/libremerge"

  depends_on macos: :monterey

  app "LibreMerge.app"

  zap trash: [
    "~/Library/Preferences/org.libremerge.LibreMerge.plist",
    "~/Library/Preferences/com.libremerge.LibreMerge.plist",
    "~/Library/Saved Application State/org.libremerge.LibreMerge.savedState",
  ]

  caveats <<~EOS
    LibreMerge is not notarized by Apple yet. If macOS blocks the first
    launch, right-click LibreMerge.app and choose Open, or clear the
    download quarantine once:
      xattr -d com.apple.quarantine /Applications/LibreMerge.app
  EOS
end
