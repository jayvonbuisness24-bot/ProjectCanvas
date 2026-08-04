--!strict
--[[
	NetworkDefinitions.luau

	Purpose:
		Single source of truth for what Remote instances exist. Nothing
		is registered yet — no gameplay networking is in scope for this
		task (see TASK-001_PROJECT_FOUNDATION.md "Out of Scope").

	Responsibilities:
		- Define the shape of a remote definition entry.
		- Hold the (currently empty) registry that
		  shared/Network/RemoteRegistry reads from.

	Public API:
		NetworkDefinitions.Remotes: { [string]: RemoteDefinition }

	Dependencies:
		None.

	Future Notes:
		When gameplay networking is implemented, add entries like:
			Remotes.RequestFireWeapon = { Name = "RequestFireWeapon", Kind = "Event" }
		then have RemoteRegistry.Init() (server-only) create the
		instances. Never add a definition here without a corresponding
		server-side validation handler in server/Networking.
]]

export type RemoteKind = "Event" | "Function"

export type RemoteDefinition = {
	Name: string,
	Kind: RemoteKind,
}

local Remotes: { [string]: RemoteDefinition } = {}

return {
	Remotes = Remotes,
}
