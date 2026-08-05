# Community Assets Pending Integration

These are third-party community assets that have been reviewed and approved for future integration after refactoring to match Project Canvas architecture.

## Approved

### FPS Counter
Status: Approved with light refactoring

Reason:
- Secure
- Lightweight
- Good UI polish
- Fits Project Canvas

Notes:
- Convert into modular controller architecture.
- Add lifecycle cleanup.
- Move colors into theme/config.

---

### Player Card Pro
Status: Approved with major refactoring

Proposed Architecture:

- `PlayerProfileController`
- `PlayerProfileView`
- `ProfileAnimator`
- `PlayerProfileModel`
- `Theme`
- `WidgetFactory`
- `PlayerStatsProvider`

Required Changes:

- Replace local XP and playtime progression with server-authoritative data.
- Separate presentation from player data.
- Add lifecycle cleanup.
- Connect the profile UI to the future progression and statistics systems.
- Preserve the community asset’s visual design and animation style where practical.
