---
name: ooda-validate
description: Validate the `.claude/ooda.project.md` adapter file in the current project. Checks schema version, required identity fields, slot types, skill slot resolvability, referenced file paths, and rigor profile completeness. Reports findings as Critical, Warning, Info.
---

You are being invoked via the `/ooda-validate` slash command. Your job is to validate the current project's `/ooda` adapter file.

Procedure:

1. **Locate the adapter.** Search for the adapter file in order:
   - `.claude/ooda.project.md`
   - `.claude/skills/ooda/project.md`
   - `ooda.project.md` (repo root)
   Use the first match.

2. **If no adapter found:** announce: "No `/ooda` adapter found in this project. Run `/ooda-init` to create one." Stop.

3. **Parse frontmatter.** Read the file and extract the YAML frontmatter block. If the YAML does not parse:
   - Report CRITICAL: "Adapter frontmatter is not valid YAML: [error message]."
   - Show the specific line and column if the error provides it.
   - Stop.

4. **Check required fields:**
   - `schema_version` must be present and an integer. If missing: CRITICAL. If present but not an integer: CRITICAL. If the integer is greater than the plugin's supported schema version (currently `1`): CRITICAL with message "Adapter schema v<N> is newer than this plugin supports. Update the plugin or downgrade the adapter."
   - `name` must be present and a non-empty string. If missing: CRITICAL. If empty: WARNING.

5. **Check each declared block for type correctness.** For each optional block that is present (`issue_tracker`, `pm_doc_store`, `branch`, `quality`, `dev_deploy`, `skills`, `rigor`, `knowledge`, `plans`, `auto_merge`, `validation_registry`, `plugin`):
   - Verify the block is a mapping (object), not a string or list.
   - For each declared subfield, verify its type matches the schema (strings are strings, lists are lists, booleans are booleans, integers are integers).
   - Flag type mismatches as CRITICAL.

6. **Check skill slot values.** For each entry in `skills.*`:
   - If the value is `null` or the entry is absent, that's fine (inline prose fallback).
   - If the value is a string, it should match the pattern `<source>:<skill-name>` where source is one of `superpowers`, `ooda`, `local`, or a plugin name.
   - If the source is `local:*`, check whether `.claude/skills/<skill-name>/SKILL.md` exists in the current project. If missing: WARNING.
   - If the source is `superpowers:*` or another plugin, we can't verify install without querying Claude Code's plugin state — emit INFO recommending the user install the plugin if not already.

7. **Check referenced file paths.** For:
   - `validation_registry.path` — if set, verify the file exists. If missing: WARNING.
   - `plans.active_path`, `plans.completed_path` — if set, verify the directories exist. If missing: INFO recommending creation.
   - `knowledge.destination_path` — if set, verify the directory exists. If missing: INFO.

8. **Check adapter edge cases:**
   - If the adapter file is empty or has no content: CRITICAL "Adapter file is empty."
   - If the file exists but has no `---` frontmatter delimiters: CRITICAL "Adapter is missing YAML frontmatter delimiters."
   - If the file is a broken symlink: CRITICAL "Adapter path resolves to a broken symlink."

9. **Check rigor profile completeness.** If the `rigor` block is present:
   - Verify `rigor.default` is set to one of: `patch`, `standard`, `hardened`, `fortified`.
   - Verify `rigor.profiles` contains at least the four standard profile names. Missing profiles: WARNING (will fall back to core defaults).
   - For each profile, verify `mutation_threshold` is either `null` or a number between 0 and 1. Values outside this range: CRITICAL.

10. **Check body section headings.** Parse the Markdown body below the frontmatter. Report INFO for any recognized heading that's present (`## Project Overview`, `## Notable Risks and Outage History`, etc.) — this gives the user a summary of what's configured.

11. **Report results.** Present findings grouped by severity:
    - **CRITICAL** (red): blocks session start. Must be fixed.
    - **WARNING** (yellow): session proceeds but degraded behavior expected.
    - **INFO** (blue): informational, no action required.
    Show the count of each severity and a summary: "Adapter is valid / has X warnings / has Y critical issues."

If everything is clean, announce: "✓ Adapter validation passed. Ready to run `/ooda`."
