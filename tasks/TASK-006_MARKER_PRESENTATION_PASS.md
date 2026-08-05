# TASK-006 — Marker Presentation Pass

Status: Approved

Milestone: First Playable

Priority: High

Depends On:

- TASK-001 — Project Foundation
- TASK-002 — Framework Bootstrap
- TASK-003 — First-Person Camera Foundation
- TASK-004 — Viewmodel System
- TASK-005 — Semi-Auto Marker Prototype

---

# Objective

Improve the temporary marker presentation so Project Canvas no longer looks like a raw debug shooter.

TASK-005 successfully proved the firing pipeline:

- Client input works
- Server fire-rate validation works
- Server raycasts work
- Invalid rapid-fire requests are rejected
- The viewmodel remains active while firing

TASK-006 should improve only the visual and responsive feel of firing.

Do not add damage, eliminations, ammunition, reloading, inventory, final assets, or new weapon families.

---

# Gameplay Purpose

The player should receive clear, responsive feedback whenever the semi-auto marker fires.

The marker should feel like a temporary paintball weapon prototype rather than a static collection of blocks.

The player should be able to:

- Click once
- See the marker react immediately
- See a brief paintball-style shot visualization
- See a temporary impact effect
- Feel a small amount of controlled firing feedback

The presentation should remain intentionally temporary and easy to replace later.

---

# Technical Purpose

Add a focused presentation layer on top of the existing TASK-005 firing pipeline.

The client should handle immediate local visual feedback.

The server should remain authoritative for:

- Fire-rate validation
- Shot validation
- Raycast results
- Confirmed impact position

The presentation layer must not become responsible for:

- Damage
- Health
- Eliminations
- Ammunition
- Reload state
- Weapon ownership
- Server weapon state

---

# Design Direction

The current prototype reportedly resembles an early 1990s shooter because:

- The marker is built from plain rectangular Parts
- The arms use a rigid neutral pose
- The marker does not visually react to firing
- The tracer or debug shot lacks paintball identity
- The impact response looks like debug visualization

TASK-006 should improve these areas without pretending to be final art.

The result should feel:

- Responsive
- Clean
- Readable
- Temporary
- Paintball-inspired
- Modern enough for continued testing

Do not attempt final AAA polish during this task.

---

# Viewmodel Improvements

Improve the runtime placeholder marker proportions.

The temporary marker should visually suggest:

- A main marker body
- A barrel
- A grip
- A trigger-frame area
- A hopper or paint-feed placeholder
- A compressed-air tank placeholder where practical

The model may remain block-based.

Requirements:

- Use simple Parts only
- No untrusted models
- No external marketplace dependencies
- No real-world logos
- No copied commercial marker branding
- No final textures
- No final cosmetic identity
- Maintain local-only behavior
- Maintain `CanCollide = false`
- Maintain `CanTouch = false`
- Maintain `CanQuery = false`
- Maintain anchored or otherwise controlled viewmodel behavior

The temporary marker should be visually more recognizable as a paintball marker.

---

# Arm Pose Improvements

Improve the placeholder arm positioning.

Requirements:

- The right arm should appear to hold the grip
- The left arm should appear to support the front of the marker
- Arms should not block the crosshair area
- Arms should not fill too much of the screen
- The pose should remain readable at the current placeholder FOV
- Arm offsets must remain configuration-driven where practical

Do not create final character meshes or final animations.

---

# Fire Presentation

## Immediate Local Response

When the player submits a valid local semi-auto fire input, immediately trigger temporary local presentation.

Allowed feedback:

- Small viewmodel kick
- Brief marker backward movement
- Brief upward rotation
- Very small camera kick if implemented through an approved extension point
- Temporary muzzle flash
- Temporary barrel glow
- Temporary shot trail

The local presentation should happen immediately so firing feels responsive.

Server confirmation must still decide the confirmed shot result.

## Fire Kick

Create a lightweight procedural firing kick.

Requirements:

- Small and controlled
- Quick return to the resting pose
- Does not permanently alter the base viewmodel offset
- Does not create large camera movement
- Does not interfere with player aim
- Does not accumulate indefinitely
- Remains configurable

Suggested configuration fields:

- KickPosition
- KickRotation
- KickInDuration
- KickReturnDuration
- CameraKickEnabled
- CameraKickAmount

Only modest placeholder values should be active.

## Camera Feedback

Camera kick is optional for TASK-006.

If implemented:

- Use the camera architecture’s approved extension path
- Do not directly fight Roblox’s camera every frame
- Keep the effect extremely small
- Do not create artificial smoothing or aim delay
- Ensure repeated shots do not permanently offset the camera
- Respect future motion-reduction settings

If no clean camera extension point exists, implement viewmodel kick only and document the limitation.

Do not rewrite `CameraController` merely to force camera recoil into this task.

---

# Paintball Shot Visualization

Create a temporary paintball-style shot visualization.

Claude must choose and explain one temporary presentation approach:

## Option A — Fast Visual Tracer

A short-lived visual line or narrow part between the muzzle and the confirmed endpoint.

Advantages:

- Simple
- Responsive
- Lightweight
- Easy to replace later

## Option B — Cosmetic Paintball Projectile

A small client-side sphere visually travels from the muzzle toward the endpoint.

Advantages:

- More clearly communicates paintball travel
- Helps distinguish Project Canvas from a conventional hitscan shooter

The cosmetic projectile must not determine hits.

The server raycast remains authoritative.

For TASK-006, prefer the simplest solution that noticeably improves the current presentation.

---

# Muzzle Presentation

Add a brief temporary muzzle effect.

Allowed approaches:

- Small colored sphere
- Briefly visible Part
- Simple Beam
- Temporary PointLight
- Temporary particle placeholder created entirely in code

Requirements:

- Very short lifetime
- No permanent instances left behind
- No imported asset dependency required
- Does not obscure the player’s view
- Does not spam the Workspace or camera
- Uses cleanup through `Debris` or explicit destruction

Do not add final particles or final muzzle art.

---

# Impact Presentation

When the server confirms the raycast endpoint, show a temporary impact effect.

Requirements:

- Spawn at the confirmed server impact position
- Clearly distinguish wall impact from empty-space range termination where practical
- Use a simple paint-colored temporary visual
- Remain short-lived
- Do not apply damage
- Do not create permanent decals
- Do not create final paint splatter
- Do not create gameplay collision
- Do not accumulate indefinitely

Allowed temporary effects:

- Small neon or smooth-plastic sphere
- Brief expanding ring
- Small flat paint-colored disk
- Short-lived impact puff
- Temporary debug mark with improved presentation

The effect is presentation only.

---

# Paint Color

Use one temporary paint color for the First Playable marker.

The paint color must come from configuration.

Do not implement:

- Player-selected paint colors
- Team paint colors
- Cosmetic paint colors
- Splatter rarity
- RNG splatter effects
- Paint ownership

Suggested placeholder:

```text
Bright blue or another clearly visible development color
```

The exact value is not final.

---

# Server Confirmation Flow

Preserve the TASK-005 authoritative pipeline.

Expected flow:

```text
Player clicks
↓
Client validates local readiness
↓
Client plays immediate marker kick/muzzle presentation
↓
Client sends FireWeapon request
↓
Server validates weapon and fire rate
↓
Server raycasts
↓
Server returns confirmed endpoint/result
↓
Client displays confirmed tracer endpoint and impact effect
```

The client must not invent a confirmed target.

The client may predict cosmetics, but confirmed impact placement should use server-returned information.

---

# Rapid-Fire Rejection Logging

TASK-005 currently reports attempts that exceed the configured fire rate.

Adjust logging behavior so ordinary fast clicking does not flood Output.

Requirements:

- The server must continue rejecting requests above the approved fire rate
- Normal rejected clicks should be silent or Debug-level
- Repeated abnormal request rates should produce a throttled warning
- Do not emit one warning for every rejected request
- Preserve useful exploit diagnostics
- Do not weaken server validation

Suggested behavior:

- Count rejected requests within a short time window
- Warn only after an abuse threshold is exceeded
- Throttle repeated warnings per player

Exact thresholds must come from configuration or clearly named constants.

---

# Configuration

Create or update configuration for presentation values.

Expected fields may include:

```text
PaintColor
TracerEnabled
TracerDuration
TracerThickness
CosmeticProjectileEnabled
CosmeticProjectileSpeed
ImpactEffectEnabled
ImpactDuration
MuzzleEffectEnabled
MuzzleDuration
KickPosition
KickRotation
KickInDuration
KickReturnDuration
CameraKickEnabled
CameraKickAmount
RejectedRequestWarningThreshold
RejectedRequestWarningCooldown
```

Do not create duplicate configuration modules if the current weapon/viewmodel configuration can hold these values cleanly.

Avoid magic numbers in controller/service code.

Clearly label all presentation values as temporary and non-final.

---

# Viewmodel Controller Integration

The presentation pass may extend `ViewmodelController` with a small public method such as:

```text
PlayFirePresentation()
```

or an equivalent focused API.

Requirements:

- Preserve existing viewmodel creation and cleanup behavior
- Do not move firing authority into `ViewmodelController`
- Do not tightly couple `ViewmodelController` to server networking
- Keep the public API narrow
- Avoid exposing internal Parts unnecessarily
- Ensure fire presentation does not break respawn behavior

`WeaponController` should request presentation from the viewmodel system.

The viewmodel system should not listen directly for weapon input.

---

# Networking

Reuse TASK-005 networking where practical.

A server-to-client response may be added or extended to include:

- Accepted/rejected status
- Confirmed endpoint
- Whether an instance was hit
- Surface normal where useful
- Optional temporary impact classification

Do not send:

- Damage
- Elimination data
- Health changes
- Client-selected target confirmation

Payloads must remain typed and validated.

---

# Cleanup

All temporary visual effects must be cleaned up.

Requirements:

- No permanent tracer Parts
- No permanent impact Parts
- No duplicate muzzle effects
- No accumulating Tweens
- No stale render-step connections
- No presentation continuing after respawn
- No orphaned effects under an old camera
- No errors if the viewmodel disappears during a shot

Use:

- `Debris`
- Explicit destruction
- Lifecycle-owned connection cleanup

as appropriate.

---

# Logging

Use the existing `Logger`.

Allowed logs:

- Presentation system initialized
- Recoverable missing-viewmodel condition
- Missing definition/config warning
- Throttled abnormal fire-request warning

Do not log:

- Every visual shot
- Every normal rejected rapid click
- Every frame
- Every Tween

Do not use raw `print()`.

---

# Expected Files

Claude may adjust exact names to match the existing implementation, but TASK-006 should include equivalents of:

```text
src/client/Controllers/ViewmodelController.luau
src/client/Controllers/WeaponController.luau
src/server/Services/WeaponService.luau
src/shared/Config/ViewmodelConfig.luau
src/shared/Config/WeaponConfig.luau
src/shared/Types/CombatTypes.luau
src/shared/Network/NetworkDefinitions.luau
CHANGELOG.md
```

Focused helper modules are allowed if they clearly reduce complexity.

Possible helper examples:

```text
src/client/Viewmodels/ViewmodelEffects.luau
src/client/Weapons/ShotEffects.luau
```

Do not add helpers solely to inflate architecture.

---

# Acceptance Criteria

- Existing TASK-005 firing pipeline still functions
- Fire-rate validation remains server-authoritative
- Ordinary excessive clicking no longer floods Output
- Abnormal request spam still produces throttled diagnostics
- Placeholder marker is more recognizable as a paintball marker
- Right hand visually aligns with the grip
- Left hand visually supports the marker
- Viewmodel no longer looks like a completely flat early-shooter sprite/block
- One click produces immediate local fire feedback
- Viewmodel kicks and returns cleanly
- Kick does not permanently accumulate
- Temporary muzzle feedback appears
- Temporary shot visualization appears
- Server-confirmed endpoint drives final impact placement
- Temporary impact feedback appears
- Visual effects clean themselves up
- Resetting and respawning do not duplicate effects
- Camera behavior remains stable
- No damage is implemented
- No health changes are implemented
- No eliminations are implemented
- No ammo is implemented
- No reload is implemented
- No final animation assets are added
- No final sound assets are added
- No final paint splatter system is added
- `rojo build` succeeds
- Roblox Studio Output contains no unexpected errors

---

# Out of Scope

Do not implement:

- Damage
- Health
- Eliminations
- Respawn-on-hit
- Teams
- Friendly fire
- Rounds
- Scoring
- Killfeed
- Hitmarkers
- Damage numbers
- Ammunition
- Reloading
- Weapon switching
- Inventory
- ADS
- Sniper scopes
- Final recoil system
- Final camera shake
- Final weapon models
- Final arm models
- Final animations
- Animation asset IDs
- Final audio
- Final particle effects
- Permanent paint decals
- Paint splatter gameplay
- Team paint colors
- Cosmetic paint colors
- Cases
- Trading
- Progression
- Movement mechanics
- Crouch
- Slide
- Mantle
- Test arena

---

# Future Expansion Notes

This temporary presentation layer should later be replaceable by:

- Final marker models
- Final arm rigs
- Animation-driven fire recoil
- Weapon-family-specific effects
- Marker-specific sound sets
- Paintball projectile simulation
- Paint splatter identity
- Team paint colors
- Cosmetic marker finishes
- Accessibility-controlled camera motion
- Settings-controlled effect intensity

The server-authoritative firing and hit-validation architecture from TASK-005 should remain intact.

Visual upgrades must not weaken security.

---

# Testing Checklist

## Build Test

- Run `rojo build default.project.json`
- Confirm build succeeds
- Confirm no temporary `.rbxl` verification file is tracked

## Marker Appearance Test

- Start single-player Studio test
- Confirm marker resembles a temporary paintball marker
- Confirm barrel, grip, hopper/feed, and tank placeholders are readable
- Confirm arms sit in a believable support pose
- Confirm center-screen visibility remains clear

## Fire Feedback Test

- Click once
- Confirm immediate marker kick
- Confirm marker returns smoothly
- Confirm muzzle effect appears
- Confirm shot visualization appears
- Confirm impact effect appears at server-confirmed endpoint
- Confirm visual effects disappear after their configured lifetimes

## Rapid Input Test

- Click faster than the approved fire rate
- Confirm extra requests are rejected
- Confirm normal rapid clicking does not flood Output
- Deliberately spam at abnormal rates
- Confirm a throttled warning eventually appears
- Confirm warning does not print every request

## Stability Test

- Fire while walking
- Fire while jumping
- Fire while rotating rapidly
- Fire near walls
- Fire at long range
- Confirm no major jitter
- Confirm camera remains responsive
- Confirm viewmodel remains visible

## Respawn Test

- Reset at least three times
- Fire after every respawn
- Confirm exactly one viewmodel exists
- Confirm no duplicate effects
- Confirm no stale Tweens or errors remain

## Multiplayer Test

- Start at least two Studio players
- Confirm both players can fire
- Confirm each player sees their own local viewmodel presentation
- Confirm confirmed impacts correspond to server results
- Confirm no damage occurs
- Confirm no other player sees another player’s local first-person viewmodel

## Scope Test

- Confirm no damage
- Confirm no health reduction
- Confirm no elimination
- Confirm no ammo
- Confirm no reload
- Confirm no weapon switching
- Confirm no movement feature was added

## Output Test

- Confirm no red errors
- Confirm no per-frame logging
- Confirm normal firing does not spam Output
- Confirm abuse diagnostics are throttled

---

# Required Deliverables

Claude must provide:

- Summary
- Files created
- Files modified
- Files deleted
- Marker-model improvement explanation
- Arm-pose explanation
- Fire-presentation architecture
- Client-prediction explanation
- Server-confirmation explanation
- Rapid-fire logging changes
- Configuration explanation
- Cleanup explanation
- Manual Roblox Studio steps
- Testing instructions
- Known limitations
- Security considerations
- Suggested next task

---

# Suggested Commit Message

```text
feat: improve marker firing presentation
```

---

# Review Checklist

- Does the marker read as a temporary paintball marker?
- Do the arms appear to hold and support it?
- Is firing visibly responsive?
- Does the server remain authoritative?
- Does confirmed impact placement come from the server?
- Are all effects temporary and cleaned up?
- Does rapid legitimate clicking avoid warning spam?
- Are abnormal requests still diagnosable?
- Is the camera still stable?
- Did Claude avoid damage, ammo, reload, rounds, movement, and final-asset scope?
- Does Studio run without errors?
