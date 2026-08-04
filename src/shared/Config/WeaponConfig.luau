--!strict
--[[
	WeaponConfig.luau

	Purpose:
		Structural weapon configuration only. No weapon system exists yet
		(see TASK-001_PROJECT_FOUNDATION.md "Out of Scope") — per-weapon
		balance (fire rate, magazine size, damage) intentionally does not
		live here.

	Responsibilities:
		Export a single, typed WeaponConfig table.

	Public API:
		WeaponConfig.EquippedSlotCount: number

	Dependencies:
		None.

	Future Notes:
		Per-weapon WeaponDefinition data belongs in shared/Weapons once
		the Weapons system is implemented, typed via
		shared/Types/WeaponTypes.luau.
]]

export type WeaponConfig = {
	EquippedSlotCount: number,
}

local WeaponConfig: WeaponConfig = {
	-- Approved: two equipped weapon slots (README.md, CLAUDE.md).
	EquippedSlotCount = 2,
}

return WeaponConfig
