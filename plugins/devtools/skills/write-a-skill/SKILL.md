---
name: write-a-skill
description: Use when creating a new skill. Scaffolds proper structure with clear input/output/boundary per phase. Skill files must be concise — under 100 lines, overflow to references/. Trigger phrases: "write a skill", "create skill", "add skill", "new skill", "scaffold skill".
---

Every skill is a focused playbook for one problem. Define input, output, and boundary before writing.

## Pre-flight

Answer all four before writing:
- **Problem**: What failure mode does this skill prevent?
- **Trigger**: What user phrases invoke it? (2–5 phrases)
- **Input**: What does the user provide? What does the skill read?
- **Output**: What does the user receive? What files are written?

## File structure

```
.claude/skills/<name>.md       # ≤100 lines — the only file Claude reads
.claude/references/<name>-reference.md  # overflow: tables, templates, specs
```

Link overflow: `See references/<name>-reference.md for [topic].`

## Frontmatter

```yaml
---
name: kebab-case-name
description: Use when [specific triggers]. [What it does]. Returns [output]. Trigger phrases: "phrase1", "phrase2".
---
```

Description: starts "Use when"; third person; ≤1024 chars; list 2–5 trigger phrases at end.

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

## Phase discipline

Each phase must declare Input, Output, and Boundary. No phase should produce raw tool output — always compact before handing off to next phase.
