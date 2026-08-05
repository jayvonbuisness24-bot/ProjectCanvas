# Project Decisions

---

# Camera

## Lobby Camera

- Players may use Roblox's normal third-person camera while in the lobby.
- Players are free to zoom in and out while not in an active match.
- The lobby should feel like a social space rather than restricting player movement.

## Match Camera

- Active matches force first-person.
- The transition into first-person should occur automatically when a match begins.
- Camera behavior must remain configuration-driven through `CameraConfig`.
- Players cannot switch back to third-person during active gameplay.

## Camera Philosophy

- Prioritize immersion during matches.
- Use Roblox's built-in camera systems where practical.
- Build future camera features as modular layers rather than replacing the entire camera system.

---

# Movement

## Core Movement

- Walk
- Sprint
- Jump
- Crouch
- Slide
- Mantle

## Future Consideration

The following may be evaluated later but are **not approved**:

- Prone
- Vaulting improvements
- Additional traversal mechanics

---

# Movement Philosophy

Movement should reward:

- Positioning
- Timing
- Map knowledge
- Mechanical consistency

Movement should **not** reward exploiting the engine.

The game should feel responsive, tactical, and competitive without becoming overly arcade-like.

The following are **not part of the core movement philosophy**:

- Bunny hopping
- Infinite slide chaining
- Wall running
- Double jumping
- Grappling hooks
- Movement exploits

---

# Design Principle

When a design decision is finalized, it should be documented here before implementation so future tasks follow the established vision instead of redefining core mechanics.## Movement Priority

Movement should always feel:

1. Responsive
2. Predictable
3. Skill-based
4. Readable to opponents

Visual flair should never reduce competitive clarity.