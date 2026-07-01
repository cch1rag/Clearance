#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/project.yml"
CHANGELOG_FILE="$ROOT_DIR/CHANGELOG.md"
PROJECT_NAME="Clearance"

usage() {
  cat <<'EOF'
Usage:
  scripts/release.sh prepare VERSION BUILD
  scripts/release.sh publish VERSION

Examples:
  scripts/release.sh prepare 1.0.3 4
  scripts/release.sh publish 1.0.3

prepare updates project.yml, regenerates the Xcode project, and creates a
validated unsigned release artifact. It does not commit, tag, push, or publish.

publish requires a clean, committed main branch matching origin/main. It
rebuilds the artifact, then asks for explicit confirmation before pushing the
release tag and creating the GitHub release.
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

validate_version() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
    die "version must use semantic version form X.Y.Z"
}

validate_build() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]] ||
    die "build number must be a positive integer"
}

require_clean_worktree() {
  [[ -z "$(git status --porcelain --untracked-files=all)" ]] ||
    die "working tree must be clean"
}

project_value() {
  local key="$1"
  awk -F'"' -v key="$key" '$0 ~ "^[[:space:]]*" key ":" { print $2; exit }' "$PROJECT_FILE"
}

require_changelog_entry() {
  local version="$1"
  grep -Fq "## [$version]" "$CHANGELOG_FILE" ||
    die "CHANGELOG.md has no section for $version"
}

write_release_notes() {
  local version="$1"
  local notes_file="$2"

  awk -v version="$version" '
    index($0, "## [" version "]") == 1 { found = 1; next }
    found && /^## \[/ { exit }
    found { print }
  ' "$CHANGELOG_FILE" > "$notes_file"

  grep -q '[^[:space:]]' "$notes_file" ||
    die "CHANGELOG.md section for $version has no release notes"
}

update_project_version() {
  local version="$1"
  local build="$2"

  VERSION="$version" BUILD="$build" perl -0pi -e '
    $version_count = s/^(\s*MARKETING_VERSION:\s*)"[^"]+"/$1"$ENV{VERSION}"/m;
    $build_count = s/^(\s*CURRENT_PROJECT_VERSION:\s*)"[^"]+"/$1"$ENV{BUILD}"/m;
    die "expected one MARKETING_VERSION and one CURRENT_PROJECT_VERSION\n"
      unless $version_count == 1 && $build_count == 1;
  ' "$PROJECT_FILE"
}

build_artifact() {
  local version="$1"
  local expected_build="$2"
  local output_dir="$ROOT_DIR/tmp/release-build-v$version"
  local app_path="$output_dir/build/Release/$PROJECT_NAME.app"
  local archive_path="$output_dir/$PROJECT_NAME-$version.zip"
  local notes_file="$output_dir/release-notes-v$version.md"
  local checksum_file="$archive_path.sha256"
  local actual_version
  local actual_build

  rm -rf "$output_dir"
  mkdir -p "$output_dir"

  xcodegen generate --spec "$PROJECT_FILE"
  xcodebuild \
    -project "$ROOT_DIR/$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -configuration Release \
    -derivedDataPath "$output_dir/DerivedData" \
    CODE_SIGNING_ALLOWED=NO \
    SYMROOT="$output_dir/build" \
    OBJROOT="$output_dir/obj" \
    clean build

  [[ -d "$app_path" ]] || die "build did not produce $app_path"
  [[ -x "$app_path/Contents/MacOS/$PROJECT_NAME" ]] ||
    die "app bundle does not contain the expected executable"

  actual_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_path/Contents/Info.plist")"
  actual_build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app_path/Contents/Info.plist")"
  [[ "$actual_version" == "$version" ]] ||
    die "built app version is $actual_version; expected $version"
  [[ "$actual_build" == "$expected_build" ]] ||
    die "built app build number is $actual_build; expected $expected_build"

  write_release_notes "$version" "$notes_file"
  ditto -c -k --sequesterRsrc --keepParent "$app_path" "$archive_path"
  shasum -a 256 "$archive_path" > "$checksum_file"

  printf '\nValidated release artifact\n'
  printf '  App:      %s\n' "$app_path"
  printf '  Archive:  %s\n' "$archive_path"
  printf '  Checksum: %s\n' "$checksum_file"
  printf '  Notes:    %s\n' "$notes_file"
}

prepare_release() {
  local version="$1"
  local build="$2"

  validate_version "$version"
  validate_build "$build"
  require_clean_worktree
  require_changelog_entry "$version"

  update_project_version "$version" "$build"
  build_artifact "$version" "$build"

  printf '\nPreparation complete. Review and commit project.yml and the regenerated Xcode project.\n'
  printf 'Nothing was committed, tagged, pushed, or published.\n'
}

publish_release() {
  local version="$1"
  local tag="v$version"
  local build
  local answer
  local tagged_commit
  local output_dir="$ROOT_DIR/tmp/release-build-v$version"
  local archive_path="$output_dir/$PROJECT_NAME-$version.zip"
  local notes_file="$output_dir/release-notes-v$version.md"

  validate_version "$version"
  require_command gh
  require_clean_worktree
  [[ "$(git branch --show-current)" == "main" ]] ||
    die "publish must run from main"

  git fetch origin main --tags
  [[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] ||
    die "local main must exactly match origin/main"

  [[ "$(project_value MARKETING_VERSION)" == "$version" ]] ||
    die "project.yml version does not match $version"
  build="$(project_value CURRENT_PROJECT_VERSION)"
  validate_build "$build"
  require_changelog_entry "$version"

  if git rev-parse -q --verify "$tag^{commit}" >/dev/null; then
    tagged_commit="$(git rev-parse "$tag^{commit}")"
    [[ "$tagged_commit" == "$(git rev-parse HEAD)" ]] ||
      die "$tag already points to a different commit"
  fi

  if gh release view "$tag" >/dev/null 2>&1; then
    die "GitHub release $tag already exists"
  fi

  build_artifact "$version" "$build"
  require_clean_worktree

  printf '\nReady to publish\n'
  printf '  Commit:   %s\n' "$(git rev-parse --short=12 HEAD)"
  printf '  Tag:      %s\n' "$tag"
  printf '  Archive:  %s\n' "$archive_path"
  printf '  Checksum: %s\n' "$(awk '{print $1}' "$archive_path.sha256")"
  printf '  Notes:    %s\n\n' "$notes_file"
  printf 'Type "publish %s" to continue: ' "$tag"
  read -r answer
  [[ "$answer" == "publish $tag" ]] || die "publication cancelled"

  if ! git rev-parse -q --verify "$tag^{commit}" >/dev/null; then
    git tag -a "$tag" -m "Release $version"
  fi
  git push origin "$tag"
  gh release create "$tag" "$archive_path" \
    --title "$PROJECT_NAME $version" \
    --notes-file "$notes_file" \
    --latest

  printf '\nPublished %s.\n' "$tag"
}

main() {
  local command="${1:-}"

  cd "$ROOT_DIR"
  require_command git
  require_command awk
  require_command grep
  require_command perl
  require_command xcodegen
  require_command xcodebuild
  require_command ditto
  require_command shasum
  [[ -f "$PROJECT_FILE" ]] || die "project.yml not found"
  [[ -f "$CHANGELOG_FILE" ]] || die "CHANGELOG.md not found"

  case "$command" in
    prepare)
      [[ "$#" -eq 3 ]] || { usage >&2; exit 2; }
      prepare_release "$2" "$3"
      ;;
    publish)
      [[ "$#" -eq 2 ]] || { usage >&2; exit 2; }
      publish_release "$2"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
