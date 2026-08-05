# TASK-007 — First Playable Test Arena

Status: Approved

Milestone: First Playable

Priority: High

Depends On:

- TASK-001 — Project Foundation
- TASK-002 — Framework Bootstrap
- TASK-003 — First-Person Camera Foundation
- TASK-004 — Viewmodel System
- TASK-005 — Semi-Auto Marker Prototype
- TASK-006 — Marker Presentation Pass

---

# Objective

Create a temporary multiplayer test arena for Project Canvas.

The arena must provide a controlled environment for validating:

- First-person camera behavior
- Viewmodel presentation
- Marker firing
- Server-authoritative raycasts
- Paintball tracer presentation
- Confirmed impact effects
- Wall obstruction
- Spawn placement
- Respawn behavior
- Multiplayer synchronization
- Basic performance

The arena is a development blockout only.

It is not a final map and should not establish final environmental art direction.

---

# Gameplay Purpose

Give developers and test players a practical space where Project Canvas can be played and evaluated rather than tested on an empty baseplate.

The arena should support:

- Close-range encounters
- Medium-range engagements
- Long-range firing tests
- Cover peeking
- Elevation
- Hallways
- Open lanes
- Spawn separation
- Wall-impact testing
- Player-versus-player testing

By the end of TASK-007, at least two players should be able to join the same Studio test, spawn separately, move through the arena, fire the temporary marker, and see server-confirmed impact presentation.

No damage or elimination behavior is included yet.

---

# Technical Purpose

Create a lightweight, organized test environment that exposes problems in existing systems.

The arena should help reveal:

- Camera clipping
- Viewmodel clipping
- Incorrect tracer endpoints
- Shots passing through walls
- Impact effects spawning incorrectly
- Invalid spawn placement
- Respawn failures
- Duplicate local systems
- Multiplayer replication issues
- Performance problems
- Lighting readability issues

The arena should be easy to modify or replace later.

---

# Arena Design Principles

The arena should be:

- Easy to understand
- Easy to navigate
- Fast to test
- Clearly temporary
- Lightweight
- Modular
- Free of unnecessary scripts
- Free of untrusted marketplace assets

The arena should not attempt to be visually impressive.

Its purpose is validation.

---

# Required Layout Zones

The arena must include all of the following.

## Central Test Space

Create one open central area suitable for:

- General movement
- Marker firing
- Two-player engagements
- Tracer visibility
- Basic camera testing

The space should not be completely empty.

Include several cover objects that break sightlines.

## Close-Range Area

Include a tighter zone containing:

- Narrow pathways
- Short sightlines
- Full-height walls
- Waist-height cover
- Corners suitable for peeking

This area should help test:

- Viewmodel clipping
- Wall impacts
- Close-range firing
- Camera behavior near geometry

## Medium-Range Area

Include a combat lane with:

- Several pieces of offset cover
- Enough distance to observe tracer behavior
- Multiple lines of approach
- At least one flank route

## Long-Range Lane

Include one clear long sightline suitable for:

- Maximum-range tests
- Tracer readability
- Confirmed endpoint testing
- Server raycast range validation
- Impact placement at distance

The lane should terminate in a visible wall or target surface.

## Elevated Area

Include at least one elevated platform.

Requirements:

- Reachable by a ramp or stairs
- Safe enough for repeated testing
- Provides a different firing angle
- Includes basic edge protection where appropriate
- Does not require mantle mechanics

Mantling is approved as a future movement mechanic but is not implemented during TASK-007.

## Ramp

Include at least one ramp suitable for testing:

- Camera stability
- Walking uphill and downhill
- Viewmodel presentation during elevation changes
- Firing while moving vertically

## Corridor

Include at least one narrow corridor suitable for testing:

- First-person spatial comfort
- Camera clipping
- Close wall impacts
- Tracer behavior
- Corner peeking

## Obstruction Wall

Include a dedicated wall or wall series used specifically to verify:

- Shots stop at geometry
- Impact effects appear on the near surface
- Tracers do not continue through walls
- Server-confirmed endpoints match visible obstruction

---

# Cover Requirements

Use simple blockout geometry.

Include examples of:

- Full-height walls
- Waist-height cover
- Thin vertical cover
- Wide horizontal cover
- Offset cover
- Angled cover where practical
- Cover near corners
- Cover in open areas

Cover placement should allow testers to:

- Peek left and right
- Fire while partially exposed
- Move between cover
- Test impacts at different angles
- Test near-surface firing

Do not spend time competitively balancing the arena yet.

---

# Spawn Requirements

Provide separated spawn locations for multiplayer testing.

Minimum:

- Two spawn locations

Preferred:

- Four or more spawn locations for future small-team testing

Requirements:

- Spawns must not face directly into one another
- Spawns must not place players inside geometry
- Spawns must have sufficient headroom
- Spawns must be separated by cover or distance
- Players should not immediately see one another at spawn
- Respawning should return players to valid positions
- Spawn objects must be clearly labeled

Do not implement final spawn protection.

Do not implement team-specific spawn assignment unless required by Roblox Studio testing.

---

# Optional Test Targets

Include simple dummy targets if useful.

Allowed target types:

- Static anchored blocks
- Humanoid test dummy
- Clearly labeled impact boards
- Distance markers
- Wall-mounted test surfaces

Requirements:

- No complex AI
- No autonomous movement
- No damage system
- No elimination logic
- No imported scripts
- No untrusted free-model content

If a Humanoid dummy is used, it should exist only to test raycast identification and should not create gameplay consequences.

---

# Distance Markers

Where practical, label test distances such as:

```text
10 studs
25 studs
50 studs
100 studs
Maximum range test
```

These may use:

- BillboardGui labels
- SurfaceGui labels
- Simple signs
- Workspace part names

Do not create a polished signage system.

Distance markers should help validate range and tracer readability.

---

# Workspace Organization

All arena content must be grouped clearly.

Expected hierarchy:

```text
Workspace
└── TestArena
    ├── Geometry
    ├── Cover
    ├── Platforms
    ├── Ramps
    ├── Corridors
    ├── Spawns
    ├── TestTargets
    ├── DistanceMarkers
    └── Documentation
```

Exact names may change if Claude explains why.

Requirements:

- No loose unrelated Parts scattered across Workspace
- Clear object names
- Clear folder separation
- No hidden scripts inside geometry
- Arena root clearly marked as temporary
- Easy to delete or replace later

---

# Implementation Approach

Claude must choose and explain one approach.

## Option A — Runtime Arena Generator

Create the arena through a server-side development script or module.

Advantages:

- Fully source-controlled
- Repeatable
- Easy for Claude to implement
- No manual Studio construction required
- Easy to rebuild

Risks:

- Map geometry in code may become verbose
- Runtime generation should not become the permanent final-map pipeline

## Option B — Rojo-Compatible Model Structure

Represent arena content through source-controlled model files or a compatible model hierarchy.

Advantages:

- Better visual editing path
- Easier future artist collaboration

Risks:

- More setup complexity
- May require asset formats not ideal for text review

## Option C — Manual Studio Blockout

Provide detailed instructions for building the arena manually in Roblox Studio.

Advantages:

- Fast visual iteration
- Natural map-building workflow

Risks:

- Harder to review entirely through Git
- Manual changes may not be represented in source control unless the place file is managed carefully

For the current workflow, prefer the simplest repeatable approach that keeps the test arena maintainable and reviewable.

Do not introduce an elaborate map-loading framework.

---

# Recommended Approach

A source-controlled runtime or one-time generator is acceptable for TASK-007.

If a generator is used:

- It should create the arena deterministically
- It should not create duplicate arenas
- It should detect and remove or replace an existing test arena safely
- It should be clearly labeled as development-only
- It should not run in production indefinitely without an explicit future decision
- It should not contain unrelated gameplay logic

Claude may instead recommend a manual Studio blockout if it can justify why that is more appropriate.

---

# Materials and Colors

Use simple development materials.

Recommended:

- Concrete
- SmoothPlastic
- Metal where useful
- Neutral blockout colors
- Distinct colors for testing zones

Possible zone coloring:

- Neutral gray geometry
- Blue spawn zone
- Red alternate spawn zone
- Yellow range-test lane
- Green elevated area

These colors are for development readability only.

They are not final art direction.

Avoid:

- High-detail textures
- Final environment materials
- Branded assets
- Real-world logos
- Excessive neon
- Visual clutter
- Distracting lighting effects

---

# Lighting

Use readable, neutral lighting.

Requirements:

- Players and geometry remain visible
- Impact effects remain readable
- Tracers remain visible
- Dark corners do not prevent testing
- Lighting should not cause severe bloom or glare
- No cinematic lighting pass
- No final atmosphere
- No dynamic weather

Do not redesign the entire Lighting service if the current default environment is sufficient.

---

# Collision

All intended geometry should use appropriate collision.

Requirements:

- Floors are walkable
- Walls block players
- Cover blocks players where intended
- Ramps are usable
- Platforms are stable
- No invisible collision surprises
- No unanchored arena geometry
- No geometry falls or moves during testing

Test target effects should not block the player unless deliberately designed as cover.

---

# Raycast Compatibility

Arena geometry must participate correctly in server raycasts.

Requirements:

- Walls must be queryable
- Cover must be queryable
- Target surfaces must be queryable
- Shots must stop on the nearest obstruction
- Impact normal should be usable for effect orientation
- Arena geometry should not use collision/query settings that make bullets pass through unintentionally

The local first-person viewmodel remains `CanQuery = false`.

Do not change that.

---

# Camera and Viewmodel Validation

Arena dimensions should allow testing of:

- Looking straight up and down
- Walking into walls
- Standing near cover
- Firing near cover edges
- Entering narrow spaces
- Walking under overhead geometry
- Walking on ramps
- Standing on platforms
- Rapid camera rotation
- Viewmodel readability against light and dark surfaces

Avoid extremely low ceilings that make the camera unusable unless they are placed in a clearly labeled camera stress-test zone.

---

# Multiplayer Validation

The arena must support at least two-player Studio testing.

Requirements:

- Players spawn at separate locations
- Players can see one another
- Each player sees only their own first-person viewmodel
- Server raycasts function for both players
- Confirmed impact effects correspond to each player’s requests
- No damage occurs
- No player is automatically eliminated
- No team logic is required

---

# Performance

Keep the arena lightweight.

Requirements:

- Reasonable Part count
- Anchored static geometry
- No unnecessary loops
- No animated decoration
- No high-polygon marketplace models
- No unnecessary particles
- No unnecessary lights
- No script per Part
- No repeated runtime recreation after successful creation
- No excessive transparency layering

The arena should run comfortably in a local multiplayer Studio test.

---

# Test Arena Documentation

Include a simple development note describing the arena.

This may be:

- A ModuleScript comment
- A README-style source file
- A StringValue or Attribute on the TestArena model
- A development sign inside the arena

The note should state:

```text
Temporary First Playable Test Arena
Not final art
Not competitively balanced
Built for camera, viewmodel, firing, raycast, impact, spawn, and multiplayer validation
```

---

# Logging

Use the existing `Logger` for generated-arena systems.

Allowed logs:

- Arena generation started
- Arena generation complete
- Existing arena replaced
- Recoverable construction failure

Do not:

- Log every Part created
- Log every spawn
- Log every raycast
- Use raw `print()`

If the arena is built manually and contains no runtime code, no arena logger is required.

---

# Expected Files

Exact files depend on the selected implementation approach.

A runtime-generator approach may include equivalents of:

```text
src/server/Services/TestArenaService.luau
src/server/TestArena/ArenaBuilder.luau
src/shared/Config/TestArenaConfig.luau
src/server/Bootstrap.server.luau
CHANGELOG.md
```

A simpler one-time generator may instead include:

```text
src/server/TestArena/GenerateTestArena.server.luau
src/shared/Config/TestArenaConfig.luau
CHANGELOG.md
```

Claude must avoid turning a temporary arena into an oversized framework.

Remove obsolete placeholder files only when a real implementation now occupies their folder.

---

# Acceptance Criteria

- Test arena appears correctly in Studio
- Arena root is clearly organized under `Workspace.TestArena`
- Arena is clearly labeled temporary
- Central test space exists
- Close-range area exists
- Medium-range area exists
- Long-range lane exists
- Elevated platform exists
- Ramp exists
- Corridor exists
- Dedicated obstruction wall exists
- At least two separated spawns exist
- Spawns do not face directly into one another
- Players do not spawn inside geometry
- Arena geometry is anchored
- Players can walk through intended paths
- Walls block player movement
- Walls block server raycasts
- Tracers stop at walls
- Impact effects appear at wall surfaces
- Long-range shots terminate correctly
- Camera remains usable throughout intended spaces
- Viewmodel remains visible and stable
- Two-player Studio testing works
- Each player sees only their own viewmodel
- Both players can fire
- No damage occurs
- No eliminations occur
- No round logic is introduced
- No movement mechanics are introduced
- No final map art is introduced
- No untrusted scripts or free-model content are added
- `rojo build` succeeds
- Roblox Studio Output contains no unexpected errors

---

# Out of Scope

Do not implement:

- Final map art
- Final competitive map
- Map voting
- Map rotation
- Map loading framework
- Matchmaking
- Teams
- Round logic
- Scoring
- Damage
- Health
- Eliminations
- Spawn protection
- Team spawn assignment
- Killfeed
- HUD
- Crosshair polish
- Movement mechanics
- Sprint
- Crouch
- Slide
- Mantle
- Vaulting
- Destructible cover
- Dynamic weather
- Environmental audio
- Final lighting
- Final materials
- Final textures
- Final props
- Final decals
- NPC AI
- Bots
- Moving targets
- Automated tests
- Production map pipeline

---

# Future Expansion Notes

The temporary arena may later be replaced by:

- A dedicated developer testing place
- Automated firing ranges
- Movement obstacle courses
- Network simulation areas
- Final competitive maps
- Team-specific spawn zones
- Match-state-controlled map loading
- Round reset systems
- Destructible or paint-reactive surfaces
- Paint splatter testing walls

The current arena should remain easy to remove.

Do not let temporary arena assumptions become permanent gameplay architecture.

---

# Testing Checklist

## Build Test

- Run `rojo build default.project.json`
- Confirm build succeeds
- Confirm no unexpected generated file is tracked

## Arena Generation or Loading Test

- Start Studio
- Confirm exactly one `Workspace.TestArena` exists
- Confirm arena creation does not duplicate on repeated Play tests
- Confirm arena hierarchy is organized correctly
- Confirm no unexpected scripts exist inside geometry

## Spawn Test

- Start one-player test
- Confirm valid spawn
- Reset three times
- Confirm valid respawn every time
- Start two-player test
- Confirm separated spawn locations
- Confirm players do not immediately face one another

## Movement and Camera Test

- Walk through every zone
- Walk into every major wall
- Walk under overhead geometry
- Walk up and down the ramp
- Stand on elevated platform
- Enter corridor
- Rotate camera rapidly
- Look straight up and down
- Confirm no severe camera clipping in intended spaces

## Viewmodel Test

- Confirm viewmodel remains visible
- Fire while walking
- Fire while jumping
- Fire on ramp
- Fire from elevated platform
- Fire near walls
- Confirm no severe viewmodel clipping or jitter

## Raycast Test

- Shoot central cover
- Shoot full-height wall
- Shoot waist-height cover
- Shoot obstruction-test wall
- Shoot down the long-range lane
- Confirm nearest geometry stops the shot
- Confirm tracer endpoint matches obstruction
- Confirm impact appears on the correct surface

## Multiplayer Test

- Start two players
- Confirm each sees the other’s character
- Confirm each sees only their own local viewmodel
- Fire simultaneously
- Confirm both receive valid server confirmations
- Confirm no damage or elimination occurs
- Confirm no red errors

## Performance Test

- Observe Studio performance
- Confirm no repeated arena generation
- Confirm no growing Part count after respawn
- Confirm no repeated warning spam
- Confirm no unexpected scripts or loops

## Scope Test

- Confirm no teams
- Confirm no rounds
- Confirm no damage
- Confirm no eliminations
- Confirm no new movement mechanics
- Confirm no final art or audio

---

# Required Deliverables

Claude must provide:

- Summary
- Selected implementation approach
- Files created
- Files modified
- Files deleted
- Workspace hierarchy
- Arena layout explanation
- Spawn-placement explanation
- Raycast compatibility explanation
- Performance explanation
- Manual Roblox Studio steps
- Testing instructions
- Known limitations
- Security considerations
- Suggested next task

---

# Suggested Commit Message

```text
feat: add first playable test arena
```

---

# Review Checklist

- Is the arena clearly temporary?
- Is it useful for testing existing systems?
- Are all required testing zones present?
- Are spawns separated and valid?
- Does geometry block raycasts correctly?
- Are tracer and impact effects easy to evaluate?
- Can at least two players test simultaneously?
- Is the hierarchy organized?
- Is the Part count reasonable?
- Is the arena easy to remove later?
- Did Claude avoid damage, rounds, movement, and final-map scope?
- Does Studio run without errors?
