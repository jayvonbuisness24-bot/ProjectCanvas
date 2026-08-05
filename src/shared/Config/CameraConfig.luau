--!strict
--[[
	CameraConfig.luau

	Purpose:
		Structural camera configuration. Values below back the TASK-003
		CameraController (first-person mode, mouse lock, local head/
		accessory hiding) plus a few forward-looking placeholders. None
		of these are final design values — see Future Notes.

	Responsibilities:
		Export a single, typed CameraConfig table.

	Public API:
		CameraConfig.DefaultFieldOfView: number
		CameraConfig.MinFieldOfView: number
		CameraConfig.MaxFieldOfView: number
		CameraConfig.FirstPersonEnabled: boolean
		CameraConfig.MouseLockEnabled: boolean
		CameraConfig.HideLocalHead: boolean
		CameraConfig.HideLocalAccessories: boolean
		CameraConfig.MotionEffectsEnabled: boolean

	Dependencies:
		None.

	Future Notes:
		CLAUDE.md's Player Ownership pillar requires players to control
		field of view — Min/MaxFieldOfView exist to bound that control.
		MotionEffectsEnabled is a placeholder for future motion/comfort
		accessibility settings (head bob, camera shake) — TASK-003 does
		not implement those layers, it only reserves the toggle so
		CameraController doesn't need a breaking config change later.
		Confirm real defaults with design as each camera layer ships;
		do not treat any value here as final.
]]

export type CameraConfig = {
	DefaultFieldOfView: number,
	MinFieldOfView: number,
	MaxFieldOfView: number,
	FirstPersonEnabled: boolean,
	MouseLockEnabled: boolean,
	HideLocalHead: boolean,
	HideLocalAccessories: boolean,
	MotionEffectsEnabled: boolean,
}

local CameraConfig: CameraConfig = {
	-- Placeholder values, not yet approved by design.
	DefaultFieldOfView = 70,
	MinFieldOfView = 60,
	MaxFieldOfView = 100,

	-- TASK-003 behavior toggles. All active-by-default except the
	-- not-yet-implemented motion effects placeholder.
	FirstPersonEnabled = true,
	MouseLockEnabled = true,
	HideLocalHead = true,
	HideLocalAccessories = true,

	-- Placeholder only — no head bob / motion effects exist yet.
	MotionEffectsEnabled = false,
}

return CameraConfig
