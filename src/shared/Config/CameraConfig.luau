--!strict
--[[
	CameraConfig.luau

	Purpose:
		Structural camera configuration only. No camera system exists yet
		(see TASK-001_PROJECT_FOUNDATION.md "Out of Scope"). Every value
		below is a placeholder, not an approved design value.

	Responsibilities:
		Export a single, typed CameraConfig table.

	Public API:
		CameraConfig.DefaultFieldOfView: number
		CameraConfig.MinFieldOfView: number
		CameraConfig.MaxFieldOfView: number

	Dependencies:
		None.

	Future Notes:
		CLAUDE.md's Player Ownership pillar requires players to control
		field of view — Min/MaxFieldOfView exist to bound that control.
		Confirm real defaults with design when the Camera Controller task
		is implemented; do not treat these numbers as final.
]]

export type CameraConfig = {
	DefaultFieldOfView: number,
	MinFieldOfView: number,
	MaxFieldOfView: number,
}

local CameraConfig: CameraConfig = {
	-- Placeholder values, not yet approved by design.
	DefaultFieldOfView = 70,
	MinFieldOfView = 60,
	MaxFieldOfView = 100,
}

return CameraConfig
