cask "audiokeeper" do
  version "1.2.0"
  sha256 "6a556d172f0054a49fd1a11a79f7b7cc8f58e652c4eeaf466cdf082d855e7b15"

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
