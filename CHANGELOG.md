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

- First-person viewmodel system for TASK-004:
  - `ViewmodelController`, the second Controller registered through the
    `ControllerLoader` (after `CameraController`, deterministic order)
  - Placeholder arms + marker built at runtime from Parts (Option A —
    no Studio asset pipeline exists yet), parented to
    `Workspace.CurrentCamera` and tracked every render step without
    ever writing to the camera's own `CFrame`
  - Weapon-agnostic: resolves a `ViewmodelDefinition` by id rather than
    hardcoding one marker
  - Clean rebind/cleanup across `CurrentCamera` replacement and
    character spawn/reset/respawn/removal — never more than one active
    viewmodel
  - New `ViewmodelConfig` (offsets, render priority, visibility/enable
    toggles, sway/bob placeholders) and `ViewmodelDefinitions` (shared
    definition registry) modules

- Semi-auto marker prototype for TASK-005:
  - `WeaponController`, the third Controller registered through the
    `ControllerLoader` (after `CameraController`/`ViewmodelController`)
  - `WeaponService`, the first Service registered through the
    `ServiceLoader`
  - New `FireWeapon` RemoteEvent (`NetworkDefinitions`); client sends
    origin/direction/weapon id/timestamp only, per CLAUDE.md's
    Networking Rules
  - Server-authoritative validation: payload shape, weapon id, an
    origin-vs-character sanity check, and a server-clock fire-rate gate
    (the client-supplied timestamp is never trusted for rate limiting)
  - Server-authoritative raycast, ignoring the shooter's own character
  - Purely cosmetic, local-only client feedback (muzzle flash and
    tracer placeholders) from an unrelated client-side predicted
    raycast — never used to decide a hit
  - New `WeaponDefinitions` (shared, weapon-agnostic registry) module;
    `WeaponConfig` extended with `WeaponId`, `FireRate`, `MaximumRange`,
    `PaintballSpeed` (placeholder), `Automatic` (false), `MarkerName`
  - New `CombatTypes.FireWeaponRequest` type
  - No damage, health, ammo, reload, weapon switching, or rounds

- Marker firing presentation pass for TASK-006:
  - Placeholder marker rebuilt as six parts (Body, Barrel, Grip,
    TriggerFrame, Hopper, Tank) instead of one block; arms repositioned
    so the right hand reads as holding the grip and the left hand as
    supporting the front
  - New `ViewmodelController.PlayFirePresentation()`: a small,
    self-contained fire kick (hand-rolled two-phase per-frame lerp, no
    `TweenService`/extra Instance) that always returns cleanly to rest
    and never accumulates; `WeaponController` requests it rather than
    `ViewmodelController` listening for input itself
  - New `client/Weapons/ShotEffects` module: muzzle flash and tracer
    (immediate, client-predicted) plus impact effect (spawned only from
    the server-confirmed position, distinguishing a real surface hit
    from an empty-space range termination)
  - `FireWeapon` RemoteEvent reused bidirectionally: the server now
    replies with a `CombatTypes.FireConfirmation`
    (`RequestId`/`Hit`/`Position`/`Normal`) after validating and
    raycasting — no damage/health/elimination data, ever
  - Rapid-fire rejection logging reworked: ordinary fire-rate rejections
    are now silent by default (`Logger.Debug`) instead of one `Warn`
    per click; sustained abnormal rejection rates still produce a
    single throttled `Warn`, reusing the existing
    `NetworkUtils.CreateRateLimiter` rather than new bespoke tracking.
    The rejection logic itself is unchanged — only its logging.
  - `ViewmodelConfig` extended with kick tuning
    (`KickPosition`/`KickRotation`/`KickInDuration`/`KickReturnDuration`)
    and inert `CameraKickEnabled`/`CameraKickAmount` placeholders (no
    `CameraController` extension point exists yet — documented
    limitation, `CameraController` was not modified)
  - `WeaponConfig` extended with `PaintColor` and shot/impact/muzzle
    presentation tuning, plus `RejectedRequestWarningThreshold`/
    `RejectedRequestWindowSeconds`/`RejectedRequestWarningCooldown`
  - New `CombatTypes.FireConfirmation` type
  - Still no damage, health, eliminations, ammo, reload, weapon
    switching, or rounds

No gameplay consequences (damage, elimination, scoring) were implemented
in TASK-001 through TASK-006.