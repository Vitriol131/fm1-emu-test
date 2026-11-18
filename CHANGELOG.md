# Changelog — Vitriol131 fork

This file records changes made in this fork, not changes in the upstream
[joakimeriksson/fm1-emu](https://github.com/joakimeriksson/fm1-emu) project.

Status terms used below:
- **Edited:** the change has been committed to this fork.
- **Built:** a local build completed successfully.
- **Tested:** the relevant behavior was exercised; the environment and scope are stated.

A commit or source edit alone does not mean that a feature has been built or tested.

## 2026-11-18

### Documentation
- Identified this repository as an unofficial, experimental fork.
- Documented the fork's goal: experimental MIDI Learn and contextual MIDI mapping for the FM-1 plugin, with the intended controller targets SELECT, PRESETS, ALGORITHM and KNOB1–KNOB4.
- Added an AI-assisted / vibe-coded development disclosure and an at-your-own-risk, no-warranty notice.
- Added this fork-specific changelog.

**Verification:** documentation committed to branch `midi-learn`; no software behavior is implied by these documentation changes.

### Compiler-warning review
- Began reviewing compiler warnings and making source corrections where the cause can be addressed safely, rather than merely suppressing warnings.
- This review is ongoing. Individual changes must be rebuilt and their behavior checked before being described as validated.

**Verification:** source edits have been committed, but the latest state has not yet been recompiled and tested as a whole.

### MIDI Learn
- Work in progress. The branch is intended for development of MIDI Learn and contextual mapping in the FM-1 plugin.
- No claim of complete implementation or reliable operation is made at this stage.
