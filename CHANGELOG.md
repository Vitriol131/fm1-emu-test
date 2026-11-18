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

### Follow-up source review
- **Core warning correction:** removed the redundant write to `synced` from the `sync!` macro. In the reported warning paths, the macro call returns immediately or is followed by the careful-operation path that sets `synced` again; the macro's write was therefore overwritten before it could be read. The macro still accounts for the uncommitted instruction count using the previous `synced` value.
- Rechecked the previously removed `blk`, `load` and `store_r` helpers: they have no remaining method call sites in the current source. Kept `sext`, which does have decoder call sites.
- Confirmed that the GDB stub crate is explicitly a placeholder and its current source does not use `fm1-core`; removing that unused manifest dependency is consistent with the current implementation.

**Verification:** the core source correction is committed, but a fresh `cargo build` and the core test suite have not yet been run on this commit. The full MIDI Learn implementation remains incomplete.
