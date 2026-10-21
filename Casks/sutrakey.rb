cask "sutrakey" do
  version "1.0.0"
  sha256 "97ad1575c5d7f49c39340240175e07c2e33696c81b32e6c5def8b67cb9daf197"

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
