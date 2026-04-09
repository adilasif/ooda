# Design: Generic `/ooda` Plugin

**Date:** 2026-04-08
**Status:** Draft — awaiting review
**Linear:** (none — tooling meta-work)
**Rigor:** Hardened (cross-system: new plugin repo + migration of this project's engineering lifecycle)
**Target plugin repo:** `github.com/adilasif/ooda-plugin`

## Problem

The current `/ooda` skill lives at `.claude/skills/ooda/SKILL.md` in this repository (371 lines). It codifies a complete engineering lifecycle orchestrator — rigor profiles, phase handover contracts, session context loading, stash hygiene, pre-PR gates, post-completion rituals, session debriefs, release changelog workflow — but it is deeply entangled with CivicReach-specific infrastructure: Linear (CRAI-### branches, CivicReach team), Notion (Product Roadmap, Session Debriefs DB, Changelog Buffer), `just` commands, tenant names (Danville / CVCAA / CoAction), GCP + LiveKit + ElevenLabs + BigQuery stack references, `docs/plans/` paths, Mergify, and local skills like `/capture-knowledge`.

The universal engineering discipline encoded in the skill (the OODA framing, four rigor profiles, phase handover contracts, four-question debrief framework, worktree-first rule, pre-PR gate structure, post-completion validation gap check) is valuable on *any* project. But as currently written, it cannot be dropped onto a non-CivicReach project without heavy manual editing.

**Goal:** extract the universal engineering lifecycle into a shareable Claude Code plugin that any project can install and configure with a per-project adapter file, while preserving 100% of the behavior this project's current `/ooda` skill provides.

## Goals

1. **Universal core skill** — OODA loop, rigor profiles, phase handover contracts, session debrief framework, stash hygiene, worktree-first, pre-PR gate structure, post-completion ritual — all codified once, reused across projects.
2. **Per-project adapter** — every project-specific concern (issue tracker, PM doc store, branch conventions, quality commands, dev deploy, skill slot bindings, rigor thresholds, knowledge/changelog destinations) lives in a declarative adapter file that the core skill reads at session start.
3. **Every adapter component optional** — a project with no issue tracker, no PM doc store, no dev deploy, and no validation registry can still use `/ooda` and get a coherent lifecycle.
4. **Dogfooded on this repo first** — the CivicReach project becomes the first consumer of the new plugin, replacing its local `/ooda` skill with the installed plugin + a project adapter. If the adapter can't express CivicReach's nuance, the schema is inadequate and we fix it before publishing.
5. **Distributable as a Claude Code plugin** — day-one plugin packaging, installable via marketplace.
6. **TDD fork** — ships a forked `test-driven-development` skill with RED → GREEN → MUTATE → KILL → REFACTOR loop (adding MUTATE and KILL phases between GREEN and REFACTOR), derived from `superpowers@5.0.7` with MIT attribution, tied to rigor-profile kill-rate thresholds.
7. **Depend on upstream superpowers for everything else** — brainstorming, writing-plans, systematic-debugging, using-git-worktrees, subagent-driven-development, executing-plans, finishing-a-development-branch, verification-before-completion, requesting-code-review — no fork, automatic inheritance of upstream improvements.
8. **Enforceable contract** — frontmatter slots in the adapter are the machine-readable policy surface; a `/ooda-validate` command validates adapters on demand.

## Non-goals

- **Not rebuilding superpowers.** The plugin depends on `superpowers` as a required plugin and only forks the one skill where the divergence (mutation testing in the TDD loop) cannot be expressed as config.
- **Not replacing hookify or shell hooks.** This project's enforcement layer (validation registry, hookify rules, shell hooks, import-linter) is not bundled into the plugin. The adapter can point at these resources when present, but the plugin does not ship enforcement infrastructure of its own.
- **Not auto-generating project adapters from repo heuristics.** `/ooda-init` drops a template adapter with all slots present and commented; users fill in what applies. We don't try to detect "this project uses Linear" from the repo state.
- **Not supporting platforms other than Claude Code in this plugin.** The upstream superpowers plugin supports 6 platforms; our plugin focuses on Claude Code. Multi-platform support is out of scope for v0.
- **Not blocking on upstream acceptance of a mutation-testing PR.** We may try to upstream the mutate/kill phases as a contribution to superpowers later, but the plugin ships first with its own fork.

## Decisions (from brainstorming session)

The architecture was narrowed through seven sequential decisions. Each is load-bearing; changing any of them would require revisiting downstream sections.

| # | Decision | Rationale |
|---|---|---|
| 1 | **Core skill + per-project adapter, every component optional** | Lets the core be genuinely universal; missing adapter = default mode works; missing adapter slot = graceful degradation for that concern only |
| 2 | **Refactor in place (dogfood)** — this project becomes the first consumer of the new pattern | Forcing function against design drift; the existing 371-line skill is the acid test for the adapter's expressiveness |
| 3 | **Day-one Claude Code plugin** at `github.com/adilasif/ooda-plugin` | Sharing is a stated goal; plugin manifest + install semantics invested upfront |
| 4 | **Hybrid adapter shape: YAML frontmatter + Markdown body** | Frontmatter is the enforceable policy contract (validated, machine-readable); body carries prose for Claude (project-specific workflows, custom gates, outage history) |
| 5 | **Depend on superpowers as a required plugin dependency** | Composability is superpowers' explicit design intent; no fork of stable skill primitives |
| 6 | **Fork only the TDD skill** into this plugin, default adapter slot points at the fork, users can override to upstream via `skills.tdd` slot | Mutation/kill phases cannot be expressed as config against superpowers' integrated-prose TDD skill; fork surface is contained to one 371-line file |
| 7 | **Flexible per-profile rigor overrides in adapter frontmatter** (not fixed profiles in core) | Preserves project autonomy over rigor policy while keeping the profile *structure* universal |

## Architecture

The plugin ships two skills and three commands. The core `/ooda` skill is the lifecycle orchestrator; the forked `test-driven-development` skill is the TDD implementation with MUTATE/KILL phases. Both are installed together and evolve together in the same repo.

### Dependency graph

```
┌─────────────────────────────────────────────────────────┐
│  ooda-plugin (this plugin)                              │
│                                                         │
│   skills/ooda/            — lifecycle orchestrator      │
│   skills/test-driven-     — forked TDD (RED→GREEN→      │
│     development/            MUTATE→KILL→REFACTOR)       │
│                                                         │
│   commands/               — /ooda, /ooda-init,          │
│                             /ooda-validate              │
└─────────────────────────────────────────────────────────┘
                    │
                    │ depends on (required)
                    ▼
┌─────────────────────────────────────────────────────────┐
│  superpowers (obra/superpowers, MIT)                    │
│                                                         │
│   brainstorming, writing-plans, executing-plans,        │
│   subagent-driven-development, systematic-debugging,    │
│   using-git-worktrees, finishing-a-development-branch,  │
│   verification-before-completion, requesting-code-      │
│   review, receiving-code-review, dispatching-parallel-  │
│   agents, writing-skills                                │
└─────────────────────────────────────────────────────────┘

                    │
                    │ consumed by
                    ▼
┌─────────────────────────────────────────────────────────┐
│  Consumer project                                       │
│                                                         │
│   .claude/ooda.project.md    — adapter file             │
│     (optional — plugin runs in default mode if absent)  │
│                                                         │
│   .claude/skills/<local>/    — local skills that the    │
│                                adapter can reference    │
│                                via slots like           │
│                                skills.capture_knowledge │
└─────────────────────────────────────────────────────────┘
```

### Runtime flow (session start)

1. User invokes `/ooda [issue-id]` (or runs on a branch with a matching issue regex)
2. Core skill searches for adapter at `.claude/ooda.project.md` → `.claude/skills/ooda/project.md` → `ooda.project.md`
3. If no adapter found: announce default mode, continue with synthetic defaults
4. If adapter found: parse frontmatter, validate `schema_version`, read body sections, build session context
5. Core skill runs Observe phase (context loading, stash hygiene, issue/epic lookup using adapter-declared tracker/doc-store bindings)
6. Core skill determines rigor level (from argument, adapter `rigor.default`, or user override)
7. Subsequent phases (Orient, Decide, Act) invoke adapter-declared sub-skills by the names supplied in `skills.*` frontmatter slots, falling back to inline prose when a slot is null

## Plugin repo layout

```
ooda-plugin/
├── .claude-plugin/
│   └── plugin.json                        # manifest: name, version, deps, commands
├── skills/
│   ├── ooda/
│   │   ├── SKILL.md                       # entry, ~250-350 lines, router for phases
│   │   ├── phases/
│   │   │   ├── observe.md                 # session context, stash, adapter load
│   │   │   ├── orient.md                  # rigor selection, design/plan gate
│   │   │   ├── decide.md                  # handover contracts, validation, PR gate
│   │   │   └── act.md                     # implement, PR, knowledge, debrief
│   │   ├── rigor-profiles.md              # reference: 4 profiles
│   │   ├── handover-contracts.md          # reference: evidence matrix
│   │   ├── debrief.md                     # four-question root cause framework
│   │   └── templates/
│   │       └── ooda.project.md            # adapter template copied by /ooda-init
│   └── test-driven-development/
│       ├── SKILL.md                       # fork from superpowers + MUTATE/KILL
│       ├── NOTICE.md                      # MIT attribution, upstream sync notes
│       └── .last-upstream-sync            # SHA of last synced upstream commit
├── commands/
│   ├── ooda.md                            # /ooda slash command (session entry)
│   ├── ooda-init.md                       # /ooda-init — drop adapter template
│   └── ooda-validate.md                   # /ooda-validate — check adapter
├── scripts/
│   └── diff-upstream-tdd.sh               # helper: diff forked TDD against upstream
├── tests/
│   └── fixtures/
│       └── example-adapter.md             # full-coverage adapter exercising all slots
├── .github/
│   └── workflows/
│       └── lint.yml                       # markdownlint, validator self-check
├── README.md                              # install, schema, upgrade model, TDD rationale
├── CHANGELOG.md                           # Keep-a-Changelog format
├── LICENSE                                # MIT
└── .version-bump.json                     # optional, if using version bump tooling
```

### Rationale for key structural choices

- **Phase files under `skills/ooda/phases/`** — the current CivicReach skill is already 371 lines; adding adapter-aware prose will push it higher. Splitting by phase keeps each file under ~150 lines and allows Claude to load only the phase it needs at any given transition. The top-level `SKILL.md` is a short router.
- **Reference files (`rigor-profiles.md`, `handover-contracts.md`, `debrief.md`)** loaded on-demand — the rigor profile table, handover matrix, and debrief framework are substantial but not always needed in every phase. Separating them lets phases reference them without inlining.
- **Forked TDD skill as a sibling of `skills/ooda/`** — matches superpowers' skill organization; keeps the fork diff-friendly against upstream.
- **`scripts/diff-upstream-tdd.sh`** is a manual helper, not a hook. Run when the plugin author sees a new superpowers release.
- **No bundled superpowers.** Declared as required dependency in `plugin.json` and prose instructions in README.
- **No hookify rules, validation registry, or shell hooks** shipped with the plugin. Enforcement is per-project. Adapter can point at project-local enforcement infrastructure.

## Adapter contract — frontmatter schema (v1)

The frontmatter is the enforceable machine-readable contract. Every slot except `schema_version` and `name` is optional; missing = "this concern doesn't apply to this project" → graceful degradation per section below.

```yaml
---
# ─── Identity ───────────────────────────────────────────
schema_version: 1                  # REQUIRED — plugin validates this
name: "<human project name>"       # REQUIRED

# ─── Issue tracker (optional) ───────────────────────────
issue_tracker:
  type: linear                     # linear | github | jira | none
  team_or_project: "<team name>"
  branch_id_regex: '<regex>'       # e.g., '[Cc][Rr][Aa][Ii]-\d+'
  mcp_server: "<mcp-server-name>"  # optional — for MCP lookups
  states:                          # workflow states in order
    - Backlog
    - In Progress
    - Done
  auto_transitions:
    pr_opened: "<state>"
    pr_merged: "<state>"

# ─── PM doc store (optional) ────────────────────────────
pm_doc_store:
  type: notion                     # notion | confluence | none
  epic_database_id: "<id>"
  linked_field_name: "<field>"
  status_mapping:
    "In Progress": "In Development"
  debrief_database_id: "<id>"      # optional — debrief persistence
  changelog_database_id: "<id>"    # optional — changelog buffer

# ─── Branch & worktree (optional) ───────────────────────
branch:
  type_prefixes: [fix, feat, docs, chore]
  format: "{type}/{issue_id}-{slug}"
  worktree_policy: required        # required | optional | never
  worktree_exempt_paths:
    - .claude/
    - docs/

# ─── Quality commands (optional) ────────────────────────
quality:
  format_lint_typecheck: "<cmd>"
  unit_tests: "<cmd>"
  full_check: "<cmd>"
  single_file_typecheck: "<cmd with {file}>"
  single_file_lint: "<cmd with {file}>"
  single_test_file: "<cmd with {file}>"
  pre_push: |
    <multi-line pre-push checks>

# ─── Dev deploy (optional) ──────────────────────────────
dev_deploy:
  enabled: true
  trigger_paths:
    - <glob>
  deploy_trigger: push             # push | manual | skaffold
  status_command: "<cmd>"
  validate_command: "<cmd>"
  teardown_command: "<cmd>"

# ─── Skill slots ────────────────────────────────────────
skills:
  brainstorm: superpowers:brainstorming
  writing_plans: superpowers:writing-plans
  tdd: ooda:test-driven-development          # default: the fork
  systematic_debugging: superpowers:systematic-debugging
  using_git_worktrees: superpowers:using-git-worktrees
  subagent_driven_development: superpowers:subagent-driven-development
  executing_plans: superpowers:executing-plans
  finishing_a_development_branch: superpowers:finishing-a-development-branch
  verification_before_completion: superpowers:verification-before-completion
  requesting_code_review: superpowers:requesting-code-review
  capture_knowledge: null                    # null = inline prose fallback
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
auto_merge:
  tool: mergify                    # mergify | github-auto-merge | none
  default_draft: true

# ─── Validation registry (optional) ─────────────────────
validation_registry:
  path: ".claude/validation-registry.yaml"

# ─── Plugin version pin (optional) ──────────────────────
plugin:
  pinned_version: null             # set to "0.3.2" to warn on mismatch
---
```

## Adapter contract — Markdown body sections

Below the frontmatter, the adapter carries prose under named headings. Every heading is optional; missing heading = core skill uses its default prose.

| Heading | Purpose |
|---|---|
| `## Project Overview` | 1-3 paragraph description, tech stack, domains (tenants, environments) |
| `## Notable Risks and Outage History` | Things that have caused outages before; informs rigor judgment on ambiguous cases |
| `## Custom Workflows` | Project-specific workflows that don't fit a flat frontmatter slot (epic property schemas, changelog buffer column schemas, dev validation via MCP, knowledge DB rebuild steps) |
| `## Phase Overrides` | Where the project deviates from default rigor profile rules; specific anti-pattern examples |
| `## Release Process` | How releases are cut (compile unreleased entries, group, draft, approve, post, mark released) |
| `## Session Start Checklist` | Project-specific items beyond universal stash hygiene |
| `## Pre-PR Gate Additions` | Project-specific gates beyond the universal set |
| `## Tenant / Environment Inventory` | Optional — for multi-tenant or multi-env projects |

Core skill reads these sections when processing the corresponding phase. If a heading is absent, the core falls back to default prose for that concern.

## Core skill runtime behavior

### Adapter discovery

On invocation, the core walks this sequence:

1. **Look for adapter** at these paths, first-match-wins:
   - `.claude/ooda.project.md`
   - `.claude/skills/ooda/project.md`
   - `ooda.project.md`
2. **No adapter found:** announce default mode, continue with synthetic default adapter (all optional slots absent, `skills.*` defaults to `superpowers:*`, rigor profiles use hard-coded universal values, quality/dev-deploy/pm-doc-store phases skipped)
3. **Adapter found but frontmatter invalid:** announce the specific error, stop, offer `/ooda-validate`
4. **Adapter found and valid:** parse frontmatter into session context, read present body sections, proceed

### Phase routing

| Phase | When loaded | File | Reads from adapter |
|---|---|---|---|
| **Observe** | Session start | `phases/observe.md` | `issue_tracker.*`, `pm_doc_store.*` |
| **Orient** | Before design/plan/implement | `phases/orient.md` | `rigor.profiles.*`, `skills.brainstorm`, `skills.writing_plans` |
| **Decide** | Before validation/review/PR | `phases/decide.md` | `quality.*`, `validation_registry.*`, `skills.requesting_code_review`, `skills.review_pr` |
| **Act** | Implementation through completion | `phases/act.md` | `skills.using_git_worktrees`, `skills.tdd`, `dev_deploy.*`, `skills.capture_knowledge`, `plans.*`, `knowledge.*`, `pm_doc_store.changelog_database_id`, `pm_doc_store.debrief_database_id`, `auto_merge.*` |

### Skill invocation pattern (the key discipline)

Core files never reference a sub-skill by canonical name. They always say:

> "Read the current project adapter's `skills.brainstorm` slot. If set, invoke that skill via the Skill tool. If null or adapter missing, fall back to inline prose: [specific prose describing the obligation]."

This indirection is what makes the core truly project-agnostic. The forked TDD skill is treated the same way — by default `skills.tdd: ooda:test-driven-development`, but adapters can override.

### Skill name prefixes

Skill slot values use a `<source>:<skill-name>` format to disambiguate where the skill lives:

- `superpowers:<skill>` — a skill from the upstream superpowers plugin (e.g., `superpowers:brainstorming`)
- `ooda:<skill>` — a skill shipped by this plugin (e.g., `ooda:test-driven-development` for the fork)
- `<other-plugin>:<skill>` — a skill from any other installed plugin (e.g., `pr-review-toolkit:review-pr`)
- `local:<skill>` — a project-local skill living in the consumer project's `.claude/skills/<skill>/` directory (e.g., `local:capture-knowledge` for a custom skill that isn't packaged as a plugin)
- `null` — no skill; core falls back to inline prose for that obligation

## Graceful degradation table

| Absent slot | Core behavior |
|---|---|
| `issue_tracker` (entire block) | Skip issue lookup, branch → issue mapping, state transitions. Announce: "No issue tracker configured." |
| `pm_doc_store` (entire block) | Skip epic lookup, Notion sync, session-start roadmap scan |
| `pm_doc_store.debrief_database_id` | Record debrief in chat only |
| `pm_doc_store.changelog_database_id` | Skip changelog accumulation |
| `dev_deploy` (entire block) | Skip dev deploy gate for all rigor levels |
| `skills.brainstorm` | Use inline prose fallback (obligation still applies) |
| `skills.capture_knowledge` | Use inline prose fallback: summarize decisions/experiments/failures/rejected approaches, save to `knowledge.destination_path` |
| `knowledge.destination_path` | Default to `docs/knowledge/` or skip persistence if user declines |
| `plans.*_path` | Default to `docs/plans/` and `docs/plans/completed/` |
| `validation_registry` | Skip registry check; rely on rigor profile gates alone |
| `auto_merge` | Don't emit "create as draft first" rule (Mergify-specific) |
| `branch.worktree_policy` | Default to `required` for non-exempt files |
| `branch.worktree_exempt_paths` | Default to empty list (strict) |
| `quality.*` | Skip quality gate step; announce "No quality gate configured — self-check manually before PR" |

**Completely missing adapter (default mode):** core runs with synthetic defaults for every slot. `/ooda` still produces a coherent session on a repo that has no knowledge of the plugin.

## Migration plan for CivicReach

### Categorization of current skill sections

Full mapping of `.claude/skills/ooda/SKILL.md` sections to their new home:

| Current section | Lines | Fate | Destination |
|---|---|---|---|
| OODA loop overview | 8-15 | CORE | `skills/ooda/SKILL.md` |
| Linear Integration intro | 17-20 | CORE | Generic prose in `phases/observe.md` |
| Linear workflow states | 19 | FRONTMATTER | `issue_tracker.states` |
| Branch naming `{type}/CRAI-{n}` | 23 | FRONTMATTER | `branch.format`, `branch.type_prefixes`, `issue_tracker.branch_id_regex` |
| Linear auto-transitions | 24-25 | FRONTMATTER | `issue_tracker.auto_transitions` |
| "Creating work items" | 27-30 | CORE | Generic "tracker + doc store create" prose in `phases/orient.md` |
| "Linear ID" Notion property | 29 | FRONTMATTER | `pm_doc_store.linked_field_name` |
| Workflow Enforcement paragraph | 40 | CORE | Generic prose in `SKILL.md` |
| `validation-registry.yaml` path | 40 | FRONTMATTER | `validation_registry.path` |
| `import-linter` mention | 40 | BODY | `## Custom Workflows` |
| Rigor profile names + structure | 42-108 | CORE | `rigor-profiles.md` |
| Rigor profile thresholds/flags | 42-108 | FRONTMATTER | `rigor.profiles.*` |
| Phase Handover Contracts matrix | 110-124 | CORE | `handover-contracts.md` |
| Session Context Loading procedure | 128-133 | CORE | `phases/observe.md` |
| Stash Hygiene | 136-144 | CORE | `phases/observe.md`, `phases/act.md` |
| Worktree First universal | 148-156 | CORE | `phases/orient.md` |
| Exempt file list | 157 | FRONTMATTER | `branch.worktree_exempt_paths` |
| `just setup-db-all`, knowledge DB | 154 | BODY | `## Custom Workflows` |
| Skill Chain | 161-166 | CORE | `phases/orient.md`, `phases/act.md` (uses `skills.*`) |
| Plan quality gate | 167 | CORE | `phases/orient.md` |
| Team "CivicReach" | 179 | FRONTMATTER | `issue_tracker.team_or_project` |
| Notion "Product Roadmap" DB | 184-188 | FRONTMATTER | `pm_doc_store.epic_database_id` |
| Notion epic property schema | 186-188 | BODY | `## Custom Workflows` (too structured for flat slot in v1) |
| Keeping Notion in Sync concept | 194 | CORE | `phases/act.md` |
| Notion status mapping | 196-200 | FRONTMATTER | `pm_doc_store.status_mapping` |
| Pre-commit hook verify sync | 202 | BODY | `## Custom Workflows` |
| Pre-PR gate list structure | 208 | CORE | `phases/decide.md` |
| `/review-pr` invocation | 210 | CORE + FRONTMATTER | `skills.review_pr` |
| `just check` + ruff commands | 211 | FRONTMATTER | `quality.format_lint_typecheck`, `quality.pre_push` |
| `just test-unit` | 212 | FRONTMATTER | `quality.unit_tests` |
| Dev testing via MCP | 213-218 | FRONTMATTER + BODY | `dev_deploy.*` + `## Custom Workflows` → "Dev validation via telephony" |
| `packages/runtime/` trigger paths | 214 | FRONTMATTER | `dev_deploy.trigger_paths` |
| Knowledge capture before push | 220 | CORE | `phases/decide.md` |
| Plan archival before push | 221 | CORE + FRONTMATTER | `plans.active_path`, `plans.completed_path` |
| Commit hygiene | 222 | CORE | `phases/decide.md` |
| Epic phase-children check (principle) | 223 | CORE | `phases/decide.md` |
| CRAI-177 / CRAI-70 / CRAI-245 examples | 223 | BODY | `## Notable Risks and Outage History` |
| Draft PR + Mergify rationale | 224 | CORE + FRONTMATTER | `auto_merge.tool`, `auto_merge.default_draft` |
| Validation Gap Check structure | 232-238 | CORE | `phases/act.md` post-completion |
| Knowledge Capture concept | 240 | CORE | `phases/act.md` |
| `/capture-knowledge` skill | 241 | FRONTMATTER | `skills.capture_knowledge: local:capture-knowledge` |
| `docs/knowledge/` path | 241 | FRONTMATTER | `knowledge.destination_path` |
| Changelog Entry concept | 253-276 | CORE | `phases/act.md` post-completion |
| Changelog Buffer DB ID | 254-255 | FRONTMATTER | `pm_doc_store.changelog_database_id` |
| Changelog column schema | 263-268 | BODY | `## Custom Workflows` |
| Release Changelog structural pattern | 288-321 | CORE | `phases/act.md` release subsection |
| Slack channel + format template | 295-316 | BODY | `## Release Process` |
| Session-Start Notion Scan | 325-331 | BODY | `## Session Start Checklist` |
| Session Debrief structure | 335-340 | CORE | `debrief.md` |
| Four-question root cause framework | 348-354 | CORE | `debrief.md` |
| Debrief DB ID | 361 | FRONTMATTER | `pm_doc_store.debrief_database_id` |

**Deliberately awkward cases** (flagged for possible v2 schema):

1. **Notion epic property schema** — too structured for a flat slot in v1; lives in `## Custom Workflows` as a code block. Promotable to `pm_doc_store.epic_properties` if another project hits the same shape.
2. **Changelog Buffer column schema** — same treatment. Promotable to structured slot in v2.
3. **Dev deploy validation via MCP `call_start`** — CivicReach-specific tooling; frontmatter captures the command pattern, `## Custom Workflows` carries the semantic.

### Migration steps (in order)

1. **Build plugin repo in scratch directory** — create `ooda-plugin/` with full structure; write core skill files by extracting content from current CivicReach `/ooda`
2. **Fork TDD skill** — copy `superpowers@5.0.7/skills/test-driven-development/SKILL.md`, insert MUTATE/KILL phases between GREEN and REFACTOR, add rigor-aware threshold language, write `NOTICE.md`, write `scripts/diff-upstream-tdd.sh`
3. **Write CivicReach adapter** at `.claude/ooda.project.md` using the categorization table above as checklist; verify every current section has a destination
4. **Side-by-side review** — walk current skill / new core / new adapter together, confirm no gaps
5. **Install plugin locally** (symlink or dev install) so `/ooda` loads from plugin in this repo; leave local skill in place temporarily
6. **Regression test on fresh session** — `/ooda CRAI-218` or similar; verify adapter loads, issue fetches, stash hygiene runs, rigor selects, phase routing works, pre-PR gate lists right CivicReach-specific steps
7. **Retrospective comparison** — pick recent PR (e.g., CRAI-227/228), walk through what old vs new `/ooda` says at each phase; any substantive divergence is a bug
8. **Remove local skill + update CLAUDE.md** — delete `.claude/skills/ooda/SKILL.md`, update CLAUDE.md references, grep `.claude/rules/` and hookify rules for stale references
9. **Commit CivicReach-side changes** — one PR: remove local skill, add adapter, update CLAUDE.md references
10. **Publish plugin** — push `ooda-plugin` to `github.com/adilasif/ooda-plugin`, register with marketplace, write README

### Risks and mitigations

| Risk | Mitigation |
|---|---|
| Adapter schema misses current behavior | Step 4 side-by-side review before removing local skill; extend schema or body sections if gaps |
| Hookify rules reference old skill location | Step 8 — grep `.claude/hookify.*.md`; rewrite rules to be adapter-aware where needed |
| Worktrees contain copies of old skill | List active worktrees; plan is ephemeral per worktree |
| Plugin install path not clean | Test in Step 5 before Step 8; don't delete local skill until plugin verified |
| Forked TDD drifts from upstream silently | `scripts/diff-upstream-tdd.sh` run manually on new superpowers releases |
| Plugin bugs only surface in second project | Expected — dogfood this project first, iterate schema, THEN publish stable |
| `/ooda-init` overwrites existing adapter | Refuse overwrite without `--force`, print existing path |
| Schema v1 missing needed slot for v2 | `schema_version: 1` enables explicit migration; validator warns on version mismatch |

### Verification plan

1. **Smoke:** `/ooda` on fresh session — adapter detected, summary printed correctly
2. **Context load:** `/ooda CRAI-218` — Linear issue + Notion epic + plan file detected
3. **Rigor:** trigger each of four rigor levels via test prompts; verify handover contract rendering matches frontmatter values
4. **Phase walk:** synthetic standard-rigor session end-to-end — design (skipped per profile), worktree, TDD via forked skill, pre-PR gate runs adapter quality commands, PR as draft, knowledge capture via local skill, plan archival, post-completion validation gap check, debrief offered
5. **Default mode:** `/ooda` from scratch directory with no adapter — clean fallback with clear announcement
6. **Validator:** `/ooda-validate` against CivicReach adapter (clean); break slot deliberately; verify validator catches each

## Versioning & upgrade model

Three independent version dimensions:

1. **Plugin version** (`plugin.json` `version`) — semver
   - **Major:** breaking core lifecycle change (removes phase, changes slot meaning)
   - **Minor:** additive (new optional slot, new phase file, new command)
   - **Patch:** prose improvements, TDD fork sync, typo fixes
2. **Adapter schema version** (`schema_version:` in adapter) — monotonic integer
   - Bumped only for shape changes that require existing adapters to be rewritten
   - Adding new optional slots does NOT bump schema version
3. **Tested-against superpowers range** (`plugin.json` metadata)
   ```json
   "superpowersCompatibility": {
     "tested": "5.0.7",
     "minimum": "5.0.0",
     "maximum": null
   }
   ```

### Consumer upgrade experience

| Update type | User experience |
|---|---|
| Patch bump | Silent update; next invocation loads new version |
| Minor bump | Silent update; CHANGELOG has new slot/phase notes |
| Major bump, schema unchanged | One-line "updated to vX.Y.Z — see CHANGELOG" on first post-update invocation |
| Major bump, schema changed | `/ooda-validate` runs automatically on next invocation; blocks session until adapter migrated; CHANGELOG has migration guide |

**Version pinning:** adapter can declare `plugin.pinned_version: "0.3.2"` to emit a warning on version mismatch. Informational, not enforced.

### Deprecation policy

Two-step (after plugin reaches 1.0.0):
1. **Deprecation window (one minor release):** slot still works; validator emits warning with replacement guidance
2. **Removal (next major):** slot gone; validator errors; schema version bumps

**Pre-1.0:** more aggressive breakage is acceptable since primary consumer is this project.

## Upstream superpowers sync

### Sync cadence

- **Passive:** when noticing new superpowers release, run `scripts/diff-upstream-tdd.sh`, review diff in ~15 min, fold fixes into patch release
- **Active:** recurring reminder (calendar / hookify / schedule skill) every 4-6 weeks; most checks take < 5 min

### `diff-upstream-tdd.sh` behavior

Fetches upstream `test-driven-development/SKILL.md`, diffs against our fork, shows:
1. What changed upstream since last recorded sync (via `.last-upstream-sync` SHA)
2. What's different between upstream and our fork (our additions)
3. Suggested cherry-pick list

Script is a helper, not a hook. Manual invocation only.

### When upstream breaks the fork

Three options:
1. **Rebase the fork** — reapply MUTATE/KILL insertions against new structure; patch release
2. **Pin older upstream** — set `superpowersCompatibility.maximum`, defer rebase
3. **Accept upstream as new baseline** — if upstream subsumes our intent (e.g., adds mutation testing), delete fork, point `skills.tdd` default at upstream; minor release

## Release process for the plugin

Per-release checklist (lightweight, manual):

1. Decide version bump per semver rules
2. Update `CHANGELOG.md` (Keep-a-Changelog format)
3. Run `scripts/diff-upstream-tdd.sh`, sync if useful changes present
4. Run verification suite (Migration Plan §Verification above)
5. Update `plugin.json` version + `superpowersCompatibility.tested`
6. Update `README.md` if schema or install changed
7. Tag commit: `git tag v0.X.Y && git push --tags`
8. Create GitHub release with CHANGELOG section
9. Update marketplace registration

## Plugin CI (lightweight)

What to test:
1. **Lint adapter template** — `/ooda-validate` against `skills/ooda/templates/ooda.project.md`
2. **Smoke-test example adapter** — `tests/fixtures/example-adapter.md` exercises all slots
3. **Attribution check** — `skills/test-driven-development/NOTICE.md` exists and carries required attribution
4. **Markdown lint** — `markdownlint` on all `.md` files
5. **Sanity-check `diff-upstream-tdd.sh`** — no-op invocation in CI

**NOT tested in CI:** actual `/ooda` session behavior. That's a runtime concern; manual verification suite is the release gate.

## README structure

1. **What is `/ooda`** — one-paragraph pitch
2. **Install** — plugin install command, required `superpowers` dependency, `/ooda-init`
3. **Quick start** — 5-step walk-through
4. **Adapter schema** — full frontmatter reference (or link to `docs/adapter-schema.md`)
5. **Rigor profiles** — four profiles + decision tree
6. **Sub-skill slots** — superpowers skill invocations + override mechanism
7. **TDD fork rationale** — why fork, how to opt out, how to track upstream
8. **Upgrade model** — plain-language version of §Versioning
9. **Contributing** — issue-first for schema additions; design discussion required for phase additions
10. **License + credits** — MIT; credit Jesse Vincent / Prime Radiant for superpowers; credit Adil Asif for `/ooda`

## Open items / deferred decisions

- **Plugin name** — working name `ooda-plugin`, repo at `github.com/adilasif/ooda-plugin`. Final name TBD during plugin repo creation; candidates include `ooda`, `ooda-lifecycle`, `ooda-orchestrator`. Plugin identifier (what users type in `/plugin install`) will be chosen then.
- **Marketplace strategy** — do we submit to the official Claude Code marketplace (`claude.com/plugins/`) or host our own marketplace repo? Deferred until plugin is stable (post-v0.1.0, after dogfooding).
- **Mutation testing language bindings** — the forked TDD skill describes MUTATE/KILL phases generically; it does not prescribe a specific tool (mutmut, Stryker, etc.). Each project's adapter body can explain which tool the project uses. Defer language-specific helpers to future releases.
- **Upstreaming mutation phases to superpowers** — we'll try to upstream as a PR after the plugin stabilizes; if accepted, we can retire the fork in a future release.

## Implementation phases (high level)

Final implementation plan will be created by the `writing-plans` skill after this design is approved. High-level phases:

1. **Plugin repo scaffold** — manifest, LICENSE, empty skill directories, README skeleton
2. **Core skill authoring** — SKILL.md router, phases/, rigor-profiles.md, handover-contracts.md, debrief.md (extract from current CivicReach skill)
3. **TDD fork** — copy upstream, insert MUTATE/KILL phases, attribution, `.last-upstream-sync`, `diff-upstream-tdd.sh`
4. **Adapter template** — `skills/ooda/templates/ooda.project.md` with every slot present + commented
5. **Commands** — `/ooda`, `/ooda-init`, `/ooda-validate`
6. **CivicReach adapter** — populate `.claude/ooda.project.md` in this repo
7. **Side-by-side review** — verify every current section has a destination
8. **Local install + regression test** — install plugin in dev mode, run verification suite
9. **Remove local skill + update CLAUDE.md** — clean cutover in this repo
10. **CI, README, CHANGELOG** — plugin repo hygiene
11. **Publish** — tag v0.1.0, push to `github.com/adilasif/ooda-plugin`, marketplace registration

## Success criteria

- CivicReach `/ooda` behavior is preserved 100% after migration (spot-checked against recent PRs)
- Plugin runs cleanly in default mode on a zero-adapter project
- `/ooda-validate` catches deliberately-broken adapters
- Forked TDD skill diff script runs without errors against current upstream
- CivicReach's PR removing the local skill and adding the adapter passes CI
- Plugin repo exists at `github.com/adilasif/ooda-plugin` with v0.1.0 tag, README, CHANGELOG, LICENSE, and working install path
