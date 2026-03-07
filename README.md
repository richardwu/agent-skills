# Agent Skills

Collection of reusable skills for autonomous coding agents.

## Ralph

Long-running AI agent loop for implementing user stories from PRDs.

### Quick Install

```sh
curl -fsSL https://raw.githubusercontent.com/richardwu/agent-skills/main/ralph/install.sh | sh
```

This installs Ralph into `./scripts/ralph/` in your current directory.

### Usage

After installation, create a `prd.json` in the ralph directory (or convert an existing PRD using the `ralph` skill), then run:

```sh
./scripts/ralph/ralph.sh [--tool amp|claude] [max_iterations]
```

**Options:**
- `--tool amp` (default): Use Anthropic's Amp tool
- `--tool claude`: Use Claude Code
- `max_iterations`: Maximum iterations to run (default: 10)

### How It Works

Ralph reads a `prd.json` with user stories and iteratively:
1. Picks the highest priority incomplete story
2. Implements the story
3. Runs quality checks
4. Commits the changes
5. Updates the PRD progress

Ralph stops when all stories are complete or max iterations reached.

### Skills

- **prd**: Generate a Product Requirements Document
- **ralph**: Convert an existing PRD to prd.json format for Ralph
- **review-prd**: Verify Ralph PRD user stories are implemented correctly
- **fix-pr**: Fix issues on the current PR

## Skills Directory

Skills are located in the `./skills/` directory and can be used by Claude agents.
