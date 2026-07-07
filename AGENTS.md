# AGENTS.md — playos-tools

Guidance for AI agents and contributors working in this repository.

## What this repository is

Developer tools for PlayOS: packaging, project templates, build utilities,
deployment, diagnostics, and SDK tooling. Tool behavior that affects platform
artifacts (e.g. the `.gpk` package format) is specified in `playos-spec`; this
repository implements the tooling.

## Golden rules

1. **Produce spec-conformant artifacts.** Packaging tools emit `.gpk` packages
   exactly as defined in `playos-spec` (Part X). Validate against the schemas
   in `playos-spec/schemas/`.
2. **Engine-agnostic.** Tooling must not assume Raylib or any single engine.
3. **Cross-platform.** Tools run on Windows, macOS, and Linux where practical.
4. **Spec first.** Formats and manifests are specified before tools rely on
   them.
5. **Deterministic & scriptable.** Prefer reproducible, CI-friendly commands.

## Where things go

- CLIs, templates, and build/deploy helpers live here.
- Package/manifest/schema definitions live in `playos-spec`.
