--!strict
--[[
	ViewmodelConfig.luau

	Purpose:
		Structural and behavioral configuration for the first-person
		viewmodel (TASK-004) and its fire-kick presentation (TASK-006).
		Governs how ViewmodelController positions, prioritizes, kicks,
		and shows/hides the local viewmodel — none of this is final art
		or animation direction.

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
		ViewmodelConfig.KickPosition: Vector3
		ViewmodelConfig.KickRotation: Vector3
		ViewmodelConfig.KickInDuration: number
		ViewmodelConfig.KickReturnDuration: number
		ViewmodelConfig.CameraKickEnabled: boolean
		ViewmodelConfig.CameraKickAmount: number

	Dependencies:
		None.

	Future Notes:
		PlaceholderSwayEnabled/PlaceholderBobEnabled remain reserved,
		inert toggles — still not implemented.

		CameraKickEnabled/CameraKickAmount are ALSO currently inert:
		CameraController exposes no public extension point for external
		offset contributions, and TASK-006 explicitly forbids rewriting
		CameraController just to add recoil. A future camera task should
		add a narrow, approved extension point (e.g. an AddCameraOffset-
		style method) and wire these fields up then.

		Muzzle flash is NOT configured here — it moved to WeaponConfig
		because it's spawned by shared/Weapons/ShotEffects (world-space,
		camera-relative), not by this controller. Keeping every "spawn a
		temporary effect" toggle in one place avoided splitting that
		responsibility across two config modules.
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
	KickPosition: Vector3,
	KickRotation: Vector3,
	KickInDuration: number,
	KickReturnDuration: number,
	CameraKickEnabled: boolean,
	CameraKickAmount: number,
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

	-- Placeholders only — not implemented.
	PlaceholderSwayEnabled = false,
	PlaceholderBobEnabled = false,

	-- TASK-006 fire kick. Small and controlled on purpose; +Z is toward
	-- the player (Root's forward is -Z), so this reads as "punched back
	-- and slightly up." Not visually tuned in Studio — expect to nudge
	-- signs/magnitudes once it can actually be seen.
	KickPosition = Vector3.new(0, 0.02, 0.08),
	KickRotation = Vector3.new(-4, 0, 0), -- degrees
	KickInDuration = 0.04, -- seconds
	KickReturnDuration = 0.14, -- seconds

	-- Inert placeholders — see Future Notes above. No CameraController
	-- extension point exists yet, and TASK-006 explicitly forbids
	-- rewriting CameraController to add one.
	CameraKickEnabled = false,
	CameraKickAmount = 0,
}

return ViewmodelConfig
