cask "audiokeeper" do
  version "1.0.0"
  sha256 ""

  url "https://github.com/rekruizer/AudioKeeper/releases/download/v#{version}/AudioKeeper-#{version}.dmg"
  name "AudioKeeper"
  desc "macOS menu bar application that automatically maintains your preferred audio input/output devices"
  homepage "https://github.com/rekruizer/AudioKeeper"

  app "AudioKeeper.app"

  zap trash: [
    "~/Library/Preferences/com.rekruizer.audiokeeper.plist",
    "~/Library/Application Support/AudioKeeper",
  ]
end
