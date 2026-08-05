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
		CombatTypes.FireWeaponRequest
		CombatTypes.FireConfirmation

	Dependencies:
		None.

	Future Notes:
		DamageRequest intentionally mirrors CLAUDE.md's Networking Rules
		("client sends origin, direction, timestamp, weapon identifier;
		server independently validates the shot"). Do not add a raw
		damage-amount or target-player field that the client controls —
		the server must derive those from validation, never trust them.

		FireWeaponRequest (TASK-005) is the same shape used by the
		no-damage firing pipeline. It is kept distinct from DamageRequest
		— rather than reusing that type outright — so a future damage/
		hit-validation task can evolve DamageRequest independently
		without implying WeaponService (which explicitly deals no
		damage) ever consumed a "damage request."

		FireConfirmation (TASK-006) is the server's reply to a validated
		FireWeaponRequest, sent back over the same FireWeapon RemoteEvent
		via FireClient. It intentionally carries no damage/health/
		elimination fields — see WeaponService. RequestId echoes the
		originating request's id so a future task could correlate a
		confirmation to a specific local prediction; TASK-006 itself does
		not need that correlation.
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

export type FireWeaponRequest = {
	WeaponId: string,
	Origin: Vector3,
	Direction: Vector3,
	Timestamp: number,
}

export type FireConfirmation = {
	RequestId: string,
	Hit: boolean,
	Position: Vector3,
	Normal: Vector3?,
}

return {}
