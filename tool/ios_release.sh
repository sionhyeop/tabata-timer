#!/bin/sh
# Builds the App Store IPA and uploads it to App Store Connect with the
# Apple ID signed in to Xcode (Xcode › Settings › Accounts).
#
#   tool/ios_release.sh            build + upload
#   tool/ios_release.sh --no-upload  build only (build/ios/ipa/*.ipa)
#
# The app record must exist in App Store Connect, and the build number in
# pubspec.yaml must be higher than any build uploaded before.
set -eu
cd "$(dirname "$0")/.."

flutter build ipa --release

if [ "${1:-}" = "--no-upload" ]; then
  exit 0
fi

xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions-upload.plist \
  -exportPath build/ios/upload \
  -allowProvisioningUpdates
