cask "audiokeeper" do
  version "1.2.1"
  sha256 "da5bb8073da6b4cc54a15c9c9f87431b2b1291bbed3416b58f899d35d5e5d498"

  url "https://github.com/rekruizer/AudioKeeper/releases/download/v#{version}/AudioKeeper-v#{version}.dmg"
  name "AudioKeeper"
  desc "macOS menu bar application that automatically maintains your preferred audio input/output devices"
  homepage "https://github.com/rekruizer/AudioKeeper"

  app "AudioKeeper.app"

  zap trash: [
    "~/Library/Preferences/com.rekruizer.audiokeeper.plist",
    "~/Library/Application Support/AudioKeeper",
  ]
end
