--!strict
--[[
	WeaponConfig.luau

	Purpose:
		Structural + prototype weapon configuration. TASK-005 adds the
		flat, single-prototype-weapon values the semi-auto marker
		pipeline reads; TASK-006 adds shot/impact/muzzle presentation
		values and rapid-fire-rejection logging thresholds. None of this
		is final balance or final art direction.

	Responsibilities:
		Export a single, typed WeaponConfig table.

	Public API:
		WeaponConfig.EquippedSlotCount: number
		WeaponConfig.WeaponId: string
		WeaponConfig.FireRate: number
		WeaponConfig.MaximumRange: number
		WeaponConfig.PaintballSpeed: number
		WeaponConfig.Automatic: boolean
		WeaponConfig.MarkerName: string
		WeaponConfig.PaintColor: Color3
		WeaponConfig.TracerEnabled: boolean
		WeaponConfig.TracerDuration: number
		WeaponConfig.TracerThickness: number
		WeaponConfig.CosmeticProjectileEnabled: boolean
		WeaponConfig.CosmeticProjectileSpeed: number
		WeaponConfig.MuzzleEffectEnabled: boolean
		WeaponConfig.MuzzleDuration: number
		WeaponConfig.ImpactEffectEnabled: boolean
		WeaponConfig.ImpactDuration: number
		WeaponConfig.RejectedRequestWarningThreshold: number
		WeaponConfig.RejectedRequestWindowSeconds: number
		WeaponConfig.RejectedRequestWarningCooldown: number

	Dependencies:
		None.

	Future Notes:
		shared/Weapons/WeaponDefinitions.luau's single entry is built
		FROM these values (not duplicated) — WeaponConfig remains the
		one source of truth for the current prototype weapon. When a
		second weapon is approved, move per-weapon fields into
		WeaponDefinitions entries keyed by id and shrink this back down
		to genuinely global weapon settings (EquippedSlotCount already
		is one).

		CosmeticProjectileEnabled/CosmeticProjectileSpeed are reserved,
		inert placeholders — TASK-006 chose Option A (a tracer) over
		Option B (a traveling cosmetic projectile) for simplicity. Wire
		these up only if a future task deliberately switches approaches.

		Muzzle flash is configured here (not in ViewmodelConfig) because
		shared/Weapons/ShotEffects spawns it from a camera-relative
		origin WeaponController already computes, the same as the
		tracer/impact — keeping every "spawn a temporary world-space
		effect" toggle in one module.
]]

export type WeaponConfig = {
	EquippedSlotCount: number,
	WeaponId: string,
	FireRate: number,
	MaximumRange: number,
	PaintballSpeed: number,
	Automatic: boolean,
	MarkerName: string,
	PaintColor: Color3,
	TracerEnabled: boolean,
	TracerDuration: number,
	TracerThickness: number,
	CosmeticProjectileEnabled: boolean,
	CosmeticProjectileSpeed: number,
	MuzzleEffectEnabled: boolean,
	MuzzleDuration: number,
	ImpactEffectEnabled: boolean,
	ImpactDuration: number,
	RejectedRequestWarningThreshold: number,
	RejectedRequestWindowSeconds: number,
	RejectedRequestWarningCooldown: number,
}

local WeaponConfig: WeaponConfig = {
	-- Approved: two equipped weapon slots (README.md, CLAUDE.md).
	EquippedSlotCount = 2,

	-- Must match a key in shared/Weapons/WeaponDefinitions.luau.
	WeaponId = "default_semi_auto",

	-- Placeholder values, not yet approved by design.
	FireRate = 0.35, -- seconds between shots (semi-auto pace)
	MaximumRange = 300, -- studs

	-- Not yet consumed — the raycast is instant-hit. Reserved for a
	-- future travel-time/projectile-simulation task.
	PaintballSpeed = 180, -- studs/second placeholder

	-- Must stay false per CLAUDE.md's Weapon Rules ("semi-auto weapons
	-- must not automatically fire from holding the input").
	Automatic = false,

	MarkerName = "Placeholder Semi-Auto Marker",

	-- TASK-006: one temporary paint color for the First Playable
	-- marker. Bright/clearly-visible development color, not final.
	PaintColor = Color3.fromRGB(30, 130, 255),

	-- Shot visualization (Option A — see WeaponDefinitions/ShotEffects
	-- Future Notes for why over Option B).
	TracerEnabled = true,
	TracerDuration = 0.05, -- seconds
	TracerThickness = 0.06, -- studs

	-- Reserved, inert — Option B not implemented this task.
	CosmeticProjectileEnabled = false,
	CosmeticProjectileSpeed = 250, -- studs/second placeholder, unused

	MuzzleEffectEnabled = true,
	MuzzleDuration = 0.05, -- seconds

	ImpactEffectEnabled = true,
	ImpactDuration = 0.6, -- seconds

	-- Rapid-fire rejection logging (TASK-006). Ordinary fast clicking
	-- must not flood Output; sustained abnormal rejection rates must
	-- still be diagnosable. See WeaponService for how these combine
	-- with shared/Network/NetworkUtils' rate limiter.
	RejectedRequestWarningThreshold = 20, -- rejections
	RejectedRequestWindowSeconds = 2, -- rolling window, seconds
	RejectedRequestWarningCooldown = 5, -- seconds between repeat warnings
}

return WeaponConfig
