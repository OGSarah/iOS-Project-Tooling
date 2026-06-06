# iOS Project Tooling

A small, reusable toolkit I drop into new iOS projects to standardize setup and enforce code quality from the first commit. It keeps linting, file headers, and project conventions consistent across every project I start, so quality and style are baked in rather than bolted on later.

## Contents

| File | Purpose | Usage |
|------|---------|-------|
| `.swiftlint.yml` | Baseline SwiftLint configuration for a new Xcode project | Drop into the project root |
| `runscript.sh` | SwiftLint invocation for an Xcode Build Phase | Copy the contents into a Run Script build phase. Do not run it directly |
| `add_swift_header.sh` | Applies the SarahUniverse copyright header to existing files in an Xcode project | From the project root, run in bash: `add_swift_header.sh . --project ProjectName --git-year --apply` |
| `IDETemplateMacros.plist` | Defines the copyright header Xcode inserts into newly created files | Place at `YourProject.xcodeproj/xcshareddata/IDETemplateMacros.plist` |
| `Agents.md` | Coding agent guidance tuned for mostly SwiftUI projects, with some UIKit and Swift only code | Include in the project root |

## Why this exists

Setting these up once and reusing them means every project starts with linting enforced at build time, consistent file headers applied automatically, and a known set of conventions. It removes a class of small decisions and inconsistencies before they happen.

## License
# iOS Project Tooling

A small, reusable toolkit I drop into new iOS projects to standardize setup and enforce code quality from the first commit. It keeps linting, file headers, and project conventions consistent across every project I start, so quality and style are baked in rather than bolted on later.

## Contents

| File | Purpose | Usage |
|------|---------|-------|
| `.swiftlint.yml` | Baseline SwiftLint configuration for a new Xcode project | Drop into the project root |
| `runscript.sh` | SwiftLint invocation for an Xcode Build Phase | Copy the contents into a Run Script build phase. Do not run it directly |
| `add_swift_header.sh` | Applies the SarahUniverse copyright header to existing files in an Xcode project | From the project root, run in bash: `add_swift_header.sh . --project ProjectName --git-year --apply` |
| `IDETemplateMacros.plist` | Defines the copyright header Xcode inserts into newly created files | Place at `YourProject.xcodeproj/xcshareddata/IDETemplateMacros.plist` |
| `Agents.md` | Coding agent guidance tuned for mostly SwiftUI projects, with some UIKit and Swift only code | Include in the project root |

## Why this exists

Setting these up once and reusing them means every project starts with linting enforced at build time, consistent file headers applied automatically, and a known set of conventions. It removes a class of small decisions and inconsistencies before they happen.

## License

Released under the [MIT License](LICENSE). © 2026 SarahUniverse
