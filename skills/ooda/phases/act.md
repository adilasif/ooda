# Act Phase — Implement, Ship, Learn

The Act phase is the longest and most substantive. It spans implementation through post-completion rituals. It has two halves: **implementation** (before the PR is opened) and **post-completion** (after the PR is merged, or the work is otherwise done).

## Implementation half

### 1. Worktree setup (if not already done in Orient)

If the Orient phase didn't create a worktree because no code changes were expected yet, create one now using the skill named in `skills.using_git_worktrees`. Apply the adapter's `branch.format` template for the branch name.

### 2. TDD loop

Invoke the skill named in `skills.tdd` (default: `ooda:test-driven-development` — this plugin's fork with MUTATE/KILL phases).

The TDD skill knows about rigor-aware kill-rate thresholds. At hardened/fortified rigor, it will execute the full RED → GREEN → MUTATE → KILL → REFACTOR loop with the adapter's `rigor.profiles.<level>.mutation_threshold` as the kill-rate target. At standard rigor, it skips MUTATE/KILL. At patch rigor, it runs RED → GREEN only.

If `skills.tdd` is set to `superpowers:test-driven-development` (the upstream version), the MUTATE/KILL phases are skipped entirely regardless of rigor — the adapter override signals the project doesn't want mutation testing.

### 3. Subagent-driven execution (for plans with ≥3 tasks)

If a plan exists from the Orient phase with 3 or more tasks, invoke the skill named in `skills.subagent_driven_development` (default: `superpowers:subagent-driven-development`) or `skills.executing_plans` (default: `superpowers:executing-plans`). Choose based on user preference — subagent-driven is faster, executing-plans has more user checkpoints.

### 4. Dev deploy (if `dev_deploy.enabled` and trigger paths touched)

After implementation and local tests pass, if any files touched match `dev_deploy.trigger_paths`, push the branch and wait for the dev deploy flow. The Decide phase's Gate 4 handles the actual validation; this step just ensures the deployment is in flight.

### 5. Hand off to Decide phase

When implementation is complete, load `decide.md` and run its pre-PR gate list.

## Post-completion half

Run these four steps after the work is done (PR created, task complete, plan executed):

### 1. Validation gap check

Ask yourself:

> "Were there issues during implementation that existing validation didn't catch? If so, propose one of:
> 1. A new entry in the project's validation registry (if `validation_registry.path` is set)
> 2. A new test pattern or test case
> 3. An improvement to an existing check
> 4. A CLAUDE.md or memory update to prevent the issue"

Present findings to the user. Implement small improvements in the same PR if trivial; file tracking items for larger ones.

### 2. Knowledge capture

Invoke the skill named in `skills.capture_knowledge`.

- If set: run it. The skill handles session scanning, classification, structured doc generation, and cascade checks for stale guides/runbooks.
- If null: inline fallback: "Summarize decisions, experiments, failures, evolution, and rejected approaches from this session into structured documents under `knowledge.destination_path`. Check `knowledge.cascade_check_paths` for any guides/runbooks that may need updating based on what you learned."

Additionally, save learnings that apply to future sessions as feedback memories (for corrections) or project memories (for discoveries).

### 3. Changelog entry (if `pm_doc_store.changelog_database_id` or equivalent is configured)

After each PR, add an entry to the project's changelog destination:

1. Gather context: issue ID, PR number, what changed, user/developer impact.
2. Categorize per project convention (typically: Features, Fixes, Infrastructure).
3. Create the entry via the project's configured mechanism (Notion DB, file append, etc.).

The specific format lives in the adapter's `## Custom Workflows` or `## Release Process` body section. Follow the project's convention exactly.

If the adapter has no changelog destination, skip this step.

### 4. Post-completion stash hygiene

Run `git stash list`. If stashes exist that weren't there at session start, the session created them (likely from branch switching or interrupted work). Flag them to the user.

### 5. Session debrief (if rigor requires)

If `rigor.profiles.<level>.debrief_required` is true, load `../debrief.md` and walk through the four-question framework with the user. If persistence is configured (`pm_doc_store.debrief_database_id`), record the debrief there. Save actionable corrections as feedback memories.

## Release changelog (if applicable)

At release time (when cutting a version / deploying to production), follow the adapter's `## Release Process` body section if present. This typically involves compiling unreleased changelog entries, grouping them, drafting an announcement, presenting to the user for approval, posting to the configured channel, and marking entries with the release tag.

If no `## Release Process` section exists, skip — release management is the user's responsibility without a configured flow.

## Graceful degradation

- **No adapter:** use synthetic defaults; inline prose fallbacks for every skill invocation; skip dev deploy, changelog, and persistence steps.
- **`skills.capture_knowledge` null:** inline prose fallback (step 2 of post-completion).
- **No changelog destination:** skip step 3 of post-completion.
- **No debrief requirement:** offer to run the debrief but don't enforce.

## Interaction with adapter body sections

- `## Custom Workflows` — read during implementation for project-specific workflow steps (e.g., knowledge DB rebuilds, pre-commit requirements).
- `## Release Process` — read at release time for the exact compile-and-post flow.
- `## Pre-PR Gate Additions` — these are added to the Decide phase's gate list, not this phase's. See `decide.md`.
