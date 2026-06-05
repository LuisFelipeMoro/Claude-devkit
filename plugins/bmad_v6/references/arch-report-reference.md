# Architecture Report Reference

## HTML Scaffold

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Architecture Report — {YYYY-MM-DD}</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 960px; margin: 2rem auto; padding: 0 1rem; color: #1a1a1a; }
    h1 { border-bottom: 2px solid #e5e7eb; padding-bottom: .5rem; }
    h2 { margin-top: 2rem; color: #374151; }
    .finding { padding: .5rem 1rem; margin: .5rem 0; border-radius: 4px; }
    .critical { background: #fef2f2; border-left: 4px solid #ef4444; }
    .high     { background: #fff7ed; border-left: 4px solid #f97316; }
    .medium   { background: #fefce8; border-left: 4px solid #eab308; }
    .low      { background: #f0fdf4; border-left: 4px solid #22c55e; }
    .finding code { font-size: .85rem; background: #f3f4f6; padding: .1rem .3rem; border-radius: 3px; }
    table { width: 100%; border-collapse: collapse; margin: 1rem 0; }
    th, td { text-align: left; padding: .5rem .75rem; border: 1px solid #e5e7eb; }
    th { background: #f9fafb; font-weight: 600; }
    .badge { font-size: .75rem; font-weight: 600; padding: .15rem .4rem; border-radius: 4px; text-transform: uppercase; }
    .badge.critical { background: #fee2e2; color: #b91c1c; }
    .badge.high     { background: #ffedd5; color: #c2410c; }
    .badge.medium   { background: #fef9c3; color: #92400e; }
    .badge.low      { background: #dcfce7; color: #166534; }
  </style>
</head>
<body>
  <h1>Architecture Report</h1>
  <p><strong>Date:</strong> {YYYY-MM-DD} &nbsp;|&nbsp; <strong>Scope:</strong> {directory or module}</p>

  <h2>Summary</h2>
  <table>
    <tr><th>Severity</th><th>Count</th></tr>
    <tr><td><span class="badge critical">Critical</span></td><td>{N}</td></tr>
    <tr><td><span class="badge high">High</span></td><td>{N}</td></tr>
    <tr><td><span class="badge medium">Medium</span></td><td>{N}</td></tr>
    <tr><td><span class="badge low">Low</span></td><td>{N}</td></tr>
  </table>

  <h2>Critical Findings</h2>
  <!-- Repeat per finding -->
  <div class="finding critical">
    <strong><span class="badge critical">Critical</span> {title}</strong><br>
    <code>{file:line}</code><br>
    {description}<br>
    <em>Recommendation: {fix}</em>
  </div>

  <h2>High Findings</h2>
  <div class="finding high">
    <strong><span class="badge high">High</span> {title}</strong><br>
    <code>{file:line}</code><br>
    {description}<br>
    <em>Recommendation: {fix}</em>
  </div>

  <h2>Medium Findings</h2>
  <!-- Add .finding.medium divs here -->

  <h2>Low Findings</h2>
  <!-- Add .finding.low divs here -->
</body>
</html>
```

---

## ADR Template

Save to: `docs/adr/ADR-{NNN}-{kebab-title}.md`

```markdown
# ADR-{NNN}: {Title}

**Date**: {YYYY-MM-DD}
**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-{NNN}

## Context

Why was this decision needed? What problem or constraint forced a choice?

## Decision

What was decided and why?

## Consequences

### Positive
- {benefit}

### Negative
- {tradeoff}

### Risks
- {risk and mitigation}

## Rejected Alternatives

| Alternative | Reason rejected |
|-------------|----------------|
| {option A} | {why not chosen} |
| {option B} | {why not chosen} |
```
