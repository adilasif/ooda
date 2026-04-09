---
name: ooda-init
description: Drop the `/ooda` adapter template into the current project at `.claude/ooda.project.md`. Refuses to overwrite an existing adapter without `--force`. Run this once per project to bootstrap the adapter file, then fill in the slots that apply to the project.
argument-hint: "[--force]"
---

You are being invoked via the `/ooda-init` slash command. Your job is to copy the plugin's adapter template into the user's current project at `.claude/ooda.project.md`.

Procedure:

1. **Locate the template.** The template lives inside this plugin at `skills/ooda/templates/ooda.project.md`. You can find the plugin's install path by checking the environment variable `CLAUDE_PLUGIN_ROOT` if set, or by searching `~/.claude/plugins/` for the `ooda` plugin.

2. **Determine the target path.** The target is `.claude/ooda.project.md` in the current working directory. If the `.claude/` directory doesn't exist, offer to create it.

3. **Check for existing adapter.** If `.claude/ooda.project.md` already exists in the current project:
   - If the user supplied `--force`, announce that you're overwriting and proceed.
   - If the user did NOT supply `--force`, stop and announce: "An adapter already exists at `.claude/ooda.project.md`. Use `/ooda-init --force` to overwrite, or edit the existing file directly."
   - Never silently overwrite.

4. **Copy the template.** Read the template file and write its contents to `.claude/ooda.project.md` in the current project. Do not modify the content during the copy — the template is designed to be edited manually.

5. **Announce success and next steps.**
   - "Adapter template written to `.claude/ooda.project.md`."
   - "Edit the file to fill in the slots that apply to your project. Every slot is optional — leave slots commented out if they don't apply."
   - "Run `/ooda-validate` to check your adapter, then `/ooda` to start a session."

6. **Do not run `/ooda` automatically.** The user may want to fill out the adapter before starting a session.

If the template file cannot be found (plugin not installed correctly, or path mismatch), announce the error clearly and suggest reinstalling the plugin.
