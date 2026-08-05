# TASK-004 — Viewmodel System

Status: Approved

Milestone: First Playable

Priority: Critical

Depends On:

- TASK-001 — Project Foundation
- TASK-002 — Framework Bootstrap
- TASK-003 — First-Person Camera Foundation

---

# Objective

Create a reusable first-person viewmodel system for Project Canvas.

The system must display a temporary set of first-person arms and a placeholder paintball marker while the player is in active first-person gameplay.

This task establishes the visual weapon-holding foundation only.

No firing, damage, ammunition, reload logic, inventory, or gameplay weapon behavior should be implemented.

---

# Gameplay Purpose

The player should visibly hold a paintball marker in first person.

The viewmodel should make Project Canvas begin to feel like an actual first-person paintball game while remaining temporary and easy to replace with final assets later.

The system must eventually support:

- Multiple marker families
- Sniper markers
- Brushes
- Spray cans
- Weapon inspections
- Equip animations
- Reload animations
- Fire animations
- Sprint animations
- Cosmetic models
- Weapon-specific offsets

Only the foundational display system is included in TASK-004.

---

# Technical Purpose

Create a focused `ViewmodelController` responsible for:

- Creating or cloning a local-only viewmodel
- Parenting the viewmodel to the current camera
- Equipping one configured placeholder marker
- Updating the viewmodel transform relative to the camera
- Handling camera replacement
- Handling character spawn and respawn
- Cleaning up duplicate viewmodels
- Providing a clean extension point for future animation and weapon systems

The controller must not own:

- Weapon firing
- Damage
- Ammunition
- Reload state
- Inventory
- Player movement
- Camera look behavior
- Match state
- Cosmetics ownership

---

# Design Rules

## Local-Only Presentation

The viewmodel is visual presentation only.

Requirements:

- It must exist only on the local client
- It must not be treated as a server-authoritative weapon
- It must not damage players
- It must not be replicated as the player's real equipped gameplay object
- Other players do not need to see it
- Future third-person weapon presentation will be handled separately

## Temporary Assets

Use placeholder assets only.

Acceptable placeholders include:

- Simple block arms
- A simple block-based marker
- A temporary model built from Parts
- A clearly labeled developer placeholder model

Do not use untrusted free models containing scripts.

Do not spend time creating final marker art, textures, sounds, or animations.

## Weapon-Agnostic Architecture

The controller must not permanently assume one specific marker.

It should accept or resolve a viewmodel definition using an identifier such as:

```text
default_semi_auto
```

The initial implementation may support only one identifier, but replacing or adding future models should not require rewriting the controller.

---

# Bootstrap Integration

Register `ViewmodelController` in the approved client controller registry.

After TASK-004, the approved client registry should load:

1. `CameraController`
2. `ViewmodelController`

Initialization order must be deterministic.

`ViewmodelController` must support:

- `Init()`
- `Start()`
- `Destroy()` when applicable

It must not self-start outside the bootstrap framework.

---

# Camera Integration

The viewmodel must be parented to `Workspace.CurrentCamera`.

Requirements:

- Follow the camera smoothly
- Rebind if `CurrentCamera` changes
- Avoid duplicate viewmodels after camera replacement
- Avoid visible frame delay or severe jitter
- Not overwrite the camera's `CFrame`
- Not interfere with `CameraController`

The viewmodel should update during an appropriate render step so it visually tracks the camera.

---

# Viewmodel Structure

Use a clear, reusable model structure.

Expected conceptual hierarchy:

```text
Viewmodel
├── Root
├── LeftArm
├── RightArm
└── Marker
```

Exact names may vary if Claude explains the reason.

Requirements:

- A designated root part
- All parts connected or transformed consistently
- Parts must be non-collidable
- Parts must be massless where appropriate
- Parts must not query or touch the world unnecessarily
- Parts should not cast unwanted shadows where practical
- The viewmodel should not interfere with raycasts or character physics
- The model must be clearly distinguishable from the player's real character

---

# Viewmodel Creation

Claude must choose one of these approaches and explain the choice:

## Option A — Runtime Placeholder Construction

Create the temporary arms and marker locally from Parts through code.

Advantages:

- No manual Studio asset setup
- Easy to keep in source control
- Safe from free-model scripts

## Option B — ReplicatedStorage Template

Create or expect a clean template model under a dedicated location such as:

```text
ReplicatedStorage
└── Assets
    └── Viewmodels
        └── DefaultSemiAuto
```

Advantages:

- Easier for future artists and animators to replace
- Closer to the eventual production asset pipeline

For TASK-004, prefer the simplest reliable approach that preserves a clean migration path to final assets.

Do not create both systems unnecessarily.

---

# Configuration

Create or update a `ViewmodelConfig` module.

Required configurable fields:

- Enabled
- DefaultViewmodelId
- BasePositionOffset
- BaseRotationOffset
- RenderPriority
- HideWhenNotFirstPerson
- CastShadow
- PlaceholderSwayEnabled
- PlaceholderBobEnabled

Only these must actively affect TASK-004 behavior:

- Enabled
- DefaultViewmodelId
- BasePositionOffset
- BaseRotationOffset
- RenderPriority
- HideWhenNotFirstPerson
- CastShadow

Sway and bob fields are placeholders only.

Do not implement final sway or bob during this task.

Avoid unexplained magic numbers inside `ViewmodelController`.

---

# Viewmodel Definitions

Create a shared definition structure for available viewmodels.

A definition should be able to describe:

- Viewmodel ID
- Display name
- Weapon family placeholder
- Construction/template method
- Root part name
- Position offset override
- Rotation offset override
- Future animation-set identifier placeholder

Only one definition is required now.

Example conceptual identifier:

```text
default_semi_auto
```

Do not add rarity, skins, cases, ownership, damage, or weapon statistics.

---

# Visibility Behavior

The viewmodel should be visible only when appropriate.

For the current First Playable state:

- Show it while first-person gameplay is active
- Hide or destroy it when first-person mode is not active
- Handle character removal
- Handle player reset
- Handle camera replacement
- Avoid creating more than one active viewmodel

The lobby camera decision is now documented:

- Lobby allows normal Roblox camera behavior
- Active matches force first-person

However, TASK-004 does not implement lobby/match state.

For now, use the existing first-person camera state as the visibility condition while preserving a future path for explicit match-state control.

---

# Arms and Marker Presentation

The temporary arms and marker should:

- Be visible from the player's first-person camera
- Not block the center of the screen excessively
- Sit in a neutral paintball-ready pose
- Remain readable at the current placeholder FOV
- Use simple neutral placeholder materials
- Avoid final branding
- Avoid copied real-world branding
- Avoid final cosmetic identity decisions

No final animation quality is expected.

---

# Animation Preparation

Prepare the architecture for future animation support.

Future animation states include:

- Idle
- Equip
- Fire
- Reload
- Inspect
- Sprint
- Melee
- Weapon switch

TASK-004 should provide an obvious place for an `Animator`, `AnimationController`, or future animation loader if appropriate.

Do not create final animations.

Do not add fake animation IDs.

Do not hardcode asset IDs.

---

# Cleanup and Lifecycle

The controller must correctly handle:

- Initial player load
- Character spawn
- Character reset
- Character respawn
- Character removal
- CurrentCamera replacement
- Controller destruction
- Repeated initialization protection

Cleanup requirements:

- Disconnect render-step binding
- Disconnect event connections
- Destroy the local viewmodel
- Clear references
- Prevent duplicate active viewmodels
- Restore no global state unnecessarily

---

# Logging

Use the existing `Logger`.

Log:

- Controller initialization
- Controller startup
- Viewmodel creation
- Viewmodel destruction
- Camera rebinding
- Recoverable asset/definition failures

Do not:

- Log every frame
- Use raw `print()`
- Spam Output during normal camera movement

---

# Expected Files

Claude may adjust exact file names to match the existing architecture, but the implementation should include equivalents of:

```text
src/client/Controllers/ViewmodelController.luau
src/shared/Config/ViewmodelConfig.luau
src/shared/Weapons/ViewmodelDefinitions.luau
src/client/Bootstrap.client.luau
CHANGELOG.md
```

Focused helper modules are allowed only when they clearly reduce complexity.

Remove obsolete placeholder modules from any folder that now contains a real implementation.

---

# Acceptance Criteria

- `ViewmodelController` is registered through the approved controller registry
- Controller initialization order is deterministic
- Client bootstrap reports `2/2 controller(s) loaded`
- A temporary first-person viewmodel appears
- The viewmodel contains visible arms and one placeholder marker
- The viewmodel is local-only
- The viewmodel follows the camera smoothly
- The viewmodel does not overwrite camera behavior
- The viewmodel does not collide with the world
- The viewmodel does not affect player physics
- The viewmodel does not interfere with gameplay raycasts where practical
- Base position comes from configuration
- Base rotation comes from configuration
- The default viewmodel ID comes from configuration
- Replacing `CurrentCamera` rebinds the viewmodel correctly
- Resetting and respawning do not create duplicate viewmodels
- Only one local viewmodel exists at a time
- Cleanup destroys the viewmodel and disconnects update bindings
- No firing is implemented
- No damage is implemented
- No ammunition is implemented
- No reload logic is implemented
- No weapon switching is implemented
- No final animations are added
- `rojo build` succeeds
- Roblox Studio Output contains no unexpected errors

---

# Out of Scope

Do not implement:

- Weapon firing
- Damage
- Hit detection
- Ammunition
- Reload logic
- Weapon switching
- Inventory
- Third-person weapon replication
- Final marker models
- Final arm models
- Final materials
- Final textures
- Final animations
- Animation asset IDs
- Weapon inspections
- Weapon sway polish
- Walk bob polish
- Sprint transitions
- Recoil
- ADS
- Crosshair UI
- Cosmetic skins
- Cases
- Trading
- Rarity
- Ownership
- Paint splatter
- Sound effects
- Movement mechanics
- Crouch
- Slide
- Mantle
- Match-state system

---

# Future Expansion Notes

The viewmodel system should later support:

- Weapon-family-specific models
- Weapon-specific offsets
- Animation-set identifiers
- Left- and right-handed presentation if approved
- Inspect animation variants
- Skin-specific model components
- Marker attachments
- Sniper viewmodels
- Brush viewmodels
- Spray-can viewmodels
- Match-state-driven visibility
- Spectator-safe behavior
- Final Play presentation rules

The future weapon system should tell the viewmodel system what to display.

The viewmodel system should not become the source of truth for:

- Damage
- Ammunition
- Ownership
- Equipped server weapon state
- Currency
- Inventory

---

# Testing Checklist

## Build Test

- Run `rojo build default.project.json`
- Confirm build succeeds
- Confirm no unexpected generated files are tracked

## Basic Viewmodel Test

- Start a single-player Studio test
- Confirm client bootstrap loads `2/2 controller(s)`
- Confirm placeholder arms appear
- Confirm placeholder marker appears
- Confirm viewmodel follows camera rotation
- Confirm viewmodel remains stable while walking and jumping
- Confirm it does not visibly lag behind the camera

## Collision and Physics Test

- Walk directly into walls
- Stand close to cover
- Jump against geometry
- Confirm viewmodel does not physically collide
- Confirm viewmodel does not push the player
- Confirm no viewmodel parts fall into Workspace

## Respawn Test

- Reset the character at least three times
- Confirm exactly one viewmodel appears after every respawn
- Confirm old viewmodels are destroyed
- Confirm no duplicate render bindings
- Confirm no error or log spam accumulates

## Camera Replacement Test

- Confirm the viewmodel reparents or rebuilds when `CurrentCamera` changes
- Confirm no orphaned viewmodel remains under an old camera

## Multiplayer Test

- Start at least two Studio players
- Confirm each player sees only their own viewmodel
- Confirm players do not see another player's local viewmodel
- Confirm the other player's normal character remains visible

## Scope Test

- Confirm clicking does not fire
- Confirm no damage occurs
- Confirm no ammunition UI or reload behavior exists
- Confirm no movement feature was added

## Output Test

- Confirm no red errors
- Confirm no repeated per-frame logs
- Confirm startup logs identify `ViewmodelController`
- Confirm bootstrap reports `2/2 controller(s) loaded`

---

# Required Deliverables

Claude must provide:

- Summary
- Files created
- Files modified
- Files deleted
- Viewmodel architecture overview
- Placeholder construction/template approach explanation
- Bootstrap registration explanation
- Camera-follow explanation
- Configuration explanation
- Cleanup and respawn explanation
- Manual Roblox Studio steps
- Testing instructions
- Known limitations
- Security considerations
- Suggested next task

---

# Suggested Commit Message

```text
feat: add first-person viewmodel system
```

---

# Review Checklist

- Is `ViewmodelController` loaded only through the bootstrap?
- Is the viewmodel local-only?
- Is the controller weapon-agnostic?
- Are offsets configuration-driven?
- Is only one viewmodel active?
- Does cleanup handle respawn and camera replacement?
- Does it avoid modifying the camera's `CFrame`?
- Does it avoid gameplay authority?
- Did Claude avoid firing, damage, ammunition, reload, inventory, and movement scope?
- Does Studio show `2/2 controller(s) loaded` without errors?