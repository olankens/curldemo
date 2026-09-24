#!/usr/bin/env bash

# shellcheck disable=SC2155

set -euo pipefail

main() {

  # Handle dependencies
  brew install curl
  brew upgrade curl

  # Update package
  # local address="https://staruml.io/api/download/releases-v7/StarUML-7.0.0-arm64.dmg"
  local address="https://staruml.io/api/download/releases-v7/StarUML-7.1.0-arm64.dmg"
  local package="$(mktemp -d)/$(basename "$address")" && curl -LA "mozilla/5.0" "$address" -o "$package"
  hdiutil attach "$package" -noautoopen -nobrowse
  cp -fr /Volumes/StarUML*/StarUML*.app /Applications
  hdiutil detach /Volumes/StarUML*
  #  sudo xattr -rd com.apple.quarantine /Applications/StarUML*.app
  sudo xattr -cr /Applications/StarUML.app
  sudo codesign --remove-signature /Applications/StarUML.app
  sudo codesign --deep --sign - /Applications/StarUML.app

  # Invoke once
  timeout "15" osascript <<-EOD
		tell application "/Applications/StarUML.app"
			activate
			reopen
			tell application "System Events"
				tell process "StarUML"
					repeat until (exists window 1)
						delay 1
					end repeat
				end tell
			end tell
			delay 4
			quit app "StarUML"
			delay 4
		end tell
	EOD
  pkill -9 -f "StarUML"

  # Finish install
  address="https://raw.githubusercontent.com/rodyuzuriaga"
  address="$address/Get-full-version-of-StarUML-7.0.0-Pro-Remove-Watermark"
  address="$address/refs/heads/main/app/src"
  deposit="/Applications/StarUML.app/Contents/Resources"
  npx -y @electron/asar e "$deposit/app.asar" "$deposit/app"
  curl -LA "mozilla/5.0" "$address/engine/license-store.js" -o "$deposit/app/src/engine/license-store.js"
  curl -LA "mozilla/5.0" "$address/engine/diagram-export.js" -o "$deposit/app/src/engine/diagram-export.js"
  curl -LA "mozilla/5.0" "$address/dialogs/license-activation-dialog.js" -o "$deposit/app/src/dialogs/license-activation-dialog.js"
  sleep 4 && npx -y @electron/asar pack "$deposit/app" "$deposit/app.asar"
  sleep 4 && rm -fr "$deposit/app"

}

main "$@"