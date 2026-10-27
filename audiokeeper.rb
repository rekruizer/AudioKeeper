cask "audiokeeper" do
  version "1.3.0"
  sha256 "ba13aca27fb934a24afdb09f1a2c2f6e61924ec551070f32249c510513edd2dd"

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
    "~/Library/Preferences/denisyuce.AudioKeeper.plist",
    "~/Library/Containers/denisyuce.AudioKeeper",
    "~/Library/Application Support/AudioKeeper",
  ]
end
