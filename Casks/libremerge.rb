cask "libremerge" do
  os macos: "dmg", linux: "AppImage"

  version "1.0.1"
  sha256 arm:          "86deaf93fd0a4e6a81c5da6a3640c626d939f0cffd37a858724dd4f454804a08",
         intel:        "86deaf93fd0a4e6a81c5da6a3640c626d939f0cffd37a858724dd4f454804a08",
         arm64_linux:  "d3f30bde9a9f56d99de885692088072b728745c6def6977962508b11b1a767e4",
         x86_64_linux: "7093639e82edfc7d98aff0b25f21450ec3d02a15872e9d6c475499e9037b05a6"

  on_macos do
    depends_on macos: :sonoma

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
    # `libremerge` on PATH (git mergetool, terminal use). The DSL does not
    # expose appimagedir, so the wrapper finds the AppImage at run time:
    # ~/Applications, or an --appimagedir set in HOMEBREW_CASK_OPTS
    command_wrapper "libremerge", content: <<~'SH'
      #!/bin/sh
      dir="$HOME/Applications"
      for opt in $HOMEBREW_CASK_OPTS; do
        case "$opt" in
          --appimagedir=*) dir="${opt#--appimagedir=}" ;;
        esac
      done
      case "$dir" in "~"*) dir="$HOME${dir#\~}" ;; esac
      exec "$dir/LibreMerge.AppImage" "$@"
    SH

    # the AppImage adds itself to the applications menu (a desktop entry and
    # icons under ~/.local/share); failing never fails the install. Install
    # steps run sandboxed with a stand-in $HOME (~ resolves there too), so the
    # real data directory is spelled from the user name, reaches the AppImage
    # as the working directory and --data-home=. points it there; homes
    # outside /home fall back to the command in the caveats
    postflight_steps do
      run "LibreMerge.AppImage",
          base:           :appimagedir,
          args:           ["--install-desktop-integration", "--data-home=."],
          env:            { "APPIMAGE_EXTRACT_AND_RUN" => "1" },
          chdir:          "/home/{{user}}/.local/share",
          must_succeed:   false,
          writable_paths: ["/home/{{user}}/.local/share/applications", "/home/{{user}}/.local/share/icons"]
    end

    uninstall_preflight_steps do
      run "LibreMerge.AppImage",
          base:           :appimagedir,
          args:           ["--remove-desktop-integration", "--data-home=."],
          env:            { "APPIMAGE_EXTRACT_AND_RUN" => "1" },
          chdir:          "/home/{{user}}/.local/share",
          must_succeed:   false,
          writable_paths: ["/home/{{user}}/.local/share/applications", "/home/{{user}}/.local/share/icons"]
    end

    zap trash: [
      "~/.config/LibreMerge",
      "~/.local/share/applications/libremerge.desktop",
      "~/.local/share/icons/hicolor/*/apps/libremerge.png",
    ]

    caveats <<~EOS
      The AppImage needs glibc 2.35 or newer (Debian 12+, Ubuntu 22.04+,
      Fedora 36+, Arch). It lives in ~/Applications and runs from the
      terminal as:
        libremerge
      It is added to the applications menu; if it does not show up there,
      run once:
        libremerge --install-desktop-integration
    EOS
  end

  url "https://github.com/iagodpassos/libremerge/releases/download/v#{version}/LibreMerge-#{version}#{arch}.#{os}"
  name "LibreMerge"
  desc "Diff and merge tool for files, folders and CSV tables (WinMerge engine, Qt UI)"
  homepage "https://github.com/iagodpassos/libremerge"
end
