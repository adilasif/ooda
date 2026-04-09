# Phase Handover Contracts

Each phase must produce specific evidence before the next phase can start. Requirements scale with rigor level.

This file is loaded on demand at phase transitions. Before moving from one phase to another, verify the required evidence exists.

## Evidence matrix

| Handover | Patch | Standard | Hardened | Fortified |
|----------|-------|----------|----------|-----------|
| **Design → Plan** | skip | skip | design doc exists and was approved by user | design doc exists and was approved by user |
| **Plan → Implement** | skip | optional (skip if <3 tasks) | plan file exists and was approved by user | plan file exists and was approved by user |
| **Implement → Validate** | tests pass | tests pass + lint clean | tests pass + lint clean + plan archival ready | tests pass + lint clean + plan archival ready |
| **Validate → Review** | skip | validation registry checks (if adapter declares one) | registry + dev deploy evidence | registry + dev deploy + verification drill evidence |
| **Review → Complete** | self-review | review skill invoked, findings addressed | review skill invoked, findings addressed | review skill invoked, findings addressed |
| **Complete → Done** | skip | knowledge capture (if anything surprising) | knowledge + changelog entry + debrief | knowledge + changelog + debrief + backlog proposals if needed |

## How to use this matrix

1. Before starting a phase, look at the row for the handover INTO that phase and the column for your current rigor level.
2. Verify each listed piece of evidence exists (design doc, plan file, tests passing, dev deploy output, etc.).
3. If evidence is missing, complete the previous phase first. Do not proceed.
4. Evidence that's marked "skip" at your rigor level can be bypassed — but if you escalate rigor mid-session (e.g., realized the change is larger than expected), re-check the matrix for the new level.

## Interaction with the adapter

The evidence requirements in this table are *universal structural requirements*. The adapter's `rigor.profiles.*.*` frontmatter supplies the *project-specific thresholds* (e.g., mutation kill rate target, dev deploy verification drill requirement). When a handover depends on a threshold, read it from the adapter, not from this file.
