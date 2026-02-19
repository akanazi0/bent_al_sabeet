#!/bin/bash
# Usage: ./scripts/bump-version.sh [patch|minor|major]
# Example: ./scripts/bump-version.sh patch  →  1.0.0 → 1.0.1

BUMP_TYPE=${1:-patch}
CURRENT=$(grep 'version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1 | tr -d '[:space:]')

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case $BUMP_TYPE in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  *) echo "❌ Usage: $0 [patch|minor|major]"; exit 1 ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
sed -i "s/version: .*/version: $NEW_VERSION+1/" pubspec.yaml

echo "✅ Version bumped: $CURRENT → $NEW_VERSION"
echo ""
echo "To trigger the CI/CD pipeline, run:"
echo "  git add -A && git commit -m \"Release v$NEW_VERSION\""
echo "  git tag v$NEW_VERSION"
echo "  git push && git push --tags"
