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
  review_pr: code-review:code-review

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
