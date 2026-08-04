# Meliorism Studios — Claude Instructions

## Project

**Project Name:** Project Canvas
**Studio:** Meliorism Studios
**Platform:** Roblox
**Language:** Luau
**Current Stage:** Pre-production / First Playable development

Project Canvas is a competitive, round-based paintball FPS focused on skill, fairness, player expression, fast pacing, and long-term maintainability.

---

# Your Role

You are the primary implementation engineer for Project Canvas.

Your responsibilities include:

* Reading the project documentation before implementing features
* Writing and editing Luau code
* Maintaining clear client, server, and shared architecture
* Fixing bugs across multiple files
* Refactoring systems when approved
* Producing testing instructions after each implementation
* Identifying conflicts, risks, missing requirements, and security problems
* Preserving the approved gameplay and creative direction

You are not responsible for changing approved design decisions without permission.

---

# Source of Truth

Before implementing any feature, read the relevant files in this order:

1. `CLAUDE.md`
2. `docs/CREATIVE_BIBLE.md`
3. `docs/GAME_DESIGN_DOCUMENT.md`
4. `docs/TECHNICAL_DESIGN_DOCUMENT.md`
5. `tasks/CURRENT_MILESTONE.md`
6. The specific task or RFC being implemented
7. `docs/DECISIONS.md`, if present
8. `CHANGELOG.md`

If two documents conflict, stop before coding and clearly identify the conflict.

Do not silently choose one interpretation.

---

# Core Design Pillars

Every implementation must support the following pillars.

## Skill First

Players win through:

* Aim
* Movement
* Positioning
* Teamwork
* Communication
* Decision-making

Never create gameplay advantages based on spending, cosmetic rarity, crate results, or account level.

## Fair Play

All players must have access to the equipment needed to compete.

The server must validate competitive gameplay.

## Fast Action

Avoid unnecessary delays, long transitions, and slow interfaces.

The approved Regroup phase is eight seconds.

## Identity

Systems should feel specifically designed for Project Canvas rather than copied without purpose from another game.

## Personality

Weapon families, animations, sounds, splatter behavior, and cosmetics should have distinct identities.

## Player Ownership

Players should have extensive control over:

* Crosshairs
* HUD layout
* UI size
* Camera settings
* Field of view
* Audio
* Voice preferences
* Controls
* Accessibility settings

Customization must not create competitive advantages.

---

# Approved Gameplay Direction

The current approved game direction includes:

* Competitive paintball FPS
* Roblox R6-style character direction
* 6v6 public matches
* One life per round
* First team to six round wins
* No buy phase
* No pre-round loadout phase before Round One
* Eight-second Regroup phase between rounds
* Loadout changes while eliminated or during Regroup
* Two equipped weapon slots
* Semi-auto markers
* Sniper markers
* Brushes as standard melee
* Spray cans as collectible melee
* Team-only spectating after elimination
* No enemy spectating
* Proximity voice chat
* Option to disable enemy voice
* Dead players separated from living-player voice communication
* Brief cinematic Final Play after each round
* Final Play and Regroup remain separate
* No battle pass
* No pay-to-win
* Cosmetic cases
* Paint Chips currency
* Trading planned for post-launch
* Five-second locked trade countdown
* Scam warnings and trade history

Do not alter these rules unless the active task explicitly approves a change.

---

# Current Scope

The current milestone is **First Playable**.

Only implement features required by `tasks/CURRENT_MILESTONE.md`.

Do not add:

* Cases
* Trading
* Full progression
* Cosmetic collections
* Ranked matchmaking
* Multiple maps
* Large inventories
* Monetization
* Seasonal events
* Unrequested UI systems

Ideas outside the current milestone should be documented in the backlog rather than implemented.

---

# Technical Standards

## Language

Use Luau.

Use `--!strict` where practical.

Use explicit types for:

* Public module APIs
* Configuration tables
* Remote payloads
* Player data
* Weapon definitions
* Service interfaces
* Controller interfaces

Avoid using `any` unless unavoidable and clearly justified.

---

## Architecture

Maintain clear separation between:

```text
src/
├── client/
├── server/
└── shared/
```

### Client

The client may handle:

* Input
* Camera
* Viewmodels
* Local visual effects
* HUD
* Crosshairs
* Local animation playback
* Local prediction
* Audio presentation

The client must never be trusted to decide:

* Damage
* Eliminations
* Currency
* Inventory ownership
* Trade completion
* Fire-rate validity
* Ammunition validity
* Round results
* Match results
* XP rewards

### Server

The server is authoritative for:

* Weapon validation
* Hit validation
* Eliminations
* Teams
* Round state
* Match state
* Inventory ownership
* Progression
* Currency
* Trading
* Data saving
* Anti-exploit enforcement

### Shared

Shared modules may contain:

* Types
* Constants
* Configuration
* Weapon definitions
* Utility functions
* Network definitions
* Non-sensitive shared logic

Do not place secret or server-authoritative logic in shared modules available to clients.

---

# Networking Rules

All RemoteEvents and RemoteFunctions must be treated as untrusted entry points.

For every client request, validate:

* Player identity
* Request type
* Request shape
* Request frequency
* Current game state
* Current weapon state
* Ammunition
* Fire rate
* Distance
* Line of sight
* Team restrictions
* Permission to perform the action

Never allow the client to send another player as an unquestioned damage target.

Prefer the client sending:

* Origin
* Direction
* Timestamp
* Weapon identifier

Then have the server independently validate the shot.

Use rate limiting for remote requests.

Reject malformed, impossible, stale, or excessive requests.

---

# Weapon Rules

Project Canvas currently uses:

* Semi-auto markers
* Sniper markers
* Brushes
* Spray cans

Semi-auto weapons must not automatically fire from holding the input unless a future approved weapon explicitly supports that behavior.

Server-enforce:

* Fire interval
* Magazine count
* Reserve ammunition
* Reload state
* Equipped state
* Valid weapon ownership
* Shot origin
* Shot direction
* Obstruction checks
* Range
* Player state

Do not permit ammunition to become negative.

Do not permit firing while reloading unless specifically approved.

Weapon rarity must never improve competitive power.

---

# Animation Rules

Every weapon should eventually support:

* Idle
* Equip
* Fire
* Reload
* Inspect
* Sprint
* Movement presentation

Inspection is not restricted to rare weapons.

Weapon family determines the core animation identity.

Skins and rarity may add presentation differences but must not create gameplay benefits.

Do not hardcode animation IDs throughout multiple scripts.

Store asset references in weapon or animation configuration modules.

Use animation markers where appropriate for:

* Magazine changes
* Reload completion
* Sound timing
* Particle timing
* Weapon state changes

Gameplay-critical timing must remain server-authoritative.

---

# Code Quality

Write focused modules.

Avoid giant scripts that manage unrelated systems.

Prefer clear names such as:

```text
WeaponController
ViewmodelController
RoundService
HitValidationService
SpectatorController
NetworkDefinitions
WeaponDefinitions
```

Avoid vague names such as:

```text
Manager
Handler
Stuff
Main
System
Utils2
FinalScript
```

A module should have one primary responsibility.

Avoid unnecessary abstraction before it provides clear value.

Do not duplicate logic across files when a shared module is appropriate.

Do not rewrite functioning systems solely to match a personal preference.

Do not modify unrelated files.

---

# Comments and Documentation

Use comments to explain:

* Why a decision was made
* Security assumptions
* Complex state transitions
* Non-obvious math
* Workarounds
* Roblox-specific limitations

Do not add comments that merely repeat obvious code.

Public modules should clearly document:

* Purpose
* Inputs
* Outputs
* Side effects
* Failure behavior

---

# Performance

Avoid:

* Unnecessary per-frame loops
* Repeated expensive raycasts
* Repeated object searches
* Excessive RemoteEvent traffic
* Large unbounded tables
* Memory leaks from connections
* Creating and destroying excessive instances during combat

Disconnect event connections when systems are destroyed.

Reuse effects through pooling when appropriate.

Do not optimize prematurely, but do not knowingly create avoidable performance problems.

---

# Data Safety

Do not write production player data systems without an approved design.

When data saving is introduced:

* Use protected calls
* Handle failures
* Use session locking or an approved equivalent
* Avoid duplicate saves
* Validate loaded data
* Use versioned schemas
* Preserve backward compatibility
* Never trust values supplied by the client

Do not store secrets in the repository.

Never commit:

* API keys
* Access tokens
* Passwords
* Private certificates
* Personal credentials

---

# Git Rules

Work on a feature or fix branch.

Examples:

```text
feature/movement-controller
feature/semi-auto-prototype
fix/round-not-ending
docs/creative-bible-update
```

Do not push directly to `main`.

Keep commits focused.

Use clear commit messages.

Examples:

```text
feat: add first-person camera controller
feat: implement server-validated semi-auto firing
fix: prevent firing during reload
docs: update first playable milestone
refactor: separate weapon input from viewmodel logic
```

Do not commit generated junk, temporary files, logs, secrets, local settings, or build outputs that belong in `.gitignore`.

---

# Required Workflow

## Before Coding

Before making changes:

1. Read the relevant documentation.
2. Inspect the existing repository.
3. Restate the requested goal.
4. Identify affected systems.
5. List files to create or modify.
6. Identify dependencies.
7. Identify security and networking risks.
8. Identify any unclear or conflicting requirements.
9. Present a concise implementation plan.

Do not begin broad implementation before understanding the current codebase.

## During Coding

* Remain within task scope.
* Preserve working behavior.
* Use modular architecture.
* Validate all network-facing inputs.
* Update relevant types and configuration.
* Avoid hidden design changes.

## After Coding

Provide:

1. Summary of completed work
2. List of created files
3. List of modified files
4. Manual Roblox Studio steps
5. Test instructions
6. Edge cases tested
7. Known limitations
8. Security considerations
9. Anything incomplete
10. Suggested next task

Do not claim a feature is complete if it has not been tested or cannot be verified.

---

# Testing Expectations

For gameplay systems, test where possible using Roblox Studio multiplayer testing.

Verify:

* At least two players
* Client-server behavior
* Respawning
* Death during actions
* Leaving during a round
* Rejoining where relevant
* Network delay where practical
* Repeated input
* Invalid remote requests
* Rapid-fire attempts
* Reload edge cases
* State resets between rounds

Every task should include clear acceptance criteria.

---

# Bug Fix Workflow

When given a bug report:

1. Reproduce or reason through the failure.
2. Identify the root cause.
3. Identify all affected files.
4. Make the smallest reliable fix.
5. Check for related regressions.
6. Provide test steps.
7. Explain any assumptions.

Do not merely suppress errors without fixing their cause.

---

# Design Conflict Rule

If a requested implementation conflicts with the Creative Bible, GDD, TDD, or current milestone:

1. Do not silently implement it.
2. Identify the conflict.
3. Explain the likely consequences.
4. Offer a compatible alternative.
5. Wait for an approved decision before changing project direction.

---

# Final Standard

Every implementation should aim to be:

* Secure
* Maintainable
* Testable
* Modular
* Consistent
* Scope-controlled
* Appropriate for Roblox
* Faithful to Project Canvas

When uncertain, prefer a smaller, reliable, documented implementation over a large, speculative one.
