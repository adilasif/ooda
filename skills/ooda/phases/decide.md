# Decide Phase — Handover Contracts and Pre-PR Gates

The Decide phase runs after implementation, before the PR is opened. Its job is to verify all required evidence exists, run the pre-PR gate list, and ensure the work is ready for review.

## Procedure

### 1. Handover contract check

Load `../handover-contracts.md`. For the handover from "Implement → Validate" at your current rigor level, verify every required piece of evidence exists:

- Tests pass (run via `quality.unit_tests` from the adapter, or fall back to project-native test command if unset).
- Lint and format checks clean (run via `quality.format_lint_typecheck` from the adapter).
- Plan archival ready (the plan file in `plans.active_path` has an Outcomes section populated and is ready to move to `plans.completed_path`).
- Dev deploy evidence (for hardened/fortified rigor; see step 5).

Any missing evidence → go back, fix, re-run.

### 2. Validation registry check (if `validation_registry` configured)

If the adapter's `validation_registry.path` is set, read that file and run every validation that matches files modified in this session. Validation registries map file globs to required commands (e.g., "if you changed `packages/foo/`, run `just test-foo`"). Execute each matching validation and report results.

### 3. Pre-PR gate list (universal)

Run each of these in order. Every gate is required regardless of rigor (unless noted otherwise).

**Gate 1 — Code review.** Invoke the skill named in `skills.review_pr`.
- If set: run it. Address all Critical and Important findings before proceeding.
- If null: invoke `skills.requesting_code_review` (default: `superpowers:requesting-code-review`) to walk through the review checklist yourself.

**Gate 2 — Quality gate.** Run `quality.format_lint_typecheck` from the adapter. Stage any auto-fixed files. Re-run to verify clean.
- If `quality.pre_push` is set, run that too.

**Gate 3 — Unit tests.** Run `quality.unit_tests` from the adapter. Ensure no regressions.

**Gate 4 — Dev testing (if runtime/config changes).** Check whether any files in this session match `dev_deploy.trigger_paths` from the adapter. If yes and `dev_deploy.enabled` is true:
- Follow the dev deploy flow: push branch, wait for deployment, run `dev_deploy.validate_command`, dial/test the deployed version.
- Internal-only refactors may skip this — note in PR description.

**Gate 5 — Knowledge capture + doc updates (before push).** Invoke `skills.capture_knowledge`. If null, inline fallback: "Summarize decisions, experiments, failures, evolution, and rejected approaches from this session. Save to `knowledge.destination_path`." Commit the knowledge docs to the branch BEFORE the final push.

**Gate 6 — Plan archival (before push).** Check `plans.active_path` for a related plan. Move it to `plans.completed_path` with an Outcomes section populated. Commit the move to include it in the PR.

**Gate 7 — Commit hygiene.** Squash WIP/fixup commits — each commit on the main branch should be a logical unit.

**Gate 8 — Epic phase-children check (multi-phase issues only).** If the issue's description has phase-structured language (`Phase 1/2/3`, `Part A/B/C`, `Tier 1/2/3`, `MVP / Full pipeline`), verify that each phase either (a) ships in this PR, (b) already has a sibling tracking issue, or (c) has been explicitly de-scoped via a comment on the parent. Filing siblings before marking ready is cheap; recovering lost scope weeks later is expensive.

**Gate 9 — Draft PR (if `auto_merge.default_draft` is true).** Create the PR as a draft (e.g., `gh pr create --draft`). After verifying CI passes and all post-implementation work is committed, mark ready manually. This prevents auto-merge tools from merging before you're done.

## Graceful degradation

- **No adapter:** skip gates 4, 5 (prose fallback only), 9 (no draft auto-merge rule).
- **`quality.*` slots missing:** skip gate 2 or 3, announce "quality gate not configured — self-check manually before pushing."
- **`validation_registry` missing:** skip step 2.
- **`dev_deploy` missing:** skip gate 4.

## Interaction with adapter body sections

- `## Pre-PR Gate Additions` — read for project-specific gates to add to the list in step 3. Common additions: tenant-specific validation, audio/UX testing, compliance review.
- `## Phase Overrides` — read for modifications to the default gate behavior.
