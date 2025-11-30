cask "audiokeeper" do
  version "1.2.2"
  sha256 "b84491723e55bd60adfa722d7367247e6f61168a26a8b51e4545b419fe1528de"

  url "https://github.com/rekruizer/AudioKeeper/releases/download/v#{version}/AudioKeeper-v#{version}.dmg"
  name "AudioKeeper"
  desc "macOS menu bar application that automatically maintains your preferred audio input/output devices"
  homepage "https://github.com/rekruizer/AudioKeeper"

  postflight do
    system "xattr", "-d", "com.apple.quarantine", "#{appdir}/AudioKeeper.app"
  end

  app "AudioKeeper.app"

  zap trash: [
    "~/Library/Preferences/com.rekruizer.audiokeeper.plist",
    "~/Library/Application Support/AudioKeeper",
  ]
end
