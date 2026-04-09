---
# schema_version deliberately missing — should trigger CRITICAL
name: "Invalid Example"

issue_tracker:
  type: linear
  branch_id_regex: 12345   # deliberately a number instead of a string — should trigger CRITICAL

rigor:
  default: invalid-profile-name   # deliberately invalid — should trigger CRITICAL
  profiles:
    hardened:
      mutation_threshold: 1.5   # deliberately > 1 — should trigger CRITICAL

skills:
  tdd: "not-a-valid-prefix-format"   # deliberately missing source: prefix — should trigger WARNING or CRITICAL

validation_registry:
  path: ".claude/nonexistent-registry.yaml"   # deliberately nonexistent — should trigger WARNING
---

## Project Overview

An adapter with deliberate errors used to test the `/ooda-validate` command. Each error is marked with a comment explaining what should be flagged.
