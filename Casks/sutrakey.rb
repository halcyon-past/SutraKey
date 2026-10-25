cask "sutrakey" do
  version "1.0.4"
  sha256 "eaa5c7cbbfd8204a80ba02be1b5f39ac8a7b2708734ce4002ba24d93eb3b1151"

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
