cask "libremerge" do
  version "0.8.0"
  sha256 "6b6bf81f2ecfa49e201ff4929bab8fd58fb7a3a8672d4e681804c52507fa6ae8"

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
