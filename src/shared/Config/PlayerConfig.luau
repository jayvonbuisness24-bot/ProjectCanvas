--!strict
--[[
	PlayerConfig.luau

	Purpose:
		Structural player configuration only. No movement or spawning
		system exists yet (see TASK-001_PROJECT_FOUNDATION.md "Out of
		Scope") — values like WalkSpeed are not yet approved by design
		and are intentionally omitted rather than guessed.

	Responsibilities:
		Export a single, typed PlayerConfig table.

	Public API:
		PlayerConfig.OneLifePerRound: boolean

	Dependencies:
		None.

	Future Notes:
		Add movement/spawn values here once the Movement task confirms
		them with design — do not invent defaults ahead of that.
]]

export type PlayerConfig = {
	OneLifePerRound: boolean,
}

local PlayerConfig: PlayerConfig = {
	-- Approved: one life per round (README.md, CLAUDE.md).
	OneLifePerRound = true,
}

return PlayerConfig
