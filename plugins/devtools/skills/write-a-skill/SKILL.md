---
name: write-a-skill
description: 'Use when creating a new skill. Scaffolds proper structure with clear input/output/boundary per phase. Skill files must be concise — under 100 lines, overflow to references/. Trigger phrases: "write a skill", "create skill", "add skill", "new skill", "scaffold skill".'
---

Every skill is a focused playbook for one problem. Define input, output, and boundary before writing.

## Rules

- Each phase must declare Input, Output, and Boundary.
- No phase should produce raw tool output — always compact before handing off to the next phase.
- Keep the SKILL.md ≤100 lines; move tables, templates, and examples into `references/`.
- The description must start with "Use when", be third person, and end with 2–5 trigger phrases.

## Pre-flight

Answer all four before writing:
- **Problem**: What failure mode does this skill prevent?
- **Trigger**: What user phrases invoke it? (2–5 phrases)
- **Input**: What does the user provide? What does the skill read?
- **Output**: What does the user receive? What files are written?

## Scaffold

Use the file-structure, frontmatter, and body templates in `references/skill-template.md`.

## Validate (before declaring done)

After scaffolding, run the new skill through SkillSpec and act on what it finds:

1. Run `skillspec doctor <new-skill-dir>` (skip only if `skillspec` is not installed — say so explicitly).
2. Read the findings. For each CRITICAL/HIGH — and any MEDIUM you can resolve without changing behavior — adapt the SKILL.md: fix the frontmatter/description, declare dependencies, defer heavy text to `references/`, label code fences, move late obligations up.
3. Re-run `skillspec doctor` and repeat until findings stop dropping without harming the skill.

The skill is **not done** until SkillSpec has run and its actionable findings are resolved or explicitly justified. See `references/skillspec-validation.md` for the finding-to-fix map.
