--!strict
--[[
	CombatTypes.luau

	Purpose:
		Shared types for hit validation and damage requests. No hit
		validation system exists yet — this is scaffolding for the future
		HitValidationService.

	Responsibilities:
		Export the HitResult and DamageRequest types.

	Public API:
		CombatTypes.HitResult
		CombatTypes.DamageRequest

	Dependencies:
		None.

	Future Notes:
		DamageRequest intentionally mirrors CLAUDE.md's Networking Rules
		("client sends origin, direction, timestamp, weapon identifier;
		server independently validates the shot"). Do not add a raw
		damage-amount or target-player field that the client controls —
		the server must derive those from validation, never trust them.
]]

export type HitResult = {
	Hit: boolean,
	Position: Vector3?,
	Normal: Vector3?,
	Instance: Instance?,
	Player: Player?,
}

export type DamageRequest = {
	WeaponId: string,
	Origin: Vector3,
	Direction: Vector3,
	Timestamp: number,
}

return {}
