cask "sutrakey" do
  version "1.0.7"
  sha256 "a530bd3e8a6f2653de64eae51be980c657b8a8a8c2957b73bf49f7a7c11b0ee5"

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
