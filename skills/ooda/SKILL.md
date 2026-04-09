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

