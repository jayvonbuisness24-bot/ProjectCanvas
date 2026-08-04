--!strict
--[[
	Constants.luau

	Purpose:
		Small, generic, non-gameplay constants shared by both client and
		server (folder names, log prefixes, etc.). This module must never
		hold gameplay-balance values — those belong in shared/Config.

	Responsibilities:
		- Provide a single source of truth for cross-cutting literal
		  strings/values so they are not duplicated across modules.

	Public API:
		Constants.REMOTES_FOLDER_NAME: string
		Constants.LOG_PREFIX: string

	Dependencies:
		None.

	Future Notes:
		Add new structural constants here as they become needed. Do not
		add per-weapon, per-round, or other tunable gameplay values.
]]

export type Constants = {
	REMOTES_FOLDER_NAME: string,
	LOG_PREFIX: string,
}

local Constants: Constants = {
	-- Name of the Folder under ReplicatedStorage that holds all Remote
	-- instances created by shared/Network/RemoteRegistry.
	REMOTES_FOLDER_NAME = "Remotes",

	-- Prefix applied to every message emitted by shared/Utilities/Logger.
	LOG_PREFIX = "ProjectCanvas",
}

return Constants
