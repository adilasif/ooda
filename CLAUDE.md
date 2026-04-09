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
