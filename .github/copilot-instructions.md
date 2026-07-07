# Copilot instructions — playos-tools

Developer tools for PlayOS: packaging, templates, build/deploy, diagnostics,
SDK tooling. Formats are defined in
[`playos-spec`](https://github.com/PlayOS-Foundation/playos-spec) (Part X +
`schemas/`). Also read `AGENTS.md`.

## Rules for changes here

1. **Spec-conformant artifacts** — emit `.gpk` per the spec; validate against
   `playos-spec/schemas/`.
2. **Engine-agnostic** — no assumption of Raylib or any single engine.
3. **Cross-platform** — Windows/macOS/Linux where practical.
4. **Spec first** — formats specified before tools depend on them.
5. **Deterministic & scriptable** — CI-friendly commands.
