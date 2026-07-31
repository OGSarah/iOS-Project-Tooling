# iOS Toolkit

A small, reusable toolkit I drop into new iOS projects to standardize setup and enforce code quality from the first commit, plus the reference notes I keep coming back to. It keeps linting, file headers, and project conventions consistent across every project I start, so quality and style are baked in rather than bolted on later.

## Tooling

| File | Purpose | Usage |
|------|---------|-------|
| `.swiftlint.yml` | Baseline SwiftLint configuration for a new Xcode project | Drop into the project root |
| `runscript.sh` | SwiftLint invocation for an Xcode Build Phase | Copy the contents into a Run Script build phase. Do not run it directly |
| `add_swift_header.sh` | Applies the SarahUniverse copyright header to existing files in an Xcode project | From the project root, run in bash `add_swift_header.sh . --project ProjectName --git-year --apply` |
| `IDETemplateMacros.plist` | Defines the copyright header Xcode inserts into newly created files | Place at `YourProject.xcodeproj/xcshareddata/IDETemplateMacros.plist` |
| `Agents.md` | Coding agent guidance tuned for mostly SwiftUI projects, with some UIKit and Swift only code | Include in the project root |

## Reference

| File | Purpose |
|------|---------|
| `ios-code-signing-diagrams.md` | A visual guide to iOS code signing and provisioning, built from Mermaid diagrams. Covers certificates, App IDs, entitlements, provisioning profiles, automatic and manual signing, Enterprise in-house distribution, launch-time Team ID validation, and a troubleshooting decision tree |

Reference docs render directly on GitHub. Mermaid diagrams are supported in Markdown files, so no build step is needed.

## Why this exists

Setting these up once and reusing them means every project starts with linting enforced at build time, consistent file headers applied automatically, and a known set of conventions. It removes a class of small decisions and inconsistencies before they happen. The reference docs serve the same goal from the other direction, capturing the things that are easy to forget between projects so they do not have to be relearned each time.

## License

Released under the [MIT License](LICENSE). © 2026 SarahUniverse
