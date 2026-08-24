cask "libremerge" do
  version "0.7.2"
  sha256 "52aa1ee27b468af9aed406719b4d550b419848b3631faad8d0c0bb8bdc234e2f"

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
    launch, right-click LibreMerge.app and choose Open, or install with:
      brew reinstall --cask --no-quarantine libremerge
  EOS
end
