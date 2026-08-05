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

No gameplay was implemented in TASK-001 or TASK-002.