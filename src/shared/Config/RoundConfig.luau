--!strict
--[[
	RoundConfig.luau

	Purpose:
		Structural round configuration. Values here reflect design
		decisions already approved in README.md / CLAUDE.md — this
		module does not implement any round logic (see
		TASK-001_PROJECT_FOUNDATION.md "Out of Scope").

	Responsibilities:
		Export a single, typed RoundConfig table.

	Public API:
		RoundConfig.TeamSize: number
		RoundConfig.RoundsToWin: number
		RoundConfig.RegroupDurationSeconds: number

	Dependencies:
		None.

	Future Notes:
		The future RoundService should read from this module rather than
		hardcoding these numbers. Any change to these values is a design
		change and must go through the Design Conflict Rule in CLAUDE.md.
]]

export type RoundConfig = {
	TeamSize: number,
	RoundsToWin: number,
	RegroupDurationSeconds: number,
}

local RoundConfig: RoundConfig = {
	-- Approved: 6v6 public matches (README.md, CLAUDE.md).
	TeamSize = 6,
	-- Approved: first team to six round wins (README.md, CLAUDE.md).
	RoundsToWin = 6,
	-- Approved: eight-second Regroup phase (CLAUDE.md).
	RegroupDurationSeconds = 8,
}

return RoundConfig
