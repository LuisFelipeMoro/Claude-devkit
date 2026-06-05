# API Integration Reference

How to call the Anthropic API for each pipeline agent.

---

## Base Call Pattern

```javascript
async function callAgent(agentName, systemPrompt, userPrompt) {
  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': process.env.ANTHROPIC_API_KEY,  // never hardcode
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-6',
      max_tokens: 1000,
      system: systemPrompt,
      messages: [{ role: 'user', content: userPrompt }]
    })
  });
  if (!response.ok) {
    const err = await response.json().catch(() => ({}));
    throw new Error(`Anthropic API ${response.status}: ${JSON.stringify(err)}`);
  }
  const data = await response.json();
  return data.content?.map(b => b.text || '').join('') || '';
}
```

**Security**: API key via env only — never log or hardcode · Do not echo raw user input into system prompts (prompt injection risk) · Validate `response.ok` before reading body

---

## Agent Call Sequence

### Phase 1 — Planning
```javascript
const brief = await callAgent('analyst', ANALYST_SYSTEM, `Task: ${task}`);
const prd   = await callAgent('pm',       PM_SYSTEM,       `Task: ${task}\n\nBrief:\n${brief}`);
const arch  = await callAgent('architect',ARCHITECT_SYSTEM,`Task: ${task}\n\nBrief:\n${brief}\n\nPRD:\n${prd}`);
const story = await callAgent('sm',       SM_SYSTEM,       `Task: ${task}\n\nPRD:\n${prd}\n\nArch:\n${arch}`);
```

### Phase 2 — Implementation
```javascript
const code   = await callAgent('coder',   CODER_SYSTEM,   `Story:\n${story}\n\nArch:\n${arch}`);
const tests  = await callAgent('qa',      QA_SYSTEM,      `Task: ${task}\n\nStory:\n${story}\n\nCode:\n${code}`);
const review = await callAgent('reviewer',REVIEWER_SYSTEM,`Task: ${task}\n\nCode:\n${code}`);
const stress = await callAgent('stress',  STRESS_SYSTEM,  `Task: ${task}\n\nCode:\n${code}\n\nTests:\n${tests}`);
const verdict= await callAgent('verdict', VERDICT_SYSTEM, `Task: ${task}\n\nStory:\n${story}\n\nCode:\n${code}\n\nReview:\n${review}\n\nStress:\n${stress}`);
```

---

## Extracting Scores

```javascript
function extractScore(text, label = 'Score') {
  const m = text.match(new RegExp(`${label}:\\s*(\\d+(?:\\.\\d+)?)\\s*\\/\\s*10`, 'i'));
  return m ? parseFloat(m[1]) : null;
}

const reviewScore  = extractScore(review, 'Score');
const stressScore  = extractScore(stress, 'Stress Score');
const overallScore = extractScore(verdict, 'Overall Score');
const testCount    = (tests.match(/\bit\(/g) || []).length + (tests.match(/\btest\(/g) || []).length;
const verdictType  = verdict.match(/VERDICT:\s*PRODUCTION READY/i) ? 'ready'
                   : verdict.match(/VERDICT:\s*NOT READY/i)         ? 'not-ready' : 'conditions';
```

---

## Error Handling (with retry)

```javascript
async function callAgentSafe(name, system, user, retries = 3) {
  for (let i = 1; i <= retries; i++) {
    try {
      const result = await callAgent(name, system, user);
      if (!result) throw new Error('Empty response');
      return { ok: true, output: result };
    } catch (err) {
      const retryable = err.message.includes('529') || err.message.includes('overloaded');
      if (i < retries && retryable) {
        await new Promise(r => setTimeout(r, 1000 * i)); // exponential backoff
        continue;
      }
      console.error(`Agent ${name} failed (attempt ${i}):`, err.message);
      return { ok: false, output: '', error: err.message };
    }
  }
}
```

On failure: pass empty string to next agent, mark tab error — do not halt pipeline.

---

## Token Budget

| Agent | ~Input | ~Output |
|-------|--------|---------|
| Analyst | 200 | 400 |
| PM | 700 | 600 |
| Architect | 1 400 | 700 |
| Scrum Master | 2 200 | 500 |
| Coder | 1 000 | 900 |
| QA | 1 500 | 900 |
| Reviewer | 1 200 | 600 |
| Stress | 2 000 | 600 |
| Verdict | 2 500 | 700 |

If inputs exceed context: summarize earlier artifacts. Priority: Story > Code > Review > Stress > planning docs.
