--!strict
--[[
	WeaponDefinitions.luau

	Purpose:
		Shared, weapon-agnostic registry describing available weapons by
		id, so WeaponController and WeaponService never hardcode "the
		semi-auto marker" directly. Only one placeholder definition
		exists for TASK-005 — mirrors shared/Weapons/ViewmodelDefinitions'
		pattern from TASK-004.

	Responsibilities:
		- Export the WeaponDefinition type.
		- Resolve a definition by id.

	Public API:
		WeaponDefinitions.Get(id: string): WeaponDefinition?

	Dependencies:
		shared/Config/WeaponConfig (the current prototype weapon's values)
		shared/Types/WeaponTypes (WeaponFamily)

	Future Notes:
		This entry's behavioral fields (FireRate, MaximumRange,
		PaintballSpeed, Automatic, MarkerName) are read FROM WeaponConfig
		rather than duplicated here, so there is exactly one place to
		change the prototype weapon's values. When a second weapon is
		approved, give it its own literal entry here instead of reading
		WeaponConfig, and shrink WeaponConfig back down to genuinely
		global settings. ViewmodelId links to
		shared/Weapons/ViewmodelDefinitions so a future weapon-equip
		system can resolve both from one WeaponId.
]]

local WeaponConfig = require(script.Parent.Parent.Config.WeaponConfig)
local WeaponTypes = require(script.Parent.Parent.Types.WeaponTypes)

export type WeaponDefinition = {
	Id: string,
	DisplayName: string,
	Family: WeaponTypes.WeaponFamily,
	FireRate: number,
	MaximumRange: number,
	PaintballSpeed: number,
	Automatic: boolean,
	MarkerName: string,
	-- Links to shared/Weapons/ViewmodelDefinitions' matching entry.
	-- Not consumed by TASK-005; reserved for a future weapon-equip
	-- system that tells ViewmodelController what to display.
	ViewmodelId: string?,
}

local Definitions: { [string]: WeaponDefinition } = {
	[WeaponConfig.WeaponId] = {
		Id = WeaponConfig.WeaponId,
		DisplayName = "Placeholder Semi-Auto Marker",
		Family = "SemiAuto",
		FireRate = WeaponConfig.FireRate,
		MaximumRange = WeaponConfig.MaximumRange,
		PaintballSpeed = WeaponConfig.PaintballSpeed,
		Automatic = WeaponConfig.Automatic,
		MarkerName = WeaponConfig.MarkerName,
		ViewmodelId = "default_semi_auto",
	},
}

local WeaponDefinitions = {}

-- Resolves a definition by id, or nil if unknown. Callers must treat
-- nil as a recoverable failure — log and refuse to fire, never hard-error.
function WeaponDefinitions.Get(id: string): WeaponDefinition?
	return Definitions[id]
end

return WeaponDefinitions
