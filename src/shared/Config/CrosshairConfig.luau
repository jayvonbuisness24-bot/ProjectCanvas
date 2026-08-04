--!strict
--[[
	CrosshairConfig.luau

	Purpose:
		Structural crosshair configuration only. No crosshair/UI system
		exists yet (see TASK-001_PROJECT_FOUNDATION.md "Out of Scope").
		Every value below is a placeholder, not an approved design value.

	Responsibilities:
		Export a single, typed CrosshairConfig table.

	Public API:
		CrosshairConfig.DefaultColor: Color3
		CrosshairConfig.DefaultThicknessPixels: number
		CrosshairConfig.DefaultGapPixels: number

	Dependencies:
		None.

	Future Notes:
		Feeds the future Crosshair Editor referenced under CLAUDE.md's
		Player Ownership pillar. Crosshair customization must never
		create a competitive advantage (e.g. no hit-box-revealing
		colors) — enforce that constraint when the editor is built.
]]

export type CrosshairConfig = {
	DefaultColor: Color3,
	DefaultThicknessPixels: number,
	DefaultGapPixels: number,
}

local CrosshairConfig: CrosshairConfig = {
	-- Placeholder values, not yet approved by design.
	DefaultColor = Color3.fromRGB(255, 255, 255),
	DefaultThicknessPixels = 2,
	DefaultGapPixels = 4,
}

return CrosshairConfig
