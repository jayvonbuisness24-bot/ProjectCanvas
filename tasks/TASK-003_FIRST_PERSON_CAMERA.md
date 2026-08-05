# TASK-003 — First-Person Camera Foundation

Status: Approved

Milestone: First Playable

Priority: Critical

Depends On:

- TASK-001 — Project Foundation
- TASK-002 — Framework Bootstrap

---

# Objective

Create the foundational first-person camera system for Project Canvas.

The camera must feel responsive, stable, and configurable while remaining simple enough for the First Playable milestone.

This task should integrate with the existing Controller bootstrap framework and become the first real client controller registered by the project.

---

# Gameplay Purpose

The player must be able to enter the game and experience a clean first-person perspective suitable for a competitive paintball FPS.

The camera is the foundation for future:

- Viewmodels
- Weapon recoil
- ADS
- Leaning
- Spectating
- Final Play cinematics
- FOV customization
- Motion accessibility settings

---

# Technical Purpose

Create a focused `CameraController` that owns first-person camera behavior without taking responsibility for:

- Character movement
- Weapons
- Input systems unrelated to camera look
- Viewmodels
- Spectating
- UI

The controller must initialize and start through the existing ControllerLoader lifecycle.

---

# Requirements

## Bootstrap Integration

Register `CameraController` in the approved client controller registry.

The controller should support:

- `Init()`
- `Start()`
- `Destroy()` when applicable

It must not initialize itself outside the approved bootstrap system.

## Camera Mode

- Force first-person during active testing
- Lock the mouse to the center
- Use Roblox camera systems where practical instead of replacing everything unnecessarily
- Avoid fighting Roblox's camera every frame without a clear reason
- Recover cleanly when the current camera changes

## Field of View

- Read default FOV from `CameraConfig`
- Do not hardcode active FOV values inside the controller
- Preserve future support for:
  - ADS FOV
  - Sprint FOV
  - Spectator FOV
  - User-customized FOV

Only the default FOV should be active in TASK-003.

## Character Visibility

Locally hide or suppress only the character parts that obstruct first-person view.

Requirements:

- The player's head must not block the camera
- Accessories should not block the camera where practical
- Other players must still see the character normally
- Do not alter server-side transparency for camera-only behavior
- Restore local transparency state during cleanup when appropriate

## Respawn Handling

The controller must handle:

- Initial character spawn
- Character reset
- Respawn
- Character removal
- Camera replacement
- Temporary absence of `CurrentCamera`

It must not create duplicate connections or duplicate camera state after respawn.

## Stability

The camera should:

- Avoid visible jitter
- Avoid unwanted third-person zoom
- Avoid clipping inside the player's head
- Remain responsive during movement and jumping
- Not introduce artificial smoothing that makes aiming feel delayed

## Extensibility

Provide a clean internal structure for future camera layers such as:

1. Base look
2. Recoil offset
3. Camera shake
4. Lean offset
5. Head bob
6. Sprint FOV
7. Spectator override
8. Final Play cinematic override

Do not implement those systems yet.

## Configuration

Update or create `CameraConfig` fields for:

- Default FOV
- Minimum FOV placeholder
- Maximum FOV placeholder
- First-person enabled
- Mouse lock enabled
- Hide local head
- Hide local accessories
- Motion effects enabled placeholder

Only approved TASK-003 behavior should be active.

Placeholder values must be clearly labeled as non-final.

## Logging

Use the existing `Logger`.

Log:

- Controller initialization
- Controller startup
- Character binding
- Recoverable camera failures
- Cleanup failures

Do not spam logs every frame.

Do not use raw `print()`.

---

# Expected Files

Claude may adjust exact file names to match the current architecture, but the implementation should include equivalents of:

```text
src/client/Controllers/CameraController.luau
src/shared/Config/CameraConfig.luau
src/client/Bootstrap.client.luau