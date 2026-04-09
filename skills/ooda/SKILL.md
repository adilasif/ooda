---
name: ooda
description: Engineering lifecycle orchestrator — OODA-loop-structured development cycle with rigor profiles, phase handover contracts, session debriefs, and per-project adapter bindings. Use at session start, before implementation, before creating a PR, and after completing work.
user-invocable: true
argument-hint: "[issue-id]"
---

# OODA — Engineering Lifecycle

The development lifecycle follows Boyd's OODA loop:

- **Observe:** Session context loading — adapter discovery, issue lookup, plan file detection, stash hygiene, rigor-assessment inputs
- **Orient:** Rigor profile selection, design and plan gates, understanding the problem space
- **Decide:** Phase handover contracts, validation checks, pre-PR review gates — is the evidence sufficient to proceed?
- **Act:** Implementation, PR creation, knowledge capture, session debrief — ship and learn

This skill is project-agnostic. Project-specific behavior (issue tracker, quality commands, knowledge destinations, skill slot bindings) is read from a per-project **adapter file** at `.claude/ooda.project.md` (or variants). Missing adapter → default mode. Missing adapter slot → graceful degradation for that concern only.

## Adapter discovery protocol

When the user invokes `/ooda` (with or without an issue ID argument), perform these steps in order:

1. **Look for the adapter file** at these paths, first-match-wins:
   - `.claude/ooda.project.md`
   - `.claude/skills/ooda/project.md`
   - `ooda.project.md` (repo root)

2. **If no adapter found:**
   Announce: "No `/ooda` adapter detected in this project. Running in **default mode** — I'll use universal lifecycle prose without project-specific wiring. To enable project bindings, run `/ooda-init`."
   Then proceed with default mode (see "Default mode" below).

3. **If adapter found but frontmatter invalid** (missing `schema_version`, malformed YAML, unknown top-level keys):
   Announce the specific error and stop. Offer: "Run `/ooda-validate` for full diagnostics."

4. **If adapter found and valid:**
   - Parse frontmatter into session context.
   - Note which adapter body sections are present (`## Project Overview`, `## Notable Risks and Outage History`, `## Custom Workflows`, `## Phase Overrides`, `## Release Process`, `## Session Start Checklist`, `## Pre-PR Gate Additions`, `## Tenant / Environment Inventory`). Missing sections mean "use default prose for that concern."
   - Proceed to the Observe phase (see `phases/observe.md`).

### Default mode (synthetic adapter)

When no adapter file is present, the skill runs with these synthetic defaults:
- `skills.*` slots resolve to `superpowers:*` equivalents where superpowers has a matching skill (e.g., `skills.brainstorm: superpowers:brainstorming`).
- `skills.tdd` defaults to `ooda:test-driven-development` (this plugin's fork).
- `skills.capture_knowledge`, `skills.review_pr` default to `null` — obligation prose inlined, no skill invocation.
- `rigor.default` is `standard`.
- `rigor.profiles.*` use hard-coded universal values (see `rigor-profiles.md`).
- `branch.worktree_policy` defaults to `required` for non-exempt files.
- `branch.worktree_exempt_paths` defaults to empty list.
- All of `issue_tracker`, `pm_doc_store`, `dev_deploy`, `validation_registry`, `auto_merge`, `quality.*` are absent — corresponding phases are skipped with an announcement.
- `plans.*` default to `docs/plans/` (active) and `docs/plans/completed/` (archived).
- `knowledge.destination_path` defaults to `docs/knowledge/`.

## Phase routing

This SKILL.md is a router. The substantive behavior lives in per-phase files loaded on demand.

| Phase | When to load | File | Purpose |
|---|---|---|---|
| **Observe** | Session start, after adapter discovery | `phases/observe.md` | Session context loading, stash hygiene, issue/epic lookup, state summary announcement |
| **Orient** | Before any design, plan, or implementation work | `phases/orient.md` | Rigor profile selection, design gate (if required), plan gate (if required), plan quality check |
| **Decide** | Before validation, code review, or PR creation | `phases/decide.md` | Phase handover contract checks, validation registry checks, pre-PR gate list, code review invocation |
| **Act** | Implementation through completion | `phases/act.md` | Worktree setup, TDD loop, dev deploy (if configured), PR creation, knowledge capture, plan archival, changelog, session debrief, post-completion stash hygiene |

### Reference files (loaded on demand)

- `rigor-profiles.md` — the four rigor profile definitions (patch, standard, hardened, fortified). Load when selecting a rigor level in the Orient phase.
- `handover-contracts.md` — the evidence-per-phase matrix. Load at any phase transition to verify readiness.
- `debrief.md` — the four-question root cause framework. Load when running a session debrief in the Act phase.

