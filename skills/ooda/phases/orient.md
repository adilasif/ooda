# Orient Phase — Rigor, Design, and Plan Gates

The Orient phase runs after Observe, before any code is written. Its job is to pick a rigor level, enforce the design/plan gates required by that rigor, and verify the skill chain is ready to execute.

## Procedure

### 1. Rigor profile selection

Load `../rigor-profiles.md` for profile semantics. Then:

1. Start with the adapter's `rigor.default` (default: `standard`).
2. Scan the adapter's `## Notable Risks and Outage History` body section for language matching this task.
3. Estimate blast radius (one file, one package, cross-package, production safety).
4. Pick a rigor level and announce it: "Rigor: <level> — <one-line rationale>."
5. If escalating above `rigor.default`, state the reason explicitly. The user can override with "run this as patch" or "escalate to hardened."

### 2. Worktree gate

Load worktree policy from the adapter's `branch.worktree_policy` (default: `required`).

- **required:** if the task involves changes to any non-exempt file, create a worktree now using the skill named in `skills.using_git_worktrees` (default: `superpowers:using-git-worktrees`). If the slot is null, fall back to inline prose: "Create a worktree via `git worktree add` at a dedicated path before editing any non-exempt file. Use a branch name matching the `branch.format` template from the adapter."
- **optional:** ask the user before creating a worktree.
- **never:** skip.

Exempt file list: `branch.worktree_exempt_paths` from the adapter. Default: empty (strict). Common patterns: `.claude/`, `docs/`, `CLAUDE.md`, config files, lockfiles.

### 3. Design gate (if `rigor.profiles.<level>.design_required == true`)

Invoke the skill named in `skills.brainstorm` (default: `superpowers:brainstorming`).

- **If slot is set:** invoke the named skill via the Skill tool. Apply any project constraints from `## Custom Workflows` or `## Phase Overrides`.
- **If slot is null or adapter missing:** inline fallback: "Before writing any code, explore the design space. Identify 2-3 approaches with trade-offs and a recommendation. Present to the user section by section. Save the design artifact to `<plans.active_path>/YYYY-MM-DD-<topic>-design.md`. Get user approval before proceeding."

Do not proceed to the plan gate until the design is approved.

### 4. Plan gate (if `rigor.profiles.<level>.plan_required == true` or `== optional` with ≥3 tasks)

Invoke the skill named in `skills.writing_plans` (default: `superpowers:writing-plans`).

- **If slot is set:** invoke the named skill. Save plan to `<plans.active_path>/YYYY-MM-DD-<topic>.md`.
- **If slot is null:** inline fallback: "Break the work into bite-sized tasks (2-5 minutes each). Each task should have exact file paths, complete code, verification steps, and a commit step. Save to `<plans.active_path>/`."

### 5. Plan quality gate — verify external API calls

When a plan references external SDK/library calls, grep the codebase for existing usage of that API before committing the pattern to the plan. Use verified call patterns from existing code, not guesses from training data. This prevents plans from specifying plausible-but-wrong API calls that only fail at E2E validation time.

### 6. Tracking (if `issue_tracker` configured and no issue was found in Observe)

If the user is starting work without a pre-existing issue:

1. Propose a title and summary.
2. Ask: "I'll create an issue in <tracker> and a linked <doc store> entry. OK?"
3. On approval, use the adapter-declared MCP tools to create both, setting the issue state to the one matching "in progress" (from `issue_tracker.states`).
4. If `pm_doc_store.status_mapping` declares a matching doc store state, set that too.

## Graceful degradation

- **No adapter:** use synthetic defaults; rigor defaults to `standard`; skill slots default to `superpowers:*` where applicable; skip issue/doc store tracking.
- **Slot `skills.brainstorm` is null:** use inline fallback prose from step 3.
- **Slot `skills.writing_plans` is null:** use inline fallback prose from step 4.
- **No `issue_tracker`:** skip step 6.

## Interaction with adapter body sections

- `## Phase Overrides` — read for project-specific adjustments to any gate behavior.
- `## Custom Workflows` — read for any "before you start implementation, always do X" project-specific steps.
