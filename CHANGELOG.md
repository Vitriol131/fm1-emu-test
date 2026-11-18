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
- Documented the complete intended scope of the fork's MIDI Learn: every mouse-operable FM-1 and SMK-37 panel control (encoders, Master/volume, buttons and selectors, pads, faders and pitch/mod wheels), excluding only the SMK-37's 37 musical keys. This is a target specification, not a claim of implementation.
- Added an AI-assisted / vibe-coded development disclosure and an at-your-own-risk, no-warranty notice.
- Added this fork-specific changelog.

**Verification:** documentation committed to branch `midi-learn`; no software behavior is implied by these documentation changes.

### Compiler-warning review
- Began reviewing compiler warnings and making source corrections where the cause can be addressed safely, rather than merely suppressing warnings.
- This review is ongoing. Individual changes must be rebuilt and their behavior checked before being described as validated.

**Verification:** source edits have been committed, but the latest state has not yet been recompiled and tested as a whole.

### MIDI Learn — implementation work
- The intended scope is all mouse-operable panel controls on both supported boards: FM-1's seven encoders, Master pot, buttons and selectors; SMK-37's eight encoders, 16 pads, four faders, pitch/mod wheels, buttons and selectors.
- The SMK-37's 37 white and black musical keys are explicitly out of scope.
- Implemented panel-control targeting for all of the above controls, with unique target slots; the SMK-37's 37 musical keys remain excluded from MIDI Learn while retaining their normal mouse-play behavior.
- MIDI Learn accepts MIDI CC and note-on/note-off sources. Learned events are consumed before the normal firmware MIDI input path, then translated to the same internal key, encoder, analog, or Master-parameter actions used by the panel.
- Added CC/note handling for encoder increments, button press/release, pad pressure/release, faders, pitch/mod wheels, and the FM-1 Master parameter.
- Learned assignments are saved in the plugin's project state.
- Added a unit test for target-slot coverage and explicit SMK keyboard exclusion.
- These are committed source changes; compilation and live controller tests are still pending.

### Follow-up source review
- **Core warning correction:** removed the redundant write to `synced` from the `sync!` macro. In the reported warning paths, the macro call returns immediately or is followed by the careful-operation path that sets `synced` again; the macro's write was therefore overwritten before it could be read. The macro still accounts for the uncommitted instruction count using the previous `synced` value.
- Rechecked the previously removed `blk`, `load` and `store_r` helpers: they have no remaining method call sites in the current source. Kept `sext`, which does have decoder call sites.
- Confirmed that the GDB stub crate is explicitly a placeholder and its current source does not use `fm1-core`; removing that unused manifest dependency is consistent with the current implementation.

**Verification:** the core source correction is committed, but a fresh `cargo build` and the core test suite have not yet been run on this commit. The full MIDI Learn implementation remains incomplete.


### Fork identity and MIDI Learn editor
- Changed the host-facing plugin name to **FM-1 MIDI Learn Fork** and vendor to **Vitriol131 Community Fork**.
- Added a visible **FM-1 MIDI LEARN FORK** banner and an assignment counter to the editor.
- Added a collapsible MIDI assignments list showing each learned panel slot and its MIDI CC or note source.
- Made the Learn button explicitly switch between OFF, click-a-control, and waiting-for-CC/note states. The help text explains the sequence.
- Assigned unique CLAP, AU and VST3 bundle identifiers, AU manufacturer/subtype codes, and bundle filenames so this fork can coexist with upstream instead of replacing it.
- Updated macOS and Windows build/install scripts for the fork's distinct bundle names.
- Expanded the root and plugin READMEs with the upstream comparison, intended control coverage, Ableton Live 12 setup, MIDI Learn workflow, risk disclosure and a test checklist.

**Verification:** changes committed to `midi-learn`. The previous build's AU validation does not apply to these new commits. A fresh build, AU/VST3 validation, and hands-on MIDI controller tests in Ableton Live 12 are still required. MIDI Learn remains experimental until those tests pass.
