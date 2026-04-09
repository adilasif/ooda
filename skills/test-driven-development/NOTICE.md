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
