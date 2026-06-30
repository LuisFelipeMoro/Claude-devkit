---
name: release-management
description: Cut a release by determining the semver bump from conventional commits, updating CHANGELOG.md, tagging, pushing, and drafting a GitHub release. Trigger phrases — "release", "cut a release", "bump version", "changelog", "tag", "semver", "publish", "release notes".
---

The version bump follows the conventional commits since the last tag, and the GitHub release stays a draft for the human to review before publishing — nothing publishes automatically.

## Contract
- Input: a repository with conventional-commit history since the last tag.
- Output: an updated CHANGELOG.md, an annotated git tag pushed to origin, and a drafted GitHub release URL.
- Tool boundary: the draft release is never auto-published; version confirmation is requested from the user before tagging.
- Done when: the draft release URL prints for the user to review and publish.

## Steps
1. Determine the version bump: the git commands and the conventional-commit→semver table in `references/commands-and-templates.md` map commits since the last tag, where the highest-priority type wins.
2. Compute the new `vX.Y.Z` from the last tag, then confirm it with the user before tagging.
3. Update CHANGELOG.md from the Keep a Changelog template in `references/commands-and-templates.md`, grouping commits by type.
4. Tag and push with the git commands in `references/commands-and-templates.md`.
5. Draft the GitHub release with the `gh` command in `references/commands-and-templates.md`, then hand the resulting URL to the user.

## References
- `references/commands-and-templates.md` — git/gh commands, the semver mapping table, and the CHANGELOG template.
