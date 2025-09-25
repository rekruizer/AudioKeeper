cask "audiokeeper" do
  version "1.0.16"
  sha256 "bec9bed68ae134ff9542b2909c20225b6bfa954df1a91723e6a6ed220823b665"

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
