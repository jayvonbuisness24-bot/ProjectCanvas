# Current Milestone — First Playable

Status: Active

Project: Project Canvas
Studio: Meliorism Studios

---

## Objective

Build the smallest complete playable version of Project Canvas.

By the end of this milestone, two players should be able to:

- Join the game
- Spawn correctly
- Enter first-person
- Hold a temporary marker
- Fire a semi-automatic marker
- Eliminate another player
- Respawn
- Test inside a simple arena

No progression or polish is required.

---

## Approved Task Order

- ✅ TASK-001 — Project Foundation
- ⏳ TASK-002 — Framework Bootstrap
- TASK-003 — First-Person Camera Foundation
- TASK-004 — Viewmodel System
- TASK-005 — Semi-Auto Marker Prototype
- TASK-006 — First Playable Test Arena

Tasks are completed in order.

---

## Current Task

### TASK-002 — Framework Bootstrap

Status: Ready for Implementation

Objective:

Create the startup framework that initializes approved client controllers and server services through a predictable lifecycle.

Required lifecycle:

- Init()
- Start()
- Destroy() (when applicable)

No gameplay should be implemented during this task.

---

## Included In This Milestone

- Project architecture
- Bootstrap framework
- First-person camera
- Viewmodel
- Semi-auto marker prototype
- Server-authoritative hit validation
- Temporary arena
- Multiplayer Studio testing

---

## Not Included

- Round system
- Regroup phase
- Final Play
- Team spectating
- Cases
- Trading
- Paint Chips
- XP
- Weapon skins
- Brushes
- Spray cans
- Snipers
- Player cards
- Badges
- Matchmaking
- Ranked
- Monetization
- Data saving
- Final art
- Final animations
- Final audio

---

## Completion Criteria

The milestone is complete when:

- The framework initializes successfully
- Two players can join Studio multiplayer
- First-person camera works
- Temporary viewmodel works
- Semi-auto firing works
- Server validates hits
- Walls block shots
- One-hit prototype elimination works
- Temporary arena supports testing
- Studio Output contains no unexpected errors

---

## Development Rule

Every task must be:

1. Implemented
2. Tested
3. Reviewed
4. Approved
5. Committed
6. Pushed

before moving to the next task.## Current Task

### TASK-003 — First-Person Camera Foundation

Status: In Testing

Objective:

Create the first-person camera controller, integrate it through the approved controller bootstrap, and verify first-person behavior, FOV, local character visibility, respawn recovery, and multiplayer visibility.