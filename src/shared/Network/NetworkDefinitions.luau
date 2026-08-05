--!strict
--[[
	NetworkDefinitions.luau

	Purpose:
		Single source of truth for what Remote instances exist.

	Responsibilities:
		- Define the shape of a remote definition entry.
		- Hold the registry that shared/Network/RemoteRegistry reads
		  from to create (server) and resolve (both realms) instances.

	Public API:
		NetworkDefinitions.Remotes: { [string]: RemoteDefinition }

	Dependencies:
		None.

	Future Notes:
		Never add a definition here without a corresponding server-side
		validation handler (e.g. FireWeapon's handler lives in
		server/Services/WeaponService.luau — see TASK-005). Follow
		CLAUDE.md's Networking Rules for every new entry: validate
		identity, shape, frequency, and game state server-side; never
		trust a client-supplied value for anything security-relevant.
]]

export type RemoteKind = "Event" | "Function"

export type RemoteDefinition = {
	Name: string,
	Kind: RemoteKind,
}

local Remotes: { [string]: RemoteDefinition } = {
	-- TASK-005/006: bidirectional. Client -> server fire requests are
	-- validated by server/Services/WeaponService.luau (see
	-- CombatTypes.FireWeaponRequest for that payload shape). The same
	-- RemoteEvent is reused server -> client (FireClient) to send back
	-- a CombatTypes.FireConfirmation once a request is validated and
	-- raycast — TASK-006 deliberately reuses this one Remote rather
	-- than adding a second, per CLAUDE.md's "do not duplicate" guidance.
	FireWeapon = { Name = "FireWeapon", Kind = "Event" },
}

return {
	Remotes = Remotes,
}
