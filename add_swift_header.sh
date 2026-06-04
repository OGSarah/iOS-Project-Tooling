#!/usr/bin/env bash
#
# add_swift_header.sh
#
# Backfills (or replaces) the file header on .swift files so they satisfy a
# SwiftLint `file_header` rule of the form:
#
#   //
#   // <Filename>.swift
#   // <anything>
#   //
#   // Copyright © <YYYY> SarahUniverse. All rights reserved.
#   //
#
# DRY RUN by default. Pass --apply to actually modify files.
#
# Usage:
#   ./add_swift_header.sh [ROOT] [--project NAME] [--year YYYY] [--git-year] [--apply]
#
#   ROOT          Directory to search (default: current directory)
#   --project     Text for line 3 (default: auto-detected *.xcodeproj name)
#   --year        Copyright year (default: current year)
#   --git-year    Use each file's first-commit year (falls back to --year)
#   --apply       Write changes. Without it, only prints what would happen.

set -euo pipefail

ROOT="."
PROJECT=""
YEAR="$(date +%Y)"
USE_GIT_YEAR=0
APPLY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --year)    YEAR="$2"; shift 2 ;;
    --git-year) USE_GIT_YEAR=1; shift ;;
    --apply)   APPLY=1; shift ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    -*)        echo "Unknown option: $1" >&2; exit 2 ;;
    *)         ROOT="$1"; shift ;;
  esac
done

# Auto-detect project name from the first .xcodeproj if not supplied.
if [ -z "$PROJECT" ]; then
  proj="$(find "$ROOT" -maxdepth 3 -name '*.xcodeproj' -print 2>/dev/null | head -1 || true)"
  if [ -n "$proj" ]; then
    PROJECT="$(basename "$proj" .xcodeproj)"
  else
    PROJECT="SarahUniverse"
  fi
fi

# Directories we never want to touch.
PRUNE='-name .git -o -name Pods -o -name Carthage -o -name .build -o -name DerivedData -o -name .swiftpm -o -name vendor'

changed=0; skipped=0; total=0

# shellcheck disable=SC2086
while IFS= read -r file; do
  total=$((total + 1))
  fname="$(basename "$file")"

  # Decide the year for this file.
  fyear="$YEAR"
  if [ "$USE_GIT_YEAR" -eq 1 ] && command -v git >/dev/null 2>&1; then
    g="$(git -C "$(dirname "$file")" log --diff-filter=A --follow \
           --format=%ad --date=format:%Y -- "$file" 2>/dev/null | tail -1 || true)"
    [ -n "$g" ] && fyear="$g"
  fi

  # Skip files that already have a correct header (lines 1-6).
  ok="$(awk -v ic="$fname" '
    NR==1 && $0 != "//" {bad=1}
    NR==2 && $0 !~ /^\/\/ .+\.swift$/ {bad=1}
    NR==3 && $0 !~ /^\/\/ / {bad=1}
    NR==4 && $0 != "//" {bad=1}
    NR==5 && $0 !~ /^\/\/ Copyright © [0-9][0-9][0-9][0-9] SarahUniverse\. All rights reserved\.$/ {bad=1}
    NR==6 && $0 != "//" {bad=1}
    NR>6 {exit}
    END {print (bad ? "no" : "yes")}
  ' "$file")"

  if [ "$ok" = "yes" ]; then
    skipped=$((skipped + 1))
    continue
  fi

  # Build the body with any existing plain header block stripped off.
  # We keep doc comments (/// or //!), swiftlint: directives, and MARK: lines.
  body="$(awk '
    BEGIN { inhdr = 1 }
    {
      if (inhdr) {
        if ($0 ~ /^\/\/\// || $0 ~ /^\/\/!/)        { inhdr = 0 }
        else if ($0 ~ /^\/\/[[:space:]]?swiftlint:/) { inhdr = 0 }
        else if ($0 ~ /^\/\/[[:space:]]?MARK:/)      { inhdr = 0 }
        else if ($0 ~ /^\/\//)                       { next }   # drop plain header line
        else if ($0 ~ /^[[:space:]]*$/)              { next }   # drop blank in/after header
        else                                         { inhdr = 0 }
      }
      print
    }
  ' "$file")"

  if [ "$APPLY" -eq 1 ]; then
    tmp="$(mktemp "${file}.hdr.XXXXXX")"
    {
      printf '//\n'
      printf '// %s\n' "$fname"
      printf '// %s\n' "$PROJECT"
      printf '//\n'
      printf '// Copyright © %s SarahUniverse. All rights reserved.\n' "$fyear"
      printf '//\n'
      printf '\n'
      printf '%s\n' "$body"
    } > "$tmp"
    mv "$tmp" "$file"
    echo "updated: $file"
  else
    echo "would update: $file  (year $fyear, project \"$PROJECT\")"
  fi
  changed=$((changed + 1))

done < <(find "$ROOT" \( $PRUNE \) -prune -o -name '*.swift' -type f -print)

echo "---"
if [ "$APPLY" -eq 1 ]; then
  echo "done: $changed updated, $skipped already correct, $total total"
else
  echo "dry run: $changed would change, $skipped already correct, $total total"
  echo "re-run with --apply to write changes"
fi
