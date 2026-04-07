---
name: multi-agent-review
description: Multi-agent code review using 3 parallel subagents (Claude, GPT, Gemini) to review branch changes against origin/main. Validates findings against actual diffs and posts consolidated report to GitHub PR. Use before opening a PR, when wanting multiple AI perspectives on code changes, or for large changesets that might truncate in single-agent reviews. Triggers on "multi-agent review", "review my branch", "review changes against main", "AI code review", or "review before PR".
---

# Multi-Agent Code Review

## Prerequisites

- Cursor with Task tool support for subagent orchestration
- `gh` CLI (authenticated)
- Git repository with `origin/main` remote tracking branch

## Diff Command Reference

| Change type | Command |
|---|---|
| Committed changes | `git --no-pager diff --no-color $BASE..HEAD -- <path>` |
| Uncommitted (staged/unstaged) | `git --no-pager diff --no-color HEAD -- <path>` |
| Untracked files | `cat <path>` (review full contents) |
| Check if untracked | `git ls-files --others --exclude-standard -- <path>` |

Use these commands throughout the workflow wherever diffs are needed.

## Workflow

### Step 1 -- Compute review base commit

```bash
git fetch origin main 2>/dev/null
BASE=$(git merge-base --fork-point origin/main HEAD 2>/dev/null || git merge-base origin/main HEAD)
```

Use `--fork-point` first (more accurate for rebased branches), fall back to plain `merge-base`.

If both fail, report error: "Could not determine base commit. Check that origin/main exists and has been fetched." and stop.

### Step 2 -- Gather summary of changes

```bash
# Committed changes since base
FILES_COMMITTED=$(git --no-pager diff --name-only $BASE..HEAD)
STAT_COMMITTED=$(git --no-pager diff --stat $BASE..HEAD)

# Uncommitted changes (staged + unstaged + untracked)
FILES_UNCOMMITTED=$(git --no-pager diff --name-only HEAD; git ls-files --others --exclude-standard)
STAT_UNCOMMITTED=$(git --no-pager diff --stat HEAD)

# Combined unique file list
FILES=$(echo "$FILES_COMMITTED"$'\n'"$FILES_UNCOMMITTED" | sort -u | sed '/^$/d')
STAT="$STAT_COMMITTED"
```

- If FILES is empty: report "No changes to review" and stop.
- If any files are binary: note them in the summary but exclude from review.
- Note: untracked files have no base to diff against -- review their full contents instead.

### Step 3 -- Launch 3 review parallel agents

Use the Task tool to launch 3 parallel subagents. Before constructing each prompt:

1. Read `review-persona.md` (relative to this skill directory) for the shared reviewer persona
2. Read the subagent's definition file from `agents/` for its specific focus area
3. Combine both with the review context below into the subagent prompt

Subagent definitions (each references `review-persona.md`):

- `agents/multi-review-claude.md` — "The Architect": architecture, design, abstractions (latest Claude Opus model)
- `agents/multi-review-gpt.md` — "The Detective": correctness, edge cases, error handling (latest GPT Codex model)
- `agents/multi-review-gemini.md` — "The Guardian": security, performance, production readiness (latest Gemini Pro model)

Construct each subagent's prompt by concatenating:

1. The contents of `review-persona.md`
2. The contents of the subagent's definition file (body only, after frontmatter)
3. The review context block below (with `{{BASE}}`, `{{FILES}}`, `{{STAT}}` replaced from steps 1-2)

Review context block:

```
---

## Review Context

BASE commit: {{BASE}}

Changed files:
{{FILES}}

Stat summary:
{{STAT}}

## Instructions

- Use terminal commands to inspect diffs file-by-file to avoid truncation:
  - For committed changes: `git --no-pager diff --no-color {{BASE}} -- <path>`
  - For uncommitted changes (staged/unstaged): `git --no-pager diff --no-color HEAD -- <path>`
  - For untracked files (new files not yet staged): `cat <path>` (review full contents)
- To check if a file is untracked: `git ls-files --others --exclude-standard -- <path>`
- Only comment on things you actually viewed from the diff or file output
- If you hit output truncation, state what you reviewed and what you did not
- For binary files, note their filepath but skip review
- Follow the output format specified in the review persona above
```

### Step 4 -- Wait for all 3 responses

Allow up to 5 minutes per subagent. If a subagent errors or times out, proceed with available results and note the gap in the final report under Cross-Review Notes.

### Step 5 -- Validate findings

For each issue or recommendation from any subagent:

1. Extract the claim (file path, line number, issue description)
2. Run the appropriate diff command:
   - Committed files: `git --no-pager diff --no-color $BASE -- <file>`
   - Uncommitted files: `git --no-pager diff --no-color HEAD -- <file>`
   - Untracked files: `cat <file>` (verify the referenced content exists)
3. Verify the claim:
   - Does the referenced code actually exist at that location?
   - Is the line number / location accurate?
   - Does the issue logic hold when reading the actual code?
4. Categorize each finding:
   - ✅ Verified -- claim confirmed by diff
   - ⚠️ Partially verified -- directionally correct but details slightly off
   - ❌ Unverified -- not supported by diff (remove from report)
   - 🔮 Speculative -- assumptions beyond what the diff shows

Remove unverified claims from the final report. Mark speculative claims clearly.

### Step 6 -- Generate final report and post to PR

Compile the consolidated markdown report (see Step 7 for format).

Attempt to post as a PR comment:

```bash
gh pr comment --body "<report>"
```

If `gh` fails (no PR exists, auth issue, etc.), output the full report in the response instead and note the comment failure.

### Step 7 -- Final response format

```markdown
## Multi-Agent Code Review

### 1. Overall Assessment

[Summary. Include PR comment link if posted successfully.]

### 2. Strengths

[Points agreed upon across subagents]

### 3. Issues by Priority

#### Critical

- **`file.ts:42` -- Description** (flagged by: Claude, GPT, Gemini)
  <details><summary>Prompt to fix with AI</summary>

  [Copy-pasteable prompt for an LLM to fix this specific issue]

  </details>

#### Important

- ...

#### Minor

- ...

### 4. Specific Recommendations

[Consolidated actionable recommendations]

### 5. Testing Feedback

[Test coverage gaps, suggested test cases]

### 6. Cross-Review Notes

[Discrepancies between subagents, uncertainties, gaps,
which subagents timed out if any]
```

For each issue in section 3, include which subagents flagged it. Issues flagged by all 3 subagents are highest confidence and should be listed first within their priority level.

