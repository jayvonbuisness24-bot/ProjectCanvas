--!strict
--[[
	WeaponTypes.luau

	Purpose:
		Shared type definitions describing weapons and loadouts. No
		weapon system exists yet — these types exist so future weapon,
		inventory, and UI modules share one vocabulary from the start.

	Responsibilities:
		Export WeaponFamily, WeaponDefinition, and Loadout types.

	Public API:
		WeaponTypes.WeaponFamily
		WeaponTypes.WeaponDefinition
		WeaponTypes.Loadout

	Dependencies:
		None.

	Future Notes:
		WeaponDefinition will grow to include fire rate, magazine size,
		damage, range, and asset/animation references once the Weapons
		system task is implemented. Keep those additions in this file
		rather than duplicating the type elsewhere.
]]

-- Matches the approved weapon families in CLAUDE.md / README.md.
export type WeaponFamily = "SemiAuto" | "Sniper" | "Brush" | "SprayCan"

export type WeaponDefinition = {
	Id: string,
	DisplayName: string,
	Family: WeaponFamily,
}

-- Matches the approved "two equipped weapon slots" rule.
export type Loadout = {
	PrimaryWeaponId: string?,
	SecondaryWeaponId: string?,
}

return {}
