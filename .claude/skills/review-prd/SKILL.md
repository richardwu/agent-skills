---
name: review-prd
description: "Review and verify that a Ralph PRD's user stories have been implemented correctly. Reads prd.json, steps through each user story's acceptance criteria, runs tests, checks code, and uses browser verification. Produces a pass/gap/untestable summary. Triggers on: review prd, verify prd, check ralph requirements, review requirements, are the stories done, verify user stories, prd review."
user-invocable: true
---

# PRD Review

Verify that each user story in a Ralph `prd.json` has been correctly implemented by checking acceptance criteria, running tests, and inspecting code.

## Workflow

### 1. Load the PRD and repo context

1. Read the Ralph `prd.json` (check ralph skill directory or current project root)
2. Read the project's `CLAUDE.md` for testing instructions (test commands, lint commands, dev server setup)
3. Identify the branch from `prd.json.branchName` and confirm you're on it (or the work has been merged)

### 2. Run repo-wide checks first

Before per-story review, run project-level checks once to get baseline status:

- **Typecheck**: Run the typecheck command from CLAUDE.md (e.g., `tsc --noEmit`, `pnpm typecheck`)
- **Lint**: Run the lint command if specified
- **Tests**: Run the full test suite if specified

Record results — these apply to all stories with "Typecheck passes" or "Tests pass" criteria.

### 3. Review each user story

For each story in `userStories`, evaluate every acceptance criterion:

**Code-verifiable criteria** (e.g., "Add status column", "Install package X"):
- Search the codebase for the expected code changes
- Read relevant files to confirm the implementation matches the criterion
- Check imports, schema changes, migrations, component structure

**Test-verifiable criteria** (e.g., "Typecheck passes", "Tests pass"):
- Use results from the repo-wide checks in step 2
- If a story has story-specific test files, run those too

**Browser-verifiable criteria** (e.g., "Verify in browser using dev-browser skill"):
- Start the dev server if not already running (use CLAUDE.md instructions)
- Use browser automation to navigate to the relevant page
- Take screenshots and verify visual/interactive behavior
- Check that UI elements exist, respond to clicks, display correct data

**Behavioral criteria** (e.g., "Clicking delete shows confirmation dialog", "Filter persists in URL params"):
- Combine code review with browser verification where applicable
- Trace the code path to confirm the behavior is wired up correctly

For each criterion, record one of:
- **PASS**: Criterion is clearly met
- **GAP**: Implementation exists but doesn't fully meet the criterion, or has non-standard behavior
- **UNTESTABLE**: Cannot verify (e.g., requires auth, external service, or data not available)

### 4. Produce the summary

After reviewing all stories, output a structured summary:

```
## PRD Review: [project name]
Branch: [branchName]
Date: [today]

### Passed
Stories where ALL acceptance criteria passed.

- **US-XXX: [title]** — All N criteria passed

### Gaps Found
Stories where one or more criteria have gaps or non-standard behavior.

- **US-XXX: [title]**
  - [criterion text] — [what's wrong or non-standard]
  - [criterion text] — [what's wrong or non-standard]

### Untestable
Stories (or specific criteria) that couldn't be verified.

- **US-XXX: [title]**
  - [criterion text] — [why it couldn't be tested]

### Repo-wide Check Results
- Typecheck: PASS/FAIL [details if fail]
- Lint: PASS/FAIL/SKIPPED
- Tests: PASS/FAIL/SKIPPED [X passed, Y failed]
```

## Guidelines

- Do NOT skip stories marked `"passes": true` — verify them anyway, Ralph may have been wrong
- When a criterion is ambiguous, lean toward checking the code rather than marking untestable
- For UI criteria, always attempt browser verification before marking untestable
- If the dev server fails to start, mark all browser criteria as UNTESTABLE with the error
- Report exact file paths and line numbers when noting gaps
- Be specific about what's wrong — "button exists but has wrong variant" not just "gap"
