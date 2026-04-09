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
