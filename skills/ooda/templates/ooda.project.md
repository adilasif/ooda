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
