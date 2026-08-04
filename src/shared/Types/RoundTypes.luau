--!strict
--[[
	RoundTypes.luau

	Purpose:
		Shared type describing round/match state. No round system exists
		yet — this is scaffolding for the future RoundService.

	Responsibilities:
		Export the RoundPhase and RoundState types.

	Public API:
		RoundTypes.RoundPhase
		RoundTypes.RoundState

	Dependencies:
		None.

	Future Notes:
		RoundPhase mirrors the approved round flow (Regroup, Final Play)
		documented in CLAUDE.md. Do not add phases that aren't approved
		design without confirming first.
]]

export type RoundPhase = "Waiting" | "InProgress" | "FinalPlay" | "Regroup" | "MatchComplete"

export type RoundState = {
	Phase: RoundPhase,
	RoundNumber: number,
	TeamScores: { [string]: number },
}

return {}
