# ooda

Engineering lifecycle orchestrator plugin for [Claude Code](https://claude.com/claude-code), built on top of [superpowers](https://github.com/obra/superpowers).

## Status

**Early development.** Design phase complete, implementation in progress. This repo is not yet installable as a plugin — stay tuned.

See [`docs/design/2026-04-08-initial-design.md`](docs/design/2026-04-08-initial-design.md) for the full design that this project is being built against.

## What it does

`ooda` will provide a `/ooda` slash command and skill that wraps the full engineering development cycle — session context loading, rigor profile selection, phase handover contracts, pre-PR gates, post-completion rituals, and session debriefs — with a per-project adapter file that binds the universal lifecycle to each project's specific issue tracker, quality commands, and workflow.

The lifecycle is organized around Boyd's OODA loop:

- **Observe** — session context loading: issue lookup, plan file detection, stash hygiene
- **Orient** — rigor profile selection, design and plan gates, skill chain routing
- **Decide** — phase handover contracts, validation checks, pre-PR review gates
- **Act** — implementation, PR creation, knowledge capture, session debrief

Projects configure `ooda` via a `.claude/ooda.project.md` adapter file that declares the issue tracker, branch conventions, quality commands, skill slot bindings, rigor profile thresholds, and knowledge/changelog destinations. Every adapter component is optional — `ooda` runs cleanly on projects that have no issue tracker, no dev deploy infrastructure, and no doc store.

## Dependencies

- [Claude Code](https://claude.com/claude-code)
- [superpowers](https://github.com/obra/superpowers) — required plugin dependency (provides `brainstorming`, `writing-plans`, `systematic-debugging`, and other upstream skills that `ooda` composes)

## Design philosophy

- **Core + per-project adapter** — universal lifecycle lives in the plugin, project-specific bindings live in each project's adapter file
- **Graceful degradation** — missing adapter slots produce prose-only fallbacks, not errors
- **Enforceable contract** — frontmatter slots in the adapter are the machine-readable policy surface, validated by `/ooda-validate`
- **Composability** — depends on upstream `superpowers` for stable skill primitives; forks only where divergence is structurally necessary

## TDD fork

`ooda` will ship a forked `test-driven-development` skill that extends the upstream `superpowers` RED → GREEN → REFACTOR loop with **MUTATE** and **KILL** phases inserted between GREEN and REFACTOR, tied to per-rigor-profile mutation kill-rate thresholds. The fork is derived from `superpowers@5.0.7` under its MIT license. Attribution and upstream sync mechanics will live in `skills/test-driven-development/NOTICE.md` when that skill lands.

Projects that prefer the traditional RED → GREEN → REFACTOR loop can override the `skills.tdd` adapter slot to point at `superpowers:test-driven-development` instead of the forked version.

## License

MIT — see [`LICENSE`](LICENSE).

## Credits

- `ooda` is built by [Adil Asif](https://github.com/adilasif).
- Depends on [superpowers](https://github.com/obra/superpowers) by Jesse Vincent (Prime Radiant), MIT licensed.
- The `test-driven-development` skill in this plugin is a fork derived from `superpowers@5.0.7`, with MUTATE/KILL phases added. See the NOTICE file in that skill's directory when published.
- Design originally extracted from work in the [CivicReach Voice AI Platform](https://github.com/CivicReach-AI/voice-ai-platform-lab) project, where the `/ooda` skill was first developed.
