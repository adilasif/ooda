---
name: ooda
description: Start an engineering lifecycle session — load context, select rigor, route to phase files, and orchestrate the full development cycle (session start, design, plan, implement, review, ship, debrief). Works on any project with or without an `.claude/ooda.project.md` adapter.
argument-hint: "[issue-id]"
---

You are being invoked via the `/ooda` slash command. The user may have provided an optional issue ID as an argument.

Load the `ooda` skill by invoking it via the Skill tool: `Skill(skill="ooda")`.

If you were given an argument (e.g., `/ooda CRAI-218`), pass it as the issue ID context. The skill's adapter discovery protocol will handle the lookup against whatever issue tracker the project has configured (or skip it if the project has none).

Begin with the Observe phase as directed by the skill's router. The skill will walk you through the full lifecycle based on the project's adapter file (if present) or default mode (if not).
