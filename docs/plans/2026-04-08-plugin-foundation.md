# ooda Plugin Foundation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first installable version of the `ooda` Claude Code plugin — plugin manifest, core `/ooda` skill (split across router + phase files + references), adapter template, forked `test-driven-development` skill, three commands (`/ooda`, `/ooda-init`, `/ooda-validate`), test fixtures, CI, and CLAUDE.md. After this plan, the plugin runs cleanly in default mode on any project. Dogfood migration of CivicReach is a separate plan.

**Architecture:** Core skill + per-project-adapter pattern. The core `/ooda` skill lives at `skills/ooda/SKILL.md` as a short router that delegates to phase files under `phases/` and reference files (`rigor-profiles.md`, `handover-contracts.md`, `debrief.md`) loaded on demand. Sub-skills are invoked via adapter-declared names (indirection through the `skills.*` frontmatter slots), never by hardcoded reference. The forked `test-driven-development` skill adds MUTATE/KILL phases to the upstream superpowers RED-GREEN-REFACTOR loop.

**Tech Stack:** Markdown skills, YAML frontmatter, Bash helper scripts, Claude Code plugin manifest (`.claude-plugin/plugin.json`), GitHub Actions (markdownlint + YAML parse checks).

**Working directory:** `/home/adil/dev/git/ooda/` (the plugin repo; greenfield, no worktree needed — it's its own clean repo).

**Design reference:** `docs/design/2026-04-08-initial-design.md` in this repo (committed). Refer to it whenever a task needs clarification on intent.

**Verification philosophy for this plan:** Because the deliverable is mostly Markdown prose, traditional RED-GREEN-REFACTOR doesn't map cleanly. Instead, each file-producing task follows this pattern:
1. **Write the content** — exact markdown + frontmatter, no placeholders
2. **Verify format** — YAML frontmatter parses via Python; markdownlint clean (once CI is in place, earlier tasks validate manually)
3. **Commit** — conventional commit message, one logical unit per commit

For the validator command and fixture-driven tasks, we use fixture files as acceptance criteria.

---

## Phase A: Plugin manifest and scaffold (3 tasks)

### Task 1: Create plugin manifest

**Files:**
- Create: `.claude-plugin/plugin.json`

- [ ] **Step 1: Create the manifest file**

```json
{
  "name": "ooda",
  "description": "Engineering lifecycle orchestrator for Claude Code: OODA-loop-structured dev cycle with rigor profiles, phase handover contracts, and per-project adapters. Built on superpowers.",
  "version": "0.0.1",
  "author": {
    "name": "Adil Asif",
    "url": "https://github.com/adilasif"
  },
  "homepage": "https://github.com/adilasif/ooda",
  "repository": "https://github.com/adilasif/ooda",
  "license": "MIT",
  "keywords": [
    "skills",
    "workflow",
    "ooda",
    "lifecycle",
    "tdd",
    "rigor-profiles"
  ],
  "superpowersCompatibility": {
    "tested": "5.0.7",
    "minimum": "5.0.0",
    "maximum": null
  }
}
```

- [ ] **Step 2: Verify the JSON parses**

Run: `python3 -c "import json; json.load(open('.claude-plugin/plugin.json'))" && echo OK`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "chore: add plugin manifest (v0.0.1)"
```

### Task 2: Create directory scaffolding

**Files:**
- Create: `skills/ooda/phases/.gitkeep`
- Create: `skills/ooda/templates/.gitkeep`
- Create: `skills/test-driven-development/.gitkeep`
- Create: `commands/.gitkeep`
- Create: `scripts/.gitkeep`
- Create: `tests/fixtures/.gitkeep`
- Create: `.github/workflows/.gitkeep`

- [ ] **Step 1: Create all directories and placeholder .gitkeep files**

```bash
mkdir -p skills/ooda/phases
mkdir -p skills/ooda/templates
mkdir -p skills/test-driven-development
mkdir -p commands
mkdir -p scripts
mkdir -p tests/fixtures
mkdir -p .github/workflows
touch skills/ooda/phases/.gitkeep
touch skills/ooda/templates/.gitkeep
touch skills/test-driven-development/.gitkeep
touch commands/.gitkeep
touch scripts/.gitkeep
touch tests/fixtures/.gitkeep
touch .github/workflows/.gitkeep
```

- [ ] **Step 2: Verify all directories exist**

Run: `find . -type d -not -path './.git*' -not -path './docs*' | sort`
Expected output (order may vary):
```
.
./.claude-plugin
./.github
./.github/workflows
./commands
./scripts
./skills
./skills/ooda
./skills/ooda/phases
./skills/ooda/templates
./skills/test-driven-development
./tests
./tests/fixtures
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: scaffold plugin directory structure"
```

### Task 3: Write CLAUDE.md for the plugin repo

**Files:**
- Create: `CLAUDE.md`

This is the repo-level guidance file that Claude Code reads when working in the ooda repo itself. Keep it brief — the important content is in the skills themselves.

- [ ] **Step 1: Write CLAUDE.md**

```markdown
# CLAUDE.md — ooda plugin repo

This file provides guidance for Claude Code agents working in the **ooda plugin repo itself** (as opposed to projects that install ooda). If you're a Claude Code agent helping build, test, or publish this plugin, read this first.

## What this repo is

The `ooda` Claude Code plugin — an engineering lifecycle orchestrator. It ships:
- `skills/ooda/` — the lifecycle orchestrator skill (core `/ooda`)
- `skills/test-driven-development/` — a fork of superpowers' TDD skill with MUTATE/KILL phases
- `commands/` — three slash commands: `/ooda`, `/ooda-init`, `/ooda-validate`
- `scripts/diff-upstream-tdd.sh` — helper for syncing the TDD fork with upstream

## Working on this plugin

- **Read the design doc first:** `docs/design/2026-04-08-initial-design.md` is the source of truth for intent, architecture, and the adapter schema contract. Before changing any skill file, make sure your change is consistent with the design.
- **Verify YAML frontmatter before committing:** every skill file has YAML frontmatter that must parse cleanly. Run `python3 -c "import yaml; import frontmatter; frontmatter.load(open('path/to/skill.md'))"` or equivalent before committing structural changes.
- **Don't reference sub-skills by canonical name in the core skill.** The core is project-agnostic. Always route through adapter `skills.*` slots. The only exception is prose like "the brainstorming skill" (descriptive, no hardcoded plugin:name reference).
- **The forked TDD skill is a first-class citizen, not a workaround.** It has its own NOTICE.md with attribution and a sync workflow via `scripts/diff-upstream-tdd.sh`. Treat upstream changes as patch-level plugin releases.

## Dependencies

- **Required plugin dependency:** [superpowers](https://github.com/obra/superpowers) (MIT, by Jesse Vincent). The core `/ooda` skill invokes superpowers skills (brainstorming, writing-plans, systematic-debugging, etc.) via adapter-declared slot names.
- **Recommended when testing:** install both plugins in a scratch Claude Code project.

## Commit conventions

- Use conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `ci:`, `refactor:`.
- Keep commits small — one file or one logical change per commit is ideal for this plugin.
- Never commit to main directly during feature work — use branches and PRs. The initial commit and this plan's tasks may commit directly to main since the repo has no enforcement yet.

## TDD fork sync

Run `scripts/diff-upstream-tdd.sh` when you notice a new superpowers release, or every 4-6 weeks. The script shows three diffs: what changed upstream, our fork vs upstream, and a suggested cherry-pick list.

## Publishing

This plugin targets the Claude Code plugin marketplace. Publishing is handled by a separate plan (`docs/plans/2026-04-08-plugin-publish.md` when written). Don't publish from working commits — tag a version first.
```

- [ ] **Step 2: Verify the file**

Run: `wc -l CLAUDE.md && head -5 CLAUDE.md`
Expected: ~50 lines, first line `# CLAUDE.md — ooda plugin repo`

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add CLAUDE.md for plugin repo guidance"
```

---

## Phase B: Core skill router (4 tasks)

The `skills/ooda/SKILL.md` router is short (~100 lines) and delegates to phase files and reference files. It's the entry point Claude loads when `/ooda` is invoked.

### Task 4: Write SKILL.md frontmatter and OODA overview

**Files:**
- Create: `skills/ooda/SKILL.md`

- [ ] **Step 1: Write the first part of SKILL.md (frontmatter + overview)**

```markdown
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

```

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "import yaml, sys; content = open('skills/ooda/SKILL.md').read(); assert content.startswith('---\n'); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/SKILL.md
git commit -m "feat(ooda): add skill router frontmatter and OODA overview"
```

### Task 5: Add adapter discovery protocol to SKILL.md

**Files:**
- Modify: `skills/ooda/SKILL.md` (append)

- [ ] **Step 1: Append the adapter discovery section**

```markdown

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
```

- [ ] **Step 2: Verify frontmatter still parses after append**

Run: `python3 -c "import yaml, sys; content = open('skills/ooda/SKILL.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/SKILL.md
git commit -m "feat(ooda): add adapter discovery protocol and default mode spec"
```

### Task 6: Add phase routing table and reference file pointers to SKILL.md

**Files:**
- Modify: `skills/ooda/SKILL.md` (append)

- [ ] **Step 1: Append the phase routing section**

```markdown

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
```

- [ ] **Step 2: Verify append did not corrupt YAML**

Run: `python3 -c "import yaml; content = open('skills/ooda/SKILL.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/SKILL.md
git commit -m "feat(ooda): add phase routing table and reference file index"
```

### Task 7: Add skill invocation rule + skill name prefix convention to SKILL.md

**Files:**
- Modify: `skills/ooda/SKILL.md` (append)

- [ ] **Step 1: Append the skill invocation discipline**

```markdown

## Skill invocation rule (the key discipline)

Whenever this skill or any phase file under it refers to a sub-skill (e.g., "the brainstorming skill," "the TDD skill," "the code review skill"), you MUST:

1. **Read the adapter's `skills.*` slot** for that sub-skill role.
2. **If set:** invoke the named skill via the Skill tool. Supply any project-specific constraints from the adapter's `## Custom Workflows` body section.
3. **If null, unset, or the adapter is missing:** the obligation still holds. Use the inline prose fallback provided in the relevant phase file.

Never invoke a sub-skill by hardcoded canonical name from the core skill files. The indirection through `skills.*` is what makes `/ooda` project-agnostic.

### Skill name prefixes

Skill slot values use a `<source>:<skill-name>` format:

- `superpowers:<skill>` — a skill from the upstream superpowers plugin (e.g., `superpowers:brainstorming`, `superpowers:writing-plans`)
- `ooda:<skill>` — a skill shipped by this plugin (e.g., `ooda:test-driven-development` for the forked TDD skill)
- `<other-plugin>:<skill>` — a skill from any other installed plugin (e.g., `pr-review-toolkit:review-pr`)
- `local:<skill>` — a project-local skill living in the consumer project's `.claude/skills/<skill>/` directory (e.g., `local:capture-knowledge` for a custom per-project skill)
- `null` — no skill; fall back to inline prose for that obligation

## What to do next

After reading this router, immediately load `phases/observe.md` and begin the Observe phase.
```

- [ ] **Step 2: Verify the full file parses and check line count**

Run: `python3 -c "import yaml; content = open('skills/ooda/SKILL.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')" && wc -l skills/ooda/SKILL.md`
Expected: `OK` and line count between 100 and 150

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/SKILL.md
git commit -m "feat(ooda): add skill invocation rule and name prefix convention"
```

---

## Phase C: Reference files (3 tasks)

### Task 8: Write `rigor-profiles.md`

**Files:**
- Create: `skills/ooda/rigor-profiles.md`

This reference file describes the four rigor profiles. Thresholds come from the adapter's frontmatter; this file explains what each profile *means*.

- [ ] **Step 1: Write the file**

```markdown
# Rigor Profiles

Rigor profiles scale engineering discipline to task blast radius. **Default: `standard`.** Escalate based on risk; user can override with explicit instruction.

The profile selection is YOUR judgment call at the start of the Orient phase. Ask "what breaks if this goes wrong?" and pick accordingly.

Each profile's concrete thresholds (mutation kill rate, dev deploy requirement, debrief requirement, design/plan gate enforcement) are read from the adapter's `rigor.profiles.<name>.*` frontmatter. This file describes the profile *semantics*; the adapter carries the values.

## Profile definitions

### Patch

**When to use:** Config changes, docs, dependency bumps, worktree-exempt files, typo fixes. Anything where the cost of rollback is near-zero.

**Discipline:** Minimal. RED → GREEN only (no refactor enforcement). Worktree not required. Knowledge capture optional (only if something surprising happened). No debrief.

### Standard

**When to use:** Bug fixes, small features, single-package refactors. The common case.

**Discipline:** Full RED → GREEN → REFACTOR. Worktree required. Plan optional (skip if <3 tasks). Dev deploy only if runtime/config changes and the adapter's `dev_deploy.trigger_paths` are touched. Knowledge capture if decisions or failures occurred. Debrief optional.

### Hardened

**When to use:** Multi-tenant changes, data pipelines, new integrations, cross-system work — any change whose effects spread beyond a single file or package.

**Discipline:** Design required (invoke the brainstorming skill). Plan required (invoke the writing-plans skill). RED → GREEN → MUTATE → KILL → REFACTOR with mutation kill rate per adapter (typically ≥80%). Worktree required. Dev deploy required. Knowledge capture required. Debrief required.

### Fortified

**When to use:** Production safety (alerting, failover, transfer flow), grounding logic, billing — anything that has caused an outage before, or would cause one if it fails silently. See the adapter's `## Notable Risks and Outage History` section for project-specific triggers.

**Discipline:** Same as hardened, with additional requirements:
- Mutation kill rate threshold is higher (typically ≥90%, per adapter).
- Dev deploy verification drill required (exercising failure modes, not just happy path).
- Equivalent mutant registry required for any surviving mutants — each survivor must be documented as either a genuine test gap or an equivalent mutant with justification.

## How to pick a rigor level

1. Start with the adapter's `rigor.default` value (typically `standard`).
2. Scan the adapter's `## Notable Risks and Outage History` section — does any language match this task?
3. Consider blast radius: if it breaks, what's affected? One file → patch or standard. One package → standard or hardened. Cross-package or multi-tenant → hardened. Production safety → fortified.
4. If unsure, escalate one level. The cost of over-rigor is a slightly longer session; the cost of under-rigor is an outage.
5. Announce the chosen rigor at the start of the Orient phase: "Rigor: standard (escalate to hardened if scope expands)."
```

- [ ] **Step 2: Verify file**

Run: `wc -l skills/ooda/rigor-profiles.md && head -3 skills/ooda/rigor-profiles.md`
Expected: 40-60 lines, first line `# Rigor Profiles`

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/rigor-profiles.md
git commit -m "feat(ooda): add rigor-profiles.md reference"
```

### Task 9: Write `handover-contracts.md`

**Files:**
- Create: `skills/ooda/handover-contracts.md`

- [ ] **Step 1: Write the file**

```markdown
# Phase Handover Contracts

Each phase must produce specific evidence before the next phase can start. Requirements scale with rigor level.

This file is loaded on demand at phase transitions. Before moving from one phase to another, verify the required evidence exists.

## Evidence matrix

| Handover | Patch | Standard | Hardened | Fortified |
|----------|-------|----------|----------|-----------|
| **Design → Plan** | skip | skip | design doc exists and was approved by user | design doc exists and was approved by user |
| **Plan → Implement** | skip | optional (skip if <3 tasks) | plan file exists and was approved by user | plan file exists and was approved by user |
| **Implement → Validate** | tests pass | tests pass + lint clean | tests pass + lint clean + plan archival ready | tests pass + lint clean + plan archival ready |
| **Validate → Review** | skip | validation registry checks (if adapter declares one) | registry + dev deploy evidence | registry + dev deploy + verification drill evidence |
| **Review → Complete** | self-review | review skill invoked, findings addressed | review skill invoked, findings addressed | review skill invoked, findings addressed |
| **Complete → Done** | skip | knowledge capture (if anything surprising) | knowledge + changelog entry + debrief | knowledge + changelog + debrief + backlog proposals if needed |

## How to use this matrix

1. Before starting a phase, look at the row for the handover INTO that phase and the column for your current rigor level.
2. Verify each listed piece of evidence exists (design doc, plan file, tests passing, dev deploy output, etc.).
3. If evidence is missing, complete the previous phase first. Do not proceed.
4. Evidence that's marked "skip" at your rigor level can be bypassed — but if you escalate rigor mid-session (e.g., realized the change is larger than expected), re-check the matrix for the new level.

## Interaction with the adapter

The evidence requirements in this table are *universal structural requirements*. The adapter's `rigor.profiles.*.*` frontmatter supplies the *project-specific thresholds* (e.g., mutation kill rate target, dev deploy verification drill requirement). When a handover depends on a threshold, read it from the adapter, not from this file.
```

- [ ] **Step 2: Verify file**

Run: `wc -l skills/ooda/handover-contracts.md`
Expected: ~30-40 lines

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/handover-contracts.md
git commit -m "feat(ooda): add handover-contracts.md reference"
```

### Task 10: Write `debrief.md`

**Files:**
- Create: `skills/ooda/debrief.md`

- [ ] **Step 1: Write the file**

```markdown
# Session Debrief — Four-Question Root Cause Framework

At the end of every substantive session (not just PR sessions — research, debugging, design, and planning sessions count too), run a brief debrief. This is distinct from knowledge capture: knowledge capture documents what you learned about the *system*; the debrief reflects on how the *session itself* went.

**Present this to the user — don't write it silently.** The debrief is a conversation, not a form.

## Questions

Walk through these. Be honest and specific — name the actual thing, not a vague category. **Write one sentence per item. Be brutal.**

1. **What went well?** — What was efficient, smooth, or produced a better outcome than expected? Name the specific practice, tool, or decision.

2. **What went poorly?** — What was frustrating, slow, required rework, or produced a worse outcome than expected? Include your own mistakes (Claude's), not just external blockers.

3. **Why?** — For each thing that went poorly, answer these four diagnostic questions. If the answer is "yes," that's your root cause — stop there.

   | Question | Root cause | Fix archetype |
   |----------|-----------|---------------|
   | **Did I miss a signal?** | Wrong assumption — started with a belief that turned out false | What should I have checked? → new/updated **memory** |
   | **Did the process not exist?** | Process gap — no skill/hook/rule covered this | Build it → new **hookify rule**, **skill section**, or **CLAUDE.md rule** |
   | **Did I know the right thing but not do it?** | Ignored process — rule existed, wasn't followed | Why not? → **automate** it (hook/shell), or rethink the rule if it's too annoying |
   | **Did the tools fight me?** | Tooling friction — correct action was hard to do | Fix the tool, add a workaround, or file an issue |

4. **What should change?** — One concrete proposal per problem. If the answer is "nothing — this was a one-off," say so explicitly.

## Persistence

- **If the adapter declares `pm_doc_store.debrief_database_id`:** record the debrief in that destination with columns for Session Topic, Linear/issue ID, Went Well, Went Poorly, Root Causes (multi-select), Changes Made.
- **If no debrief destination is declared:** record the debrief in chat only — present it to the user, let them decide whether to capture it elsewhere.
- **Always** save actionable changes (corrections, new rules, new process steps) as feedback memories with Why and How to apply.
- If a recurring problem is identified across multiple sessions (check memory for patterns), propose a rule or skill update and implement it in the same session if small.

## When to skip

- Pure execution sessions with no decisions (e.g., "update this dependency version, commit, done") can skip debriefing.
- Patch-rigor tasks are optional for debrief.
- Hardened and fortified rigor tasks REQUIRE a debrief. The adapter's `rigor.profiles.hardened.debrief_required: true` enforces this.
```

- [ ] **Step 2: Verify file**

Run: `wc -l skills/ooda/debrief.md`
Expected: ~45-60 lines

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/debrief.md
git commit -m "feat(ooda): add debrief.md four-question framework"
```

---

## Phase D: Phase files (4 tasks, one per phase)

Each phase file is ~60-120 lines. They are the substantive content of the core skill and are loaded on demand during the respective phase.

### Task 11: Write `phases/observe.md`

**Files:**
- Create: `skills/ooda/phases/observe.md`

- [ ] **Step 1: Write the file**

```markdown
# Observe Phase — Session Context Loading

The Observe phase runs at session start, after the adapter discovery protocol has loaded the adapter (or fallen back to default mode). Its job is to load context so you can advise meaningfully rather than guessing.

## Procedure

### 1. Stash hygiene (always)

Run `git stash list`. If stashes exist:

1. For each stash, run `git stash show stash@{N} --stat` to see what files were changed.
2. For each modified file, check whether the changes already landed on the main branch via `git log <main-branch> -- <file>`.
3. Report findings to the user: which stashes are superseded (safe to drop), which contain unmerged work.
4. Offer to drop superseded stashes. For stashes with unmerged work, propose either applying them or creating a tracking item.

Stashes rot quickly — most become unmergeable within a few PRs. Catching them early prevents the archaeology session that happens months later.

### 2. Issue lookup (if `issue_tracker` configured)

If the adapter's `issue_tracker` block is present:

1. Check the current branch name against `issue_tracker.branch_id_regex`. If a match is found, extract the issue ID.
2. If the user invoked `/ooda <issue-id>` explicitly, use that instead of the branch-inferred ID.
3. If `issue_tracker.mcp_server` is declared, use the corresponding MCP tools to fetch the issue. Note its current state (matches one of `issue_tracker.states`).
4. If no issue ID is found and no argument was given: ask the user whether to create a new issue or proceed without tracking.

If the adapter has no `issue_tracker`: skip this step. Announce: "No issue tracker configured — proceeding without issue linking."

### 3. Doc store epic lookup (if `pm_doc_store` configured)

If the adapter's `pm_doc_store` block is present AND an issue was found:

1. Look for a linked epic in the doc store using the adapter's `pm_doc_store.linked_field_name` (typically the issue ID as a property).
2. If found, fetch the epic's content for context.
3. If not found, note it — the user may want to create one before proceeding.

If the adapter has no `pm_doc_store`: skip this step.

### 4. Plan file detection

Check the adapter's `plans.active_path` (default `docs/plans/`) for a plan file matching the current work:

1. Look for filenames containing the issue ID, or for a file whose frontmatter/title references this task.
2. If found, read it — it may inform rigor selection and task sequencing.
3. If not found, note it — we may need to write a plan in the Orient phase (depending on rigor).

### 5. Summary announcement

Present a brief summary to the user:

```
[<issue-id>] <issue title> — <current state>
Epic: <link or "none">
Plan: <link or "none">
Adapter: <loaded | default mode>
Recent stashes: <count, with any flagged ones>
```

This grounds the session without consuming much context. From here, proceed to the Orient phase.

## Graceful degradation

- **No adapter:** skip issue/epic lookup, announce default mode, still run stash hygiene and plan detection.
- **Adapter with no issue_tracker:** skip issue lookup, still run stash + plan detection.
- **Issue tracker declared but MCP server not installed/not authenticated:** announce the failure, offer to proceed without issue linking, and suggest either installing the MCP server or removing the slot from the adapter.
- **Doc store declared but lookup fails:** announce the failure, proceed without the epic context.

## Interaction with adapter body sections

If `## Session Start Checklist` is present in the adapter's Markdown body, run its items after the universal steps above. These are project-specific additions like "check the dashboard for unlinked epics in the current sprint."
```

- [ ] **Step 2: Verify file**

Run: `wc -l skills/ooda/phases/observe.md`
Expected: ~60-80 lines

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/phases/observe.md
git commit -m "feat(ooda): add observe phase — context loading and stash hygiene"
```

### Task 12: Write `phases/orient.md`

**Files:**
- Create: `skills/ooda/phases/orient.md`

- [ ] **Step 1: Write the file**

```markdown
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
```

- [ ] **Step 2: Verify file**

Run: `wc -l skills/ooda/phases/orient.md`
Expected: ~75-100 lines

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/phases/orient.md
git commit -m "feat(ooda): add orient phase — rigor, design, plan gates"
```

### Task 13: Write `phases/decide.md`

**Files:**
- Create: `skills/ooda/phases/decide.md`

- [ ] **Step 1: Write the file**

```markdown
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
```

- [ ] **Step 2: Verify file**

Run: `wc -l skills/ooda/phases/decide.md`
Expected: ~75-100 lines

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/phases/decide.md
git commit -m "feat(ooda): add decide phase — handover contracts and pre-PR gates"
```

### Task 14: Write `phases/act.md`

**Files:**
- Create: `skills/ooda/phases/act.md`

- [ ] **Step 1: Write the file**

```markdown
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
```

- [ ] **Step 2: Verify file**

Run: `wc -l skills/ooda/phases/act.md`
Expected: ~105-135 lines

- [ ] **Step 3: Commit**

```bash
git add skills/ooda/phases/act.md
git commit -m "feat(ooda): add act phase — implement, ship, post-completion"
```

---

## Phase E: Adapter template (1 task with multiple sub-steps)

### Task 15: Write the adapter template

**Files:**
- Create: `skills/ooda/templates/ooda.project.md`

This template is copied into consumer projects by `/ooda-init`. Every frontmatter slot is present but commented; users uncomment and fill what applies. Every body section heading is present but empty.

- [ ] **Step 1: Write the adapter template (full content)**

```markdown
---
# ─── Identity ───────────────────────────────────────────
schema_version: 1
name: "<Human-readable project name>"

# ─── Issue tracker (optional) ───────────────────────────
# Omit this entire block if the project has no issue tracker.
# issue_tracker:
#   type: linear                     # linear | github | jira | none
#   team_or_project: "<team name>"
#   branch_id_regex: '<regex>'       # e.g., '[Cc][Rr][Aa][Ii]-\d+'
#   mcp_server: "<mcp server name>"  # optional — MCP tool prefix for lookups
#   states:                          # workflow states in order
#     - Backlog
#     - In Progress
#     - Done
#   auto_transitions:
#     pr_opened: In Progress
#     pr_merged: Done

# ─── PM doc store (optional) ────────────────────────────
# Omit if the project has no product roadmap / epic doc store.
# pm_doc_store:
#   type: notion                     # notion | confluence | none
#   epic_database_id: "<id>"
#   linked_field_name: "<field name that holds the issue ID>"
#   status_mapping:
#     "In Progress": "In Development"
#   debrief_database_id: "<id>"      # optional — session debrief destination
#   changelog_database_id: "<id>"    # optional — changelog buffer

# ─── Branch & worktree (optional) ───────────────────────
# branch:
#   type_prefixes: [fix, feat, docs, chore, ci, refactor, test]
#   format: "{type}/{issue_id}-{slug}"
#   worktree_policy: required        # required | optional | never
#   worktree_exempt_paths:
#     - .claude/
#     - docs/
#     - CLAUDE.md

# ─── Quality commands (optional) ────────────────────────
# Commands are shell strings. {file} is a placeholder for single-file variants.
# quality:
#   format_lint_typecheck: "<cmd to run formatter + linter + typecheck>"
#   unit_tests: "<cmd to run unit tests>"
#   full_check: "<cmd to run full test suite>"
#   single_file_typecheck: "<cmd with {file}>"
#   single_file_lint: "<cmd with {file}>"
#   single_test_file: "<cmd with {file}>"
#   pre_push: |
#     <multi-line pre-push check sequence>

# ─── Dev deploy (optional) ──────────────────────────────
# dev_deploy:
#   enabled: true
#   trigger_paths:
#     - <glob pattern>
#   deploy_trigger: push             # push | manual | skaffold
#   status_command: "<cmd with {branch}>"
#   validate_command: "<cmd with {branch}>"
#   teardown_command: "<cmd with {branch}>"

# ─── Skill slots ────────────────────────────────────────
# Each slot names the skill that fulfills that obligation.
# Format: <source>:<skill-name> where source is one of:
#   superpowers:*     — upstream superpowers plugin skills
#   ooda:*            — this plugin's skills (e.g., ooda:test-driven-development)
#   <plugin>:*        — any other installed plugin
#   local:*           — project-local skill in .claude/skills/<name>/
#   null              — inline prose fallback (no skill invocation)
skills:
  brainstorm: superpowers:brainstorming
  writing_plans: superpowers:writing-plans
  tdd: ooda:test-driven-development
  systematic_debugging: superpowers:systematic-debugging
  using_git_worktrees: superpowers:using-git-worktrees
  subagent_driven_development: superpowers:subagent-driven-development
  executing_plans: superpowers:executing-plans
  finishing_a_development_branch: superpowers:finishing-a-development-branch
  verification_before_completion: superpowers:verification-before-completion
  requesting_code_review: superpowers:requesting-code-review
  capture_knowledge: null
  review_pr: null

# ─── Rigor profiles ─────────────────────────────────────
rigor:
  default: standard
  profiles:
    patch:
      design_required: false
      plan_required: false
      mutation_threshold: null
      dev_deploy_required: false
      debrief_required: false
    standard:
      design_required: false
      plan_required: optional
      mutation_threshold: null
      dev_deploy_required: if_trigger_paths_changed
      debrief_required: optional
    hardened:
      design_required: true
      plan_required: true
      mutation_threshold: 0.80
      dev_deploy_required: true
      debrief_required: true
    fortified:
      design_required: true
      plan_required: true
      mutation_threshold: 0.90
      dev_deploy_required: true
      dev_deploy_verification_drill: true
      debrief_required: true
      equivalent_mutant_registry_required: true

# ─── Knowledge & plans ──────────────────────────────────
knowledge:
  destination_path: "docs/knowledge/"
  cascade_check_paths:
    - "docs/guides/"
    - "docs/runbooks/"

plans:
  active_path: "docs/plans/"
  completed_path: "docs/plans/completed/"

# ─── Auto-merge (optional) ──────────────────────────────
# auto_merge:
#   tool: mergify                    # mergify | github-auto-merge | none
#   default_draft: true

# ─── Validation registry (optional) ─────────────────────
# validation_registry:
#   path: ".claude/validation-registry.yaml"

# ─── Plugin version pin (optional) ──────────────────────
# plugin:
#   pinned_version: "0.1.0"          # warn if installed plugin doesn't match
---

## Project Overview

<!-- 1-3 paragraphs describing the project: what it does, tech stack, domains, tenants, notable constraints. This section is read by Claude at session start to ground its understanding of the project. -->

## Notable Risks and Outage History

<!-- Things that have caused outages before, or would if they failed. Used to inform rigor judgment on ambiguous cases. Be specific — name the incident, the component, and what broke. -->

## Custom Workflows

<!-- Project-specific workflows that don't fit a flat frontmatter slot. Examples: epic property schemas, changelog buffer column schemas, dev validation via MCP tools, knowledge DB rebuild steps, pre-commit hook behaviors. -->

## Phase Overrides

<!-- Where this project deviates from the default rigor profile rules, gate behavior, or skill chain. Use when a frontmatter slot isn't expressive enough. -->

## Release Process

<!-- How releases are cut for this project: compile unreleased changelog entries, group by category, draft announcement, user approval, post to channel, mark entries as released. If no formal release process, omit this heading. -->

## Session Start Checklist

<!-- Project-specific items to run at session start, beyond universal stash hygiene. Examples: "check the dashboard for unlinked epics in the current sprint," "verify dev deploy namespace is clean." -->

## Pre-PR Gate Additions

<!-- Project-specific gates to add to the Decide phase's pre-PR gate list, beyond the universal gates 1-9. Examples: tenant-specific validation, audio/UX testing, compliance review. -->

## Tenant / Environment Inventory

<!-- For multi-tenant or multi-environment projects: list tenants/environments and their notable characteristics. -->
```

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "import yaml; content = open('skills/ooda/templates/ooda.project.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Verify all body headings present**

Run: `grep -c '^## ' skills/ooda/templates/ooda.project.md`
Expected: `8`

- [ ] **Step 4: Commit**

```bash
git add skills/ooda/templates/ooda.project.md
git commit -m "feat(ooda): add adapter template with full schema and body sections"
```

---

## Phase F: Forked TDD skill (3 tasks)

### Task 16: Copy upstream TDD skill as base

**Files:**
- Create: `skills/test-driven-development/SKILL.md`
- Create: `skills/test-driven-development/.last-upstream-sync`

- [ ] **Step 1: Fetch the upstream TDD skill from superpowers v5.0.7**

```bash
curl -sSL "https://raw.githubusercontent.com/obra/superpowers/v5.0.7/skills/test-driven-development/SKILL.md" > skills/test-driven-development/SKILL.md.upstream
```

- [ ] **Step 2: Verify fetch succeeded**

Run: `wc -l skills/test-driven-development/SKILL.md.upstream`
Expected: ~370 lines (the upstream SKILL.md at v5.0.7)

If the line count is drastically different or the file is empty, the URL or tag may have changed — fall back to reading from the local superpowers plugin cache at `~/.claude/plugins/cache/superpowers-marketplace/superpowers/5.0.7/skills/test-driven-development/SKILL.md`.

- [ ] **Step 3: Copy upstream as the starting point for our fork**

```bash
cp skills/test-driven-development/SKILL.md.upstream skills/test-driven-development/SKILL.md
rm skills/test-driven-development/SKILL.md.upstream
```

- [ ] **Step 4: Record the upstream SHA for future sync tracking**

```bash
# Fetch the commit SHA of v5.0.7 on the upstream repo
UPSTREAM_SHA=$(curl -sSL "https://api.github.com/repos/obra/superpowers/commits/v5.0.7" | python3 -c "import json, sys; print(json.load(sys.stdin)['sha'])")
echo "$UPSTREAM_SHA" > skills/test-driven-development/.last-upstream-sync
cat skills/test-driven-development/.last-upstream-sync
```

Expected: a 40-character SHA on stdout.

- [ ] **Step 5: Commit**

```bash
git add skills/test-driven-development/SKILL.md skills/test-driven-development/.last-upstream-sync
git commit -m "feat(tdd): import superpowers v5.0.7 test-driven-development skill as fork base"
```

### Task 17: Modify SKILL.md to add MUTATE and KILL phases

**Files:**
- Modify: `skills/test-driven-development/SKILL.md`

This task extends the TDD loop by inserting MUTATE and KILL between GREEN and REFACTOR. The insertion should be clearly marked as "extended" to ease upstream diffing.

- [ ] **Step 1: Update the skill frontmatter to note the fork**

Find the existing frontmatter (first lines of the file). It likely looks like:
```yaml
---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---
```

Replace it with:
```yaml
---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code. This is a fork of superpowers/test-driven-development with MUTATE and KILL phases inserted between GREEN and REFACTOR, gated by per-rigor-profile mutation kill-rate thresholds.
---
```

Use the Edit tool with exact matching to replace the frontmatter block.

- [ ] **Step 2: Locate the REFACTOR section and insert MUTATE before it**

The upstream skill has a section like `### REFACTOR - Clean Up` (or similar heading). Before that section, insert the following new section:

```markdown

### MUTATE - Seed Mutations (hardened/fortified rigor only)

**When to run:** Only at `hardened` or `fortified` rigor levels. Skip entirely for `patch` and `standard`. Read `rigor.profiles.<level>.mutation_threshold` from the project adapter — if null, skip this phase.

Mutation testing verifies that your tests actually *catch* bugs rather than merely exercising the code. A test that passes when the code is broken is a bad test.

After GREEN (all tests passing), run your project's mutation tester over the modules you modified. Typical tools by language:
- Python: `mutmut`, `cosmic-ray`
- JavaScript/TypeScript: `Stryker Mutator`
- Ruby: `mutant`
- Go: `go-mutesting`

Mutation tools introduce small changes (mutations) to your code — flipping operators, changing constants, removing statements — and check whether your test suite catches them (tests fail = mutant killed) or lets them slip by (tests pass = mutant survived).

**Your target kill rate** is the `mutation_threshold` from the adapter (typically 0.80 for hardened, 0.90 for fortified).

### KILL - Hunt Surviving Mutants

**When to run:** Immediately after MUTATE, at the same rigor levels.

For each surviving mutant, one of two things is true:

1. **Your test suite has a gap.** Add a test that catches the mutant. This is the common case.
2. **The mutant is equivalent.** Some code changes don't change observable behavior (e.g., `i++` vs `i = i + 1` in a loop counter that's never compared). These are "equivalent mutants" and cannot be killed by any test. Document them.

**For genuine gaps:** write a new failing test (RED), then watch it catch the mutant (GREEN for the new test, dead mutant for the old one). This is TDD for your test suite — the mutant is the failing "requirement."

**For equivalent mutants:** at fortified rigor, the adapter may require an equivalent mutant registry (`rigor.profiles.fortified.equivalent_mutant_registry_required: true`). If so, record the surviving mutant in the registry (typical locations: `docs/mutation/equivalent-mutants.md`, or a project-specific path) with the mutant diff, the reason it's equivalent, and a justification.

Re-run mutation testing after killing the reachable mutants. Continue until your kill rate meets the threshold, either by adding tests or by justifying equivalent mutants.

**Escape valve:** if you hit 80-90% of the threshold but the remaining mutants are genuinely hard to kill (deeply coupled to environment, timing, or external state), present the situation to the user and ask whether to (a) accept the lower kill rate with justification, (b) refactor the code to be more testable, or (c) defer the remaining work. Never silently accept a lower kill rate than the adapter's threshold.

```

Use the Edit tool with a precise `old_string` that matches the text just before the existing REFACTOR heading (so the insertion point is unambiguous).

- [ ] **Step 3: Verify frontmatter still parses**

Run: `python3 -c "import yaml; content = open('skills/test-driven-development/SKILL.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 4: Verify new sections are present**

Run: `grep -c '^### MUTATE\|^### KILL' skills/test-driven-development/SKILL.md`
Expected: `2`

- [ ] **Step 5: Commit**

```bash
git add skills/test-driven-development/SKILL.md
git commit -m "feat(tdd): add MUTATE and KILL phases between GREEN and REFACTOR"
```

### Task 18: Write NOTICE.md attribution and sync instructions

**Files:**
- Create: `skills/test-driven-development/NOTICE.md`

- [ ] **Step 1: Write NOTICE.md**

```markdown
# NOTICE — test-driven-development (fork)

## Origin

This skill is a fork of `test-driven-development` from [superpowers](https://github.com/obra/superpowers) by Jesse Vincent (Prime Radiant).

- **Upstream:** https://github.com/obra/superpowers
- **Upstream path:** `skills/test-driven-development/SKILL.md`
- **Original author:** Jesse Vincent <jesse@fsck.com>
- **Original license:** MIT — see below
- **Base version:** superpowers v5.0.7 (SHA recorded in `.last-upstream-sync`)

## Changes from upstream

This fork inserts two new phases between GREEN and REFACTOR:
- **MUTATE** — seed mutations in the modified code
- **KILL** — hunt and kill surviving mutants, or document equivalents

These phases run only at `hardened` or `fortified` rigor levels, gated by the `rigor.profiles.<level>.mutation_threshold` value from the consumer project's `/ooda` adapter. At `patch` and `standard` rigor, the skill behaves identically to the upstream (RED → GREEN → REFACTOR).

## Upstream sync

To check for upstream changes and cherry-pick improvements:

```bash
bash scripts/diff-upstream-tdd.sh
```

The script (at the plugin repo root) fetches the current upstream `test-driven-development/SKILL.md`, diffs it against our fork, and shows three outputs:
1. What changed upstream since the last recorded sync (see `.last-upstream-sync`)
2. What's different between upstream and our fork (our additions — mostly MUTATE/KILL)
3. A suggested cherry-pick list of upstream changes not yet applied

Run this script passively when you notice a new superpowers release, and actively every 4-6 weeks as a cadence discipline. Most checks are fast (no upstream changes to the TDD skill) and most sync sessions take under 30 minutes.

After syncing, update `.last-upstream-sync` to the new upstream commit SHA.

## Upstream MIT License

```
MIT License

Copyright (c) 2025 Jesse Vincent

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

The ooda plugin's own license (`LICENSE` at the repo root) also applies to this forked file and the MUTATE/KILL additions.
```

- [ ] **Step 2: Verify file**

Run: `wc -l skills/test-driven-development/NOTICE.md && grep -c 'MIT License' skills/test-driven-development/NOTICE.md`
Expected: ~60 lines, grep result `1`

- [ ] **Step 3: Commit**

```bash
git add skills/test-driven-development/NOTICE.md
git commit -m "docs(tdd): add NOTICE with upstream attribution and sync instructions"
```

---

## Phase G: Diff helper script (1 task)

### Task 19: Write `scripts/diff-upstream-tdd.sh`

**Files:**
- Create: `scripts/diff-upstream-tdd.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
# diff-upstream-tdd.sh — compare forked test-driven-development skill against upstream superpowers
#
# Shows three diffs:
#   1. What changed upstream since our last recorded sync (via .last-upstream-sync)
#   2. Our fork vs current upstream (our additions — should be roughly the MUTATE/KILL content)
#   3. Suggested cherry-pick candidates (lines in upstream that changed since last sync)
#
# Run manually when a new superpowers release is noticed, or every 4-6 weeks as cadence discipline.

set -euo pipefail

UPSTREAM_REPO="obra/superpowers"
UPSTREAM_PATH="skills/test-driven-development/SKILL.md"
LOCAL="skills/test-driven-development/SKILL.md"
LAST_SYNC_REF_FILE="skills/test-driven-development/.last-upstream-sync"

if [[ ! -f "$LOCAL" ]]; then
  echo "ERROR: $LOCAL does not exist. Run from the plugin repo root." >&2
  exit 1
fi

TMP_CURRENT_UPSTREAM=$(mktemp)
trap 'rm -f "$TMP_CURRENT_UPSTREAM" "$TMP_PREV_UPSTREAM"' EXIT
TMP_PREV_UPSTREAM=$(mktemp)

echo "Fetching current upstream $UPSTREAM_PATH from $UPSTREAM_REPO (main branch)..."
curl -sSL "https://raw.githubusercontent.com/$UPSTREAM_REPO/main/$UPSTREAM_PATH" > "$TMP_CURRENT_UPSTREAM"

if [[ ! -s "$TMP_CURRENT_UPSTREAM" ]]; then
  echo "ERROR: Failed to fetch upstream file (empty response). Check network and repo URL." >&2
  exit 1
fi

echo
echo "=========================================="
echo "1. What changed upstream since last sync"
echo "=========================================="
if [[ -f "$LAST_SYNC_REF_FILE" ]]; then
  LAST_SYNC_SHA=$(cat "$LAST_SYNC_REF_FILE")
  echo "Last recorded sync: $LAST_SYNC_SHA"
  curl -sSL "https://raw.githubusercontent.com/$UPSTREAM_REPO/$LAST_SYNC_SHA/$UPSTREAM_PATH" > "$TMP_PREV_UPSTREAM" 2>/dev/null || true
  if [[ -s "$TMP_PREV_UPSTREAM" ]]; then
    if diff -q "$TMP_PREV_UPSTREAM" "$TMP_CURRENT_UPSTREAM" >/dev/null 2>&1; then
      echo "No changes upstream since last sync."
    else
      diff -u "$TMP_PREV_UPSTREAM" "$TMP_CURRENT_UPSTREAM" || true
    fi
  else
    echo "Could not fetch upstream file at last sync SHA. Upstream history may have changed."
  fi
else
  echo "No previous sync ref recorded (missing $LAST_SYNC_REF_FILE)."
fi

echo
echo "=========================================="
echo "2. Our fork vs current upstream (our additions)"
echo "=========================================="
if diff -q "$TMP_CURRENT_UPSTREAM" "$LOCAL" >/dev/null 2>&1; then
  echo "Fork is identical to upstream. No custom additions."
else
  diff -u "$TMP_CURRENT_UPSTREAM" "$LOCAL" || true
fi

echo
echo "=========================================="
echo "Next steps"
echo "=========================================="
echo "- If section 1 shows useful upstream changes, cherry-pick them into $LOCAL."
echo "- After syncing, record the new upstream SHA:"
echo "    NEW_SHA=\$(curl -sSL 'https://api.github.com/repos/$UPSTREAM_REPO/commits/main' | python3 -c 'import json,sys; print(json.load(sys.stdin)[\"sha\"])')"
echo "    echo \$NEW_SHA > $LAST_SYNC_REF_FILE"
echo "    git add $LAST_SYNC_REF_FILE $LOCAL"
echo "    git commit -m 'chore(tdd): sync with upstream superpowers (new SHA)'"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x scripts/diff-upstream-tdd.sh
```

- [ ] **Step 3: Run it in no-op verification mode**

Run: `bash scripts/diff-upstream-tdd.sh > /tmp/diff-upstream-test.log 2>&1 && head -30 /tmp/diff-upstream-test.log`
Expected: Script runs without error, produces 3 sections of output, may show "No changes upstream since last sync" if the upstream hasn't changed since v5.0.7, or a diff if it has. The exit code is 0.

If the script errors out, read the error message and fix the script. Common issues: curl not available (install it), GitHub API rate limit (wait or authenticate).

- [ ] **Step 4: Commit**

```bash
git add scripts/diff-upstream-tdd.sh
git commit -m "feat(scripts): add diff-upstream-tdd.sh for TDD fork sync"
```

---

## Phase H: Commands (3 tasks)

### Task 20: Write `/ooda` slash command

**Files:**
- Create: `commands/ooda.md`

In Claude Code plugins, commands are short markdown files that the plugin system registers as slash commands. The command file contains the prompt Claude executes when the user runs the slash command.

- [ ] **Step 1: Write the file**

```markdown
---
name: ooda
description: Start an engineering lifecycle session — load context, select rigor, route to phase files, and orchestrate the full development cycle (session start, design, plan, implement, review, ship, debrief). Works on any project with or without an `.claude/ooda.project.md` adapter.
argument-hint: "[issue-id]"
---

You are being invoked via the `/ooda` slash command. The user may have provided an optional issue ID as an argument.

Load the `ooda` skill by invoking it via the Skill tool: `Skill(skill="ooda")`.

If you were given an argument (e.g., `/ooda CRAI-218`), pass it as the issue ID context. The skill's adapter discovery protocol will handle the lookup against whatever issue tracker the project has configured (or skip it if the project has none).

Begin with the Observe phase as directed by the skill's router. The skill will walk you through the full lifecycle based on the project's adapter file (if present) or default mode (if not).
```

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "import yaml; content = open('commands/ooda.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add commands/ooda.md
git commit -m "feat(commands): add /ooda slash command"
```

### Task 21: Write `/ooda-init` slash command

**Files:**
- Create: `commands/ooda-init.md`

- [ ] **Step 1: Write the file**

```markdown
---
name: ooda-init
description: Drop the `/ooda` adapter template into the current project at `.claude/ooda.project.md`. Refuses to overwrite an existing adapter without `--force`. Run this once per project to bootstrap the adapter file, then fill in the slots that apply to the project.
argument-hint: "[--force]"
---

You are being invoked via the `/ooda-init` slash command. Your job is to copy the plugin's adapter template into the user's current project at `.claude/ooda.project.md`.

Procedure:

1. **Locate the template.** The template lives inside this plugin at `skills/ooda/templates/ooda.project.md`. You can find the plugin's install path by checking the environment variable `CLAUDE_PLUGIN_ROOT` if set, or by searching `~/.claude/plugins/` for the `ooda` plugin.

2. **Determine the target path.** The target is `.claude/ooda.project.md` in the current working directory. If the `.claude/` directory doesn't exist, offer to create it.

3. **Check for existing adapter.** If `.claude/ooda.project.md` already exists in the current project:
   - If the user supplied `--force`, announce that you're overwriting and proceed.
   - If the user did NOT supply `--force`, stop and announce: "An adapter already exists at `.claude/ooda.project.md`. Use `/ooda-init --force` to overwrite, or edit the existing file directly."
   - Never silently overwrite.

4. **Copy the template.** Read the template file and write its contents to `.claude/ooda.project.md` in the current project. Do not modify the content during the copy — the template is designed to be edited manually.

5. **Announce success and next steps.**
   - "Adapter template written to `.claude/ooda.project.md`."
   - "Edit the file to fill in the slots that apply to your project. Every slot is optional — leave slots commented out if they don't apply."
   - "Run `/ooda-validate` to check your adapter, then `/ooda` to start a session."

6. **Do not run `/ooda` automatically.** The user may want to fill out the adapter before starting a session.

If the template file cannot be found (plugin not installed correctly, or path mismatch), announce the error clearly and suggest reinstalling the plugin.
```

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "import yaml; content = open('commands/ooda-init.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add commands/ooda-init.md
git commit -m "feat(commands): add /ooda-init slash command"
```

### Task 22: Write `/ooda-validate` slash command

**Files:**
- Create: `commands/ooda-validate.md`

- [ ] **Step 1: Write the file**

```markdown
---
name: ooda-validate
description: Validate the `.claude/ooda.project.md` adapter file in the current project. Checks schema version, required identity fields, slot types, skill slot resolvability, referenced file paths, and rigor profile completeness. Reports findings as Critical, Warning, Info.
---

You are being invoked via the `/ooda-validate` slash command. Your job is to validate the current project's `/ooda` adapter file.

Procedure:

1. **Locate the adapter.** Search for the adapter file in order:
   - `.claude/ooda.project.md`
   - `.claude/skills/ooda/project.md`
   - `ooda.project.md` (repo root)
   Use the first match.

2. **If no adapter found:** announce: "No `/ooda` adapter found in this project. Run `/ooda-init` to create one." Stop.

3. **Parse frontmatter.** Read the file and extract the YAML frontmatter block. If the YAML does not parse:
   - Report CRITICAL: "Adapter frontmatter is not valid YAML: [error message]."
   - Show the specific line and column if the error provides it.
   - Stop.

4. **Check required fields:**
   - `schema_version` must be present and an integer. If missing: CRITICAL. If present but not an integer: CRITICAL. If the integer is greater than the plugin's supported schema version (currently `1`): CRITICAL with message "Adapter schema v<N> is newer than this plugin supports. Update the plugin or downgrade the adapter."
   - `name` must be present and a non-empty string. If missing: CRITICAL. If empty: WARNING.

5. **Check each declared block for type correctness.** For each optional block that is present (`issue_tracker`, `pm_doc_store`, `branch`, `quality`, `dev_deploy`, `skills`, `rigor`, `knowledge`, `plans`, `auto_merge`, `validation_registry`, `plugin`):
   - Verify the block is a mapping (object), not a string or list.
   - For each declared subfield, verify its type matches the schema (strings are strings, lists are lists, booleans are booleans, integers are integers).
   - Flag type mismatches as CRITICAL.

6. **Check skill slot values.** For each entry in `skills.*`:
   - If the value is `null` or the entry is absent, that's fine (inline prose fallback).
   - If the value is a string, it should match the pattern `<source>:<skill-name>` where source is one of `superpowers`, `ooda`, `local`, or a plugin name.
   - If the source is `local:*`, check whether `.claude/skills/<skill-name>/SKILL.md` exists in the current project. If missing: WARNING.
   - If the source is `superpowers:*` or another plugin, we can't verify install without querying Claude Code's plugin state — emit INFO recommending the user install the plugin if not already.

7. **Check referenced file paths.** For:
   - `validation_registry.path` — if set, verify the file exists. If missing: WARNING.
   - `plans.active_path`, `plans.completed_path` — if set, verify the directories exist. If missing: INFO recommending creation.
   - `knowledge.destination_path` — if set, verify the directory exists. If missing: INFO.

8. **Check rigor profile completeness.** If the `rigor` block is present:
   - Verify `rigor.default` is set to one of: `patch`, `standard`, `hardened`, `fortified`.
   - Verify `rigor.profiles` contains at least the four standard profile names. Missing profiles: WARNING (will fall back to core defaults).
   - For each profile, verify `mutation_threshold` is either `null` or a number between 0 and 1. Values outside this range: CRITICAL.

9. **Check body section headings.** Parse the Markdown body below the frontmatter. Report INFO for any recognized heading that's present (`## Project Overview`, `## Notable Risks and Outage History`, etc.) — this gives the user a summary of what's configured.

10. **Report results.** Present findings grouped by severity:
    - **CRITICAL** (red): blocks session start. Must be fixed.
    - **WARNING** (yellow): session proceeds but degraded behavior expected.
    - **INFO** (blue): informational, no action required.
    Show the count of each severity and a summary: "Adapter is valid / has X warnings / has Y critical issues."

If everything is clean, announce: "✓ Adapter validation passed. Ready to run `/ooda`."
```

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "import yaml; content = open('commands/ooda-validate.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add commands/ooda-validate.md
git commit -m "feat(commands): add /ooda-validate slash command"
```

---

## Phase I: Test fixtures (2 tasks)

### Task 23: Write `tests/fixtures/example-adapter.md` — full-coverage fixture

**Files:**
- Create: `tests/fixtures/example-adapter.md`

This fixture exercises every frontmatter slot and every body section. It serves as:
1. A reference example for plugin users
2. A CI smoke test that `/ooda-validate` accepts a correctly-populated adapter
3. A verification target for future schema changes

- [ ] **Step 1: Write the fixture**

```markdown
---
schema_version: 1
name: "Example Project — Full Coverage Fixture"

issue_tracker:
  type: linear
  team_or_project: ExampleTeam
  branch_id_regex: '[Ee][Xx]-\d+'
  mcp_server: mcp__example_linear
  states:
    - Backlog
    - Ready
    - In Progress
    - Awaiting Review
    - Done
  auto_transitions:
    pr_opened: Awaiting Review
    pr_merged: Done

pm_doc_store:
  type: notion
  epic_database_id: "00000000-0000-0000-0000-000000000000"
  linked_field_name: "Linear ID"
  status_mapping:
    "Ready": "Planned"
    "In Progress": "In Development"
    "Awaiting Review": "In Review"
    "Done": "Done"
  debrief_database_id: "00000000-0000-0000-0000-000000000001"
  changelog_database_id: "00000000-0000-0000-0000-000000000002"

branch:
  type_prefixes: [fix, feat, feature, docs, chore, ci, refactor, test]
  format: "{type}/{issue_id}-{slug}"
  worktree_policy: required
  worktree_exempt_paths:
    - .claude/
    - docs/
    - CLAUDE.md
    - justfile
    - .gitignore
    - .env*
    - pyproject.toml
    - uv.lock

quality:
  format_lint_typecheck: "just check"
  unit_tests: "just test-unit"
  full_check: "just test"
  single_file_typecheck: "uv run mypy {file} --show-error-codes"
  single_file_lint: "uv run ruff check {file}"
  single_test_file: "uv run pytest {file} -v"
  pre_push: |
    just check
    uv run ruff check packages/ --output-format=github
    uv run ruff format --check .

dev_deploy:
  enabled: true
  trigger_paths:
    - packages/runtime/**
    - config/**
  deploy_trigger: push
  status_command: "just dev-status {branch}"
  validate_command: "just dev-phone {branch}"
  teardown_command: "just dev-teardown {branch}"

skills:
  brainstorm: superpowers:brainstorming
  writing_plans: superpowers:writing-plans
  tdd: ooda:test-driven-development
  systematic_debugging: superpowers:systematic-debugging
  using_git_worktrees: superpowers:using-git-worktrees
  subagent_driven_development: superpowers:subagent-driven-development
  executing_plans: superpowers:executing-plans
  finishing_a_development_branch: superpowers:finishing-a-development-branch
  verification_before_completion: superpowers:verification-before-completion
  requesting_code_review: superpowers:requesting-code-review
  capture_knowledge: local:capture-knowledge
  review_pr: pr-review-toolkit:review-pr

rigor:
  default: standard
  profiles:
    patch:
      design_required: false
      plan_required: false
      mutation_threshold: null
      dev_deploy_required: false
      debrief_required: false
    standard:
      design_required: false
      plan_required: optional
      mutation_threshold: null
      dev_deploy_required: if_trigger_paths_changed
      debrief_required: optional
    hardened:
      design_required: true
      plan_required: true
      mutation_threshold: 0.80
      dev_deploy_required: true
      debrief_required: true
    fortified:
      design_required: true
      plan_required: true
      mutation_threshold: 0.90
      dev_deploy_required: true
      dev_deploy_verification_drill: true
      debrief_required: true
      equivalent_mutant_registry_required: true

knowledge:
  destination_path: "docs/knowledge/"
  cascade_check_paths:
    - "docs/guides/"
    - "docs/runbooks/"

plans:
  active_path: "docs/plans/"
  completed_path: "docs/plans/completed/"

auto_merge:
  tool: mergify
  default_draft: true

validation_registry:
  path: ".claude/validation-registry.yaml"

plugin:
  pinned_version: null
---

## Project Overview

Example Project is a fictional multi-service application used as a full-coverage adapter fixture. It demonstrates every slot in the `ooda` adapter schema at schema_version 1. It is not a real project.

Tech stack: fictional Python + TypeScript monorepo with a CLI, web frontend, and background worker.

## Notable Risks and Outage History

- Billing changes have caused outages three times (CHARGEBACK-17, CHARGEBACK-22, CHARGEBACK-41). Any change touching `packages/billing/` requires fortified rigor.
- The authentication middleware was rewritten under CHARGEBACK-55 after a session-fixation CVE. Changes to auth require hardened rigor minimum.

## Custom Workflows

### Knowledge DB rebuild

Before running integration tests that depend on the knowledge index, rebuild with `just setup-db-all`. Without this, `TestKnowledgeIntegration` fails with cryptic "table not found" errors.

### Epic property schema (Notion "Example Roadmap" database)

When creating epics via MCP, set these properties:
- `Type`: `Epic` | `Story` | `Task`
- `Status`: matches `issue_tracker.states`
- `Priority`: `P1` | `P2` | `P3` | `P4`
- `Linear ID`: the issue ID (e.g., `EX-42`)

## Phase Overrides

- **Plan archival before push:** Check `docs/plans/` for a related plan and move it to `docs/plans/completed/` with an Outcomes section BEFORE the final push, not after. This prevents Mergify from auto-merging before the archival lands.
- **Draft PR rule:** All PRs must be created as draft (`gh pr create --draft`) and manually marked ready with `gh pr ready` only after CI passes and all post-implementation work is committed.

## Release Process

At release time, compile unreleased entries from the Notion changelog buffer, group by Features / Fixes / Infrastructure, draft a Slack post in `#releases`, present to the user for approval, post on approval, then update each included entry with the release tag.

## Session Start Checklist

Check the Notion "Example Roadmap" board for epics where `Priority = P1` and `Linear ID` is empty. Offer to create Linear issues for any unlinked P1 epics.

## Pre-PR Gate Additions

- **Accessibility audit** for any frontend changes (`packages/web/**`).
- **Billing ledger replay** for any changes to `packages/billing/**` (run `just replay-ledger`).

## Tenant / Environment Inventory

- `tenant-a` — US East, primary production tenant, 80% of traffic
- `tenant-b` — EU West, compliance-gated, fortified rigor for any billing changes
- `dev` — per-branch dev deploy environment
- `staging` — pre-production validation environment
```

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "import yaml; content = open('tests/fixtures/example-adapter.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Verify all body headings are present**

Run: `grep -c '^## ' tests/fixtures/example-adapter.md`
Expected: `8`

- [ ] **Step 4: Commit**

```bash
git add tests/fixtures/example-adapter.md
git commit -m "test(fixtures): add example-adapter full-coverage fixture"
```

### Task 24: Write `tests/fixtures/minimal-adapter.md` and `tests/fixtures/invalid-adapter.md`

**Files:**
- Create: `tests/fixtures/minimal-adapter.md`
- Create: `tests/fixtures/invalid-adapter.md`

- [ ] **Step 1: Write the minimal adapter**

```markdown
---
schema_version: 1
name: "Minimal Example"
---

## Project Overview

A minimal adapter with only the required fields. Every optional slot is absent, triggering graceful degradation across the board.
```

- [ ] **Step 2: Verify minimal adapter frontmatter parses**

Run: `python3 -c "import yaml; content = open('tests/fixtures/minimal-adapter.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Write the invalid adapter**

```markdown
---
# schema_version deliberately missing — should trigger CRITICAL
name: "Invalid Example"

issue_tracker:
  type: linear
  branch_id_regex: 12345   # deliberately a number instead of a string — should trigger CRITICAL

rigor:
  default: invalid-profile-name   # deliberately invalid — should trigger CRITICAL
  profiles:
    hardened:
      mutation_threshold: 1.5   # deliberately > 1 — should trigger CRITICAL

skills:
  tdd: "not-a-valid-prefix-format"   # deliberately missing source: prefix — should trigger WARNING or CRITICAL

validation_registry:
  path: ".claude/nonexistent-registry.yaml"   # deliberately nonexistent — should trigger WARNING
---

## Project Overview

An adapter with deliberate errors used to test the `/ooda-validate` command. Each error is marked with a comment explaining what should be flagged.
```

- [ ] **Step 4: Verify invalid adapter frontmatter is still parseable YAML** (the errors are semantic, not syntactic)

Run: `python3 -c "import yaml; content = open('tests/fixtures/invalid-adapter.md').read(); parts = content.split('---\n', 2); yaml.safe_load(parts[1]); print('OK')"`
Expected: `OK`

The fixture's frontmatter MUST be valid YAML syntactically (so the parser can load it) but contains semantic errors that `/ooda-validate` should catch. If the YAML is itself unparseable, the fixture is malformed and needs to be fixed.

- [ ] **Step 5: Commit**

```bash
git add tests/fixtures/minimal-adapter.md tests/fixtures/invalid-adapter.md
git commit -m "test(fixtures): add minimal and invalid adapter fixtures"
```

---

## Phase J: CI workflow (1 task)

### Task 25: Write GitHub Actions CI workflow

**Files:**
- Create: `.github/workflows/lint.yml`

- [ ] **Step 1: Write the workflow**

```yaml
name: Lint and Verify

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  markdown-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install markdownlint-cli
        run: npm install -g markdownlint-cli
      - name: Run markdownlint
        run: |
          markdownlint '**/*.md' \
            --ignore node_modules \
            --ignore docs/design/ \
            || true  # non-blocking for now; tighten later

  frontmatter-yaml-parse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install PyYAML
        run: pip install pyyaml
      - name: Verify every .md file with YAML frontmatter parses
        run: |
          set -e
          FAILED=0
          for f in $(find . -type f -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*"); do
            # Only check files that start with YAML frontmatter
            if head -1 "$f" | grep -q "^---$"; then
              python3 -c "
          import sys, yaml
          content = open('$f').read()
          parts = content.split('---\n', 2)
          if len(parts) < 3:
              print('SKIP: $f — no frontmatter')
              sys.exit(0)
          try:
              yaml.safe_load(parts[1])
              print('OK: $f')
          except yaml.YAMLError as e:
              print('FAIL: $f — {}'.format(e))
              sys.exit(1)
              " || FAILED=1
            fi
          done
          exit $FAILED

  attribution-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify TDD fork attribution
        run: |
          set -e
          test -f skills/test-driven-development/NOTICE.md
          grep -q "Jesse Vincent" skills/test-driven-development/NOTICE.md
          grep -q "MIT License" skills/test-driven-development/NOTICE.md
          grep -q "superpowers" skills/test-driven-development/NOTICE.md
          echo "TDD fork attribution OK"

  diff-script-smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run diff-upstream-tdd.sh in no-op mode
        run: |
          bash scripts/diff-upstream-tdd.sh > /tmp/diff-test.log 2>&1 || {
            echo "Script failed. Output:"
            cat /tmp/diff-test.log
            exit 1
          }
          echo "Script ran successfully"
          head -30 /tmp/diff-test.log
```

- [ ] **Step 2: Verify YAML is valid**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/lint.yml')); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/lint.yml
git commit -m "ci: add lint workflow (markdown, YAML frontmatter, attribution, diff script)"
```

---

## Phase K: Final verification and version tag (2 tasks)

### Task 26: Full-repo verification sweep

No file changes — this task runs a verification pass across everything built in phases A-J.

- [ ] **Step 1: Verify all expected files exist**

Run:
```bash
set -e
for f in \
  .claude-plugin/plugin.json \
  CLAUDE.md \
  skills/ooda/SKILL.md \
  skills/ooda/rigor-profiles.md \
  skills/ooda/handover-contracts.md \
  skills/ooda/debrief.md \
  skills/ooda/phases/observe.md \
  skills/ooda/phases/orient.md \
  skills/ooda/phases/decide.md \
  skills/ooda/phases/act.md \
  skills/ooda/templates/ooda.project.md \
  skills/test-driven-development/SKILL.md \
  skills/test-driven-development/NOTICE.md \
  skills/test-driven-development/.last-upstream-sync \
  scripts/diff-upstream-tdd.sh \
  commands/ooda.md \
  commands/ooda-init.md \
  commands/ooda-validate.md \
  tests/fixtures/example-adapter.md \
  tests/fixtures/minimal-adapter.md \
  tests/fixtures/invalid-adapter.md \
  .github/workflows/lint.yml; do
  test -f "$f" && echo "OK: $f" || { echo "MISSING: $f"; exit 1; }
done
```

Expected: every line starts with `OK:` and the script exits 0.

- [ ] **Step 2: Verify every file with YAML frontmatter parses**

Run:
```bash
for f in \
  skills/ooda/SKILL.md \
  skills/ooda/templates/ooda.project.md \
  skills/test-driven-development/SKILL.md \
  commands/ooda.md \
  commands/ooda-init.md \
  commands/ooda-validate.md \
  tests/fixtures/example-adapter.md \
  tests/fixtures/minimal-adapter.md \
  tests/fixtures/invalid-adapter.md; do
  python3 -c "
import yaml
content = open('$f').read()
parts = content.split('---\n', 2)
yaml.safe_load(parts[1])
print('OK: $f')
  " || { echo "FAIL: $f"; exit 1; }
done
```

Expected: every line starts with `OK:`.

- [ ] **Step 3: Verify the diff script runs without error**

Run: `bash scripts/diff-upstream-tdd.sh > /tmp/diff-final-test.log 2>&1 && echo "Script OK" || { cat /tmp/diff-final-test.log; exit 1; }`
Expected: `Script OK`

- [ ] **Step 4: Verify plugin.json is still valid JSON and version is 0.0.1**

Run: `python3 -c "import json; m = json.load(open('.claude-plugin/plugin.json')); assert m['version'] == '0.0.1'; print('OK')"`
Expected: `OK`

- [ ] **Step 5: Verify example-adapter has all body sections**

Run: `grep -c '^## ' tests/fixtures/example-adapter.md`
Expected: `8`

- [ ] **Step 6: Announce verification complete**

The verification pass is complete. No commit in this task — it's a read-only verification.

### Task 27: Tag v0.0.1-pre and push

This tags the current state as a pre-release signaling "foundation complete, not yet dogfooded."

- [ ] **Step 1: Verify the git tree is clean**

Run: `git status --porcelain`
Expected: empty output (no uncommitted changes)

- [ ] **Step 2: Tag the current HEAD**

```bash
git tag -a v0.0.1-pre -m "v0.0.1-pre: Plugin foundation complete

Foundation complete:
- Plugin manifest and directory scaffold
- Core /ooda skill (SKILL.md router, 4 phase files, 3 reference files)
- Forked test-driven-development skill with MUTATE/KILL phases
- Adapter template (ooda.project.md) with full schema
- Three commands: /ooda, /ooda-init, /ooda-validate
- Test fixtures: example, minimal, invalid adapters
- GitHub Actions CI for linting and YAML validation
- TDD fork upstream diff helper script

Next: Plan 2 (dogfood migration of CivicReach project) will validate the extraction.
Not yet dogfooded; not yet published to marketplace.
"
```

- [ ] **Step 3: Push commits and tag to origin**

```bash
git push origin main
git push origin v0.0.1-pre
```

- [ ] **Step 4: Verify the tag exists on remote**

Run: `gh release list --limit 5 2>&1 || git ls-remote --tags origin | grep v0.0.1-pre`
Expected: the tag is listed

- [ ] **Step 5: Optional — create GitHub release from the tag**

```bash
gh release create v0.0.1-pre \
  --title "v0.0.1-pre: Plugin foundation complete" \
  --notes "Plugin foundation complete. Not yet dogfooded, not yet published to marketplace. See Plan 2 for the dogfood migration." \
  --prerelease
```

Expected: GitHub release URL printed.

---

## Self-review

After completing all tasks, the plugin repo should have:

- [ ] A working `plugin.json` manifest at version 0.0.1
- [ ] A CLAUDE.md explaining the repo to future Claude agents
- [ ] The core `/ooda` skill split across SKILL.md (router), 4 phase files, 3 reference files
- [ ] The forked `test-driven-development` skill with MUTATE/KILL phases and NOTICE.md attribution
- [ ] An adapter template with every schema slot present
- [ ] Three slash commands: `/ooda`, `/ooda-init`, `/ooda-validate`
- [ ] Three test fixtures: example (full coverage), minimal, invalid
- [ ] A GitHub Actions CI workflow for linting and YAML parse validation
- [ ] An upstream sync helper script (`scripts/diff-upstream-tdd.sh`)
- [ ] A tagged v0.0.1-pre pre-release on GitHub

After Plan 1, the plugin exists as a published Git repo and GitHub release. It has never been installed in a real Claude Code session — that's Plan 2 (dogfood migration to the CivicReach project), which will:
1. Install the plugin locally in the voice-ai-platform-lab project
2. Write the CivicReach-specific `.claude/ooda.project.md` adapter
3. Run a regression test on a real session
4. Remove the local `.claude/skills/ooda/SKILL.md` once the plugin is validated
5. Update CivicReach's CLAUDE.md references
6. Open a PR

## Success criteria for Plan 1

- All 27 tasks completed with commits
- v0.0.1-pre tag pushed to `github.com/adilasif/ooda`
- CI workflow passes on the tagged commit
- The upstream TDD diff script runs without errors
- Every skill file and command file has valid YAML frontmatter
- The example adapter fixture exercises every schema slot
