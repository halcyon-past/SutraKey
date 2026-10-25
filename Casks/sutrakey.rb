cask "sutrakey" do
  version "1.0.6"
  sha256 "a4e195a2abe1a2bcdc6e2c78316f6ff54e68e5da5b43884dd61494f7ce560e2f"

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
