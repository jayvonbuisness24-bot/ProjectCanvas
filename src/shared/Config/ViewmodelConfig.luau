--!strict
--[[
	ViewmodelConfig.luau

	Purpose:
		Structural and behavioral configuration for the first-person
		viewmodel (TASK-004). Governs how ViewmodelController positions,
		prioritizes, and shows/hides the local viewmodel — none of this
		is final art or animation direction.

	Responsibilities:
		Export a single, typed ViewmodelConfig table.

	Public API:
		ViewmodelConfig.Enabled: boolean
		ViewmodelConfig.DefaultViewmodelId: string
		ViewmodelConfig.BasePositionOffset: Vector3
		ViewmodelConfig.BaseRotationOffset: Vector3
		ViewmodelConfig.RenderPriority: number
		ViewmodelConfig.HideWhenNotFirstPerson: boolean
		ViewmodelConfig.CastShadow: boolean
		ViewmodelConfig.PlaceholderSwayEnabled: boolean
		ViewmodelConfig.PlaceholderBobEnabled: boolean

	Dependencies:
		None.

	Future Notes:
		PlaceholderSwayEnabled/PlaceholderBobEnabled are reserved toggles
		only — TASK-004 does not implement sway or bob. Wire the actual
		behavior up behind these existing toggles when that motion-
		presentation task is approved, rather than adding it ahead of
		time.
]]

export type ViewmodelConfig = {
	Enabled: boolean,
	DefaultViewmodelId: string,
	BasePositionOffset: Vector3,
	BaseRotationOffset: Vector3,
	RenderPriority: number,
	HideWhenNotFirstPerson: boolean,
	CastShadow: boolean,
	PlaceholderSwayEnabled: boolean,
	PlaceholderBobEnabled: boolean,
}

local ViewmodelConfig: ViewmodelConfig = {
	Enabled = true,

	-- Must match a key in shared/Weapons/ViewmodelDefinitions.luau.
	DefaultViewmodelId = "default_semi_auto",

	-- Placeholder pose offset relative to the camera, in studs/degrees.
	-- Not approved by design — revisit once real marker art/animation
	-- exists.
	BasePositionOffset = Vector3.new(0.55, -0.55, -1.1),
	BaseRotationOffset = Vector3.new(0, 0, 0),

	-- Runs immediately after Roblox's own camera update step, so the
	-- viewmodel reads this frame's Camera.CFrame rather than lagging a
	-- frame behind it.
	RenderPriority = Enum.RenderPriority.Camera.Value + 1,

	-- Reflects the live Player.CameraMode, not a static assumption —
	-- see CameraController for the analogous pattern.
	HideWhenNotFirstPerson = true,

	-- Placeholder blocks should not cast shadows onto the world.
	CastShadow = false,

	-- Placeholders only — TASK-004 implements neither.
	PlaceholderSwayEnabled = false,
	PlaceholderBobEnabled = false,
}

return ViewmodelConfig
