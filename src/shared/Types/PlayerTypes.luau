--!strict
--[[
	PlayerTypes.luau

	Purpose:
		Shared type describing a player's current gameplay state. No
		player-state system exists yet — this is scaffolding for the
		round and weapon systems that will read/write it.

	Responsibilities:
		Export the PlayerState type.

	Public API:
		PlayerTypes.PlayerState

	Dependencies:
		None.

	Future Notes:
		Expand as round/spectating/voice systems are implemented (e.g.
		spectating target, voice mute state). Keep client-authoritative
		fields separate from server-authoritative ones when that happens.
]]

export type PlayerState = {
	UserId: number,
	Team: string?,
	IsAlive: boolean,
	EquippedWeaponId: string?,
}

return {}
