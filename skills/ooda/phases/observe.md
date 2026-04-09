# Observe Phase — Session Context Loading

The Observe phase runs at session start, after the adapter discovery protocol has loaded the adapter (or fallen back to default mode). Its job is to load context so you can advise meaningfully rather than guessing.

## Procedure

### 1. Stash hygiene (always)

Run `git stash list`. If stashes exist:

1. For each stash, run `git stash show stash@{N} --stat` to see what files were changed.
2. For each modified file, check whether the changes already landed on the main branch via `git log <main-branch> -- <file>`.
3. Report findings to the user: which stashes are superseded (safe to drop), which contain unmerged work.
4. Offer to drop superseded stashes. For stashes with unmerged work, propose either applying them or creating a tracking item.

Stashes rot quickly — most become unmergeable within a few PRs. Catching them early prevents the archaeology session that happens months later.

### 2. Issue lookup (if `issue_tracker` configured)

If the adapter's `issue_tracker` block is present:

1. Check the current branch name against `issue_tracker.branch_id_regex`. If a match is found, extract the issue ID.
2. If the user invoked `/ooda <issue-id>` explicitly, use that instead of the branch-inferred ID.
3. If `issue_tracker.mcp_server` is declared, use the corresponding MCP tools to fetch the issue. Note its current state (matches one of `issue_tracker.states`).
4. If no issue ID is found and no argument was given: ask the user whether to create a new issue or proceed without tracking.

If the adapter has no `issue_tracker`: skip this step. Announce: "No issue tracker configured — proceeding without issue linking."

### 3. Doc store epic lookup (if `pm_doc_store` configured)

If the adapter's `pm_doc_store` block is present AND an issue was found:

1. Look for a linked epic in the doc store using the adapter's `pm_doc_store.linked_field_name` (typically the issue ID as a property).
2. If found, fetch the epic's content for context.
3. If not found, note it — the user may want to create one before proceeding.

If the adapter has no `pm_doc_store`: skip this step.

### 4. Plan file detection

Check the adapter's `plans.active_path` (default `docs/plans/`) for a plan file matching the current work:

1. Look for filenames containing the issue ID, or for a file whose frontmatter/title references this task.
2. If found, read it — it may inform rigor selection and task sequencing.
3. If not found, note it — we may need to write a plan in the Orient phase (depending on rigor).

### 5. Summary announcement

Present a brief summary to the user:

```
[<issue-id>] <issue title> — <current state>
Epic: <link or "none">
Plan: <link or "none">
Adapter: <loaded | default mode>
Recent stashes: <count, with any flagged ones>
```

This grounds the session without consuming much context. From here, proceed to the Orient phase.

## Graceful degradation

- **No adapter:** skip issue/epic lookup, announce default mode, still run stash hygiene and plan detection.
- **Adapter with no issue_tracker:** skip issue lookup, still run stash + plan detection.
- **Issue tracker declared but MCP server not installed/not authenticated:** announce the failure, offer to proceed without issue linking, and suggest either installing the MCP server or removing the slot from the adapter.
- **Doc store declared but lookup fails:** announce the failure, proceed without the epic context.

## Interaction with adapter body sections

If `## Session Start Checklist` is present in the adapter's Markdown body, run its items after the universal steps above. These are project-specific additions like "check the dashboard for unlinked epics in the current sprint."
