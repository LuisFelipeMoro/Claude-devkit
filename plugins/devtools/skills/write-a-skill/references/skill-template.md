# Skill scaffold templates

## File structure

```text
.claude/skills/<name>.md                 # ≤100 lines — the only file Claude reads
.claude/references/<name>-reference.md   # overflow: tables, templates, specs
```

Link overflow from the SKILL.md: `See references/<name>-reference.md for [topic].`

## Frontmatter

```yaml
---
name: kebab-case-name
description: 'Use when [specific triggers]. [What it does]. Returns [output]. Trigger phrases: "phrase1", "phrase2".'
---
```

Description: starts "Use when"; third person; ≤1024 chars; list 2–5 trigger
phrases at the end. Always quote the value so colons inside it stay valid YAML.

## Body structure

```markdown
[One-sentence core rule]

## [Phase — Name]
Input: [...]
Output: [...]
Boundary: does NOT [...]

1. Step
2. Step

## Anti-patterns
- Don't [X] because [Y]
```
