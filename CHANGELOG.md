# Changelog

## [Unreleased]

### Added — 2026-08-04

- Project technical foundation for TASK-001:
  - Rojo project mapping
  - Client, server, and shared source architecture
  - Configuration scaffolding
  - Shared Luau type definitions
  - Networking scaffold
  - Logging utility
  - Repository path cleanup

- Framework bootstrap for TASK-002:
  - Shared lifecycle types
  - Shared module loader
  - Service loader
  - Controller loader
  - Server bootstrap entry point
  - Client bootstrap entry point
  - Explicit service and controller registration
  - Deterministic `Init()` and `Start()` lifecycle
  - Per-module startup error isolation and logging

- First-person camera foundation for TASK-003:
  - `CameraController`, the first Controller registered through the
    TASK-002 `ControllerLoader`
  - Forced first-person camera mode and center-locked mouse
  - Default field of view applied from `CameraConfig`, reapplied
    whenever `CurrentCamera` is replaced (e.g. on respawn)
  - Local-only hiding of the player's own head and accessories via
    `LocalTransparencyModifier` (server-authoritative `Transparency`
    untouched; other players see the character normally)
  - Clean bind/unbind across spawn, respawn, and character removal
  - `CameraConfig` extended with first-person, mouse-lock, and
    local-visibility toggles plus a motion-effects placeholder

No gameplay was implemented in TASK-001, TASK-002, or TASK-003.