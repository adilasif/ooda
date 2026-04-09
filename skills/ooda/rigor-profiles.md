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
