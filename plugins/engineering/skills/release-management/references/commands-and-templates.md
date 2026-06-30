# Release Commands and Templates

## Step 1 — Determine version bump

```bash
# Get last tag
git describe --tags --abbrev=0

# Commits since last tag
git log <last-tag>..HEAD --oneline --no-decorate
```

Map conventional commit types to semver (highest-priority type in the set wins):

| Commit type | Bump |
|-------------|------|
| `feat!:` or `BREAKING CHANGE:` footer | MAJOR |
| `feat:` | MINOR |
| `fix:` `perf:` `refactor:` `chore:` `docs:` `test:` `ci:` | PATCH |

## Step 2 — Compute new version

Parse last tag as `vMAJOR.MINOR.PATCH`. Apply the bump. New tag = `vX.Y.Z`.

Confirm with the user: `Next version: vX.Y.Z — confirm? (y/n)`

## Step 3 — CHANGELOG.md template

Follow [Keep a Changelog](https://keepachangelog.com). Insert the new section above previous entries:

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

## Step 4 — Tag and push

```bash
git add CHANGELOG.md
git commit -m "chore(release): vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin HEAD
git push origin vX.Y.Z
```

## Step 5 — Draft GitHub release

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

Output: the draft release URL for the user to review and publish.
