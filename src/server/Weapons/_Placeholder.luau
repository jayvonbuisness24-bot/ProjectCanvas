--!strict
--[[
	_Placeholder.luau (server/Weapons)

	Purpose:
		Reserved location for server-authoritative weapon validation
		(fire interval, ammo, obstruction/range checks — see CLAUDE.md
		Weapon Rules). Empty by design — no weapon system exists yet.

	Responsibilities:
		None yet.

	Public API:
		None. Not intended to be required.

	Dependencies:
		None.

	Future Notes:
		This is the server's authority boundary for weapons; the client
		must never be trusted for fire-rate or ammunition validity. Type
		with shared/Types/WeaponTypes and shared/Types/CombatTypes.
]]

return {}
