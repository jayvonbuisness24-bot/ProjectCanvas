# TASK-005 — Semi-Auto Marker Prototype

Status: Approved

Milestone: First Playable

Priority: Critical

Depends On:

- TASK-001 — Project Foundation
- TASK-002 — Framework Bootstrap
- TASK-003 — First-Person Camera Foundation
- TASK-004 — Viewmodel System

---

# Objective

Create the first playable semi-automatic paintball marker.

This task establishes the complete client/server firing pipeline while intentionally remaining minimal.

The player should be able to click, fire a paintball ray, receive immediate visual feedback, and obey a configurable fire rate.

No damage, eliminations, scoring, teams, rounds, paint splatter, or networking optimizations should be implemented.

---

# Gameplay Purpose

Allow the player to fire a believable semi-auto paintball marker.

This becomes the foundation for every future weapon.

---

# Technical Purpose

Build a weapon architecture that separates:

- Input
- Weapon presentation
- Client prediction
- Server validation
- Hit reporting

without implementing gameplay consequences.

---

# Requirements

## Bootstrap Integration

Register the required systems through the existing framework.

Do not bypass ControllerLoader or ServiceLoader.

---

## Input

Left mouse button fires once.

Holding the mouse button must respect the configured fire rate.

No burst.

No full auto.

No alternate fire.

---

## Weapon Configuration

Create a shared configuration module containing:

- WeaponId
- FireRate
- MaximumRange
- PaintballSpeed placeholder
- Automatic (false)
- MarkerName

No damage.

No reload.

No ammunition.

---

## Networking

Create one RemoteEvent.

Client requests:

FireWeapon

Server validates:

- Fire rate
- Basic payload
- Player existence

Server returns no damage.

---

## Raycasting

Use server-authoritative raycasts.

Requirements:

- Ignore the shooter's character
- Ignore the local viewmodel
- Respect collision filtering
- Configurable range

---

## Visual Feedback

Provide placeholder effects only.

Allowed:

- Muzzle flash placeholder
- Tiny beam/tracer placeholder
- Debug hit marker
- Debug impact part

No particles.

No sounds.

No decals.

---

## Fire Rate

Must come from configuration.

No magic numbers.

Semi-auto only.

---

## Viewmodel Integration

Trigger a placeholder fire animation hook.

Do not create animations.

Provide only an obvious extension point.

---

## Logging

Log:

- weapon initialized
- weapon fired
- invalid fire requests
- server validation failures

Do not spam Output.

---

# Expected Files

src/client/Controllers/WeaponController.luau

src/server/Services/WeaponService.luau

src/shared/Weapons/WeaponDefinitions.luau

src/shared/Config/WeaponConfig.luau

src/shared/Network/NetworkDefinitions.luau

CHANGELOG.md

---

# Acceptance Criteria

- WeaponController loads through bootstrap.
- WeaponService loads through bootstrap.
- Bootstrap reports all controllers/services loaded.
- Left click fires.
- Fire rate obeys config.
- Raycast originates correctly.
- Viewmodel remains visible.
- No duplicate requests.
- No damage exists.
- No reload exists.
- No ammo exists.
- rojo build succeeds.
- Studio shows no errors.

---

# Out of Scope

Damage

Health

Teams

Rounds

Hitmarkers

Killfeed

Ammo

Reload

ADS

Weapon switching

Weapon inventory

Weapon skins

Paint splatter

Sounds

Animations

Movement mechanics

Crosshair polish

Networking optimization

---

# Suggested Commit Message

feat: add semi-auto marker prototype