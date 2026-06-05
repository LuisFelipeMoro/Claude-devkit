---
name: release-management
description: Use when asked to cut a release, bump version, or generate a changelog. Determines semver bump from conventional commits, updates CHANGELOG.md, creates git tag, pushes, drafts GitHub release.
---

## Step 1 — Determine Version Bump

```bash
# Get last tag
git describe --tags --abbrev=0

# Commits since last tag
git log <last-tag>..HEAD --oneline --no-decorate
```

Map conventional commit types to semver:
| Commit type | Bump |
|-------------|------|
| `feat!:` or `BREAKING CHANGE:` footer | MAJOR |
| `feat:` | MINOR |
| `fix:` `perf:` `refactor:` `chore:` `docs:` `test:` `ci:` | PATCH |

Rule: highest-priority type in the set wins.

## Step 2 — Compute New Version

Parse last tag as `vMAJOR.MINOR.PATCH`. Apply bump. New tag = `vX.Y.Z`.

Ask user to confirm: `Next version: vX.Y.Z — confirm? (y/n)`

## Step 3 — Update CHANGELOG.md

Follow [Keep a Changelog](https://keepachangelog.com) format. Insert new section above previous entries:

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Added
- feat: [description] ([commit-sha])

### Fixed
- fix: [description] ([commit-sha])

### Changed
- refactor/perf: [description] ([commit-sha])

### Breaking Changes
- feat!: [description] — **Migration**: [what callers must change]
```

Group commits by type. Skip `chore:`, `docs:`, `test:`, `ci:` unless they affect users.

## Step 4 — Tag and Push

```bash
git add CHANGELOG.md
git commit -m "chore(release): vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin HEAD
git push origin vX.Y.Z
```

## Step 5 — Draft GitHub Release

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "$(cat <<'EOF'
## What's Changed
[paste CHANGELOG section content]

**Full Changelog**: https://github.com/{owner}/{repo}/compare/vPREV...vX.Y.Z
EOF
)" \
  --draft
```

Output: release URL for user to review + publish.
