cask "libremerge" do
  os macos: "dmg", linux: "AppImage"

  version "0.9.6"
  sha256 arm:          "31f65595944cb64727238c8c42508e8004ce07053e312a0c4124a67c8810be9c",
         intel:        "31f65595944cb64727238c8c42508e8004ce07053e312a0c4124a67c8810be9c",
         arm64_linux:  "721105648f3de2ef097e885464b94e48ab2896ad5ccd3545725cfe175784b6e4",
         x86_64_linux: "b5eb4becfea73a3392506e5f8fabf672d603991659d9f154a277393054ef8b03"

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
