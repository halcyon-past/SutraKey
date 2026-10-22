cask "sutrakey" do
  version "1.0.2"
  sha256 "7c5dfee73ec884aa90e0d4654738b3ed3763252d9d8b20129f768b44424b81ed"

  url "https://github.com/halcyon-past/SutraKey/releases/download/v#{version}/SutraKey-v#{version}.dmg"
  name "SutraKey"
  desc "Shift + Select radial media and document downloader for macOS"
  homepage "https://sutrakey.aritro.cloud/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :sonoma

  app "SutraKey.app"

  zap trash: [
    "~/Library/Application Support/cloud.aritro.sutrakey",
    "~/Library/Preferences/cloud.aritro.sutrakey.plist",
    "~/Library/Caches/cloud.aritro.sutrakey",
  ]
end
