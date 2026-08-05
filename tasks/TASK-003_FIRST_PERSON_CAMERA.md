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
---

# Acceptance Criteria

- `CameraController` is registered through the approved controller registry
- Client bootstrap reports `1/1 controller(s) loaded`
- Player enters first person on spawn
- Mouse locks to center
- Camera FOV comes from `CameraConfig`
- Player head does not obstruct the view
- Accessories do not obstruct the view where practical
- Other players still see the full character normally
- Camera remains stable during walking and jumping
- Resetting the character restores correct first-person behavior
- Respawning does not create duplicate connections
- Camera recovers if `CurrentCamera` changes
- No viewmodel logic is added
- No weapon logic is added
- No movement system is added
- No spectating or Final Play logic is added
- `rojo build` succeeds
- Roblox Studio Output contains no unexpected errors

---

# Out of Scope

Do not implement:

- Viewmodels
- Weapon sway
- Weapon recoil
- ADS
- Leaning
- Head bob
- Camera shake
- Sprint FOV
- Spectating
- Final Play
- Kill cams
- Crosshair UI
- Full settings UI
- Mobile camera controls
- Controller aim assistance
- Custom character movement
- Weapon input
- Animations
- Audio

---

# Future Expansion Notes

The camera architecture should later support composed offsets instead of unrelated scripts directly overwriting `Camera.CFrame`.

Future systems should be able to contribute camera effects without becoming tightly coupled to the base controller.

Possible future API concepts:

- `SetBaseFov()`
- `AddCameraOffset()`
- `SetOverrideMode()`
- `SetMotionEffectsEnabled()`
- `BindCharacter()`
- `UnbindCharacter()`

These are examples only. Do not create speculative APIs unless they provide immediate architectural value.

---

# Testing Checklist

## Basic Test

- Run `rojo build default.project.json`
- Start a single-player Studio test
- Confirm client bootstrap loads `1/1 controller`
- Confirm first-person activates
- Confirm mouse lock works
- Confirm FOV matches `CameraConfig`

## Character Test

- Walk
- Jump
- Rotate rapidly
- Look straight up and down
- Walk into walls
- Reset the character
- Respawn
- Confirm head and accessories do not block the camera
- Confirm no duplicate behavior after multiple resets

## Multiplayer Test

- Start at least two players in Studio
- Confirm each player sees their own first-person view
- Confirm each player still sees the other player's full character
- Confirm local transparency changes do not replicate

## Recovery Test

- Confirm controller handles a temporarily missing character
- Confirm controller handles `CurrentCamera` replacement
- Confirm cleanup does not leave stale event connections

## Output Test

- Confirm no red errors
- Confirm no repeated per-frame log spam
- Confirm startup logs identify `CameraController`

---

# Required Deliverables

Claude must provide:

- Summary
- Files created
- Files modified
- Camera architecture overview
- Bootstrap registration explanation
- Character visibility explanation
- Respawn and cleanup explanation
- Manual Roblox Studio steps
- Testing instructions
- Known limitations
- Security considerations
- Suggested next task

---

# Suggested Commit Message

```text
feat: add first-person camera foundation