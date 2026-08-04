# Changelog

## [Unreleased]

### Added — 2026-08-04

- Project technical foundation (TASK-001): `src/client`, `src/server`,
  `src/shared` architecture with Service/Controller folders, shared
  Config modules (Round/Weapon/Player/Camera/Crosshair), shared Type
  definitions (Weapon/Player/Round/Combat/Network), a networking
  scaffold (`NetworkDefinitions`, `RemoteRegistry`, `NetworkUtils`) with
  no gameplay remotes registered, a `Logger` utility, and
  `default.project.json` for Rojo. No gameplay implemented.
- Moved misplaced root-level doc/task files into `docs/` and `tasks/`
  (`DECISIONS.md`, `CODING_STANDARD.md`, `ENGINEERING_PRINCIPLES.md`,
  `GIT_WORKFLOW.md`, `TASK-001_PROJECT_FOUNDATION.md`).
