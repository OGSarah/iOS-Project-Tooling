# Scripts, SwiftLint, and other universal files

| File | Purpose | Usage |
|------|---------|-------|
| `Add_Swift_Header.sh` | Adds the SarahUniverse copyright to existing files in an Xcode project | From the main project folder, paste into the terminal (bash): `add_swift_header.sh . --project ProjectName --git-year --apply` |
| `RunScript.sh` | SwiftLint script for Xcode Build Phases | Don't run it. Copy and paste into the shell inside Run Script in Build Phases |
| `.swiftlint.yml` | Basic SwiftLint config for a new Xcode project | Drop into the project root |
| `Agents.md` | Agents file for mostly SwiftUI (with some UIKit and Swift-only) Xcode projects | Include in the project |
| `IDETemplateMacros.plist` | File for the SarahUniverse copyright header used in the project | Place it at: `YourProject.xcodeproj/xcshareddata/IDETemplateMacros.plist` |
