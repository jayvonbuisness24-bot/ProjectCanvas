--!strict
--[[
	ShotEffects.luau

	Purpose:
		Client-only, temporary world-space visuals for a fired shot
		(TASK-006): muzzle flash, tracer, and impact. Every effect is
		local-only, short-lived, and cleaned up via Debris — none of
		this decides a hit or carries any gameplay authority.

	Responsibilities:
		- Spawn a brief muzzle flash near a given origin.
		- Spawn a brief tracer beam between two points (client-predicted,
		  immediate — see WeaponController).
		- Spawn a brief impact effect at a given position, visually
		  distinguishing a real surface hit from an empty-space range
		  termination (server-confirmed — see WeaponController).

	Public API:
		ShotEffects.ShowMuzzleFlash(origin: Vector3): ()
		ShotEffects.ShowTracer(origin: Vector3, endPoint: Vector3): ()
		ShotEffects.ShowImpact(position: Vector3, normal: Vector3?, hit: boolean): ()

	Dependencies:
		shared/Config/WeaponConfig
		Workspace, Debris (Roblox services)

	Future Notes:
		Kept separate from WeaponController and ViewmodelController on
		purpose: every "spawn a temporary Workspace effect" concern lives
		in exactly one module, and future weapons (sniper, etc.) can
		reuse this directly rather than duplicating it. If a future task
		switches to Option B (a traveling cosmetic projectile,
		WeaponConfig.CosmeticProjectileEnabled), add it here rather than
		in WeaponController — it is still a presentation-only concern.
]]

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponConfig = require(Shared:WaitForChild("Config"):WaitForChild("WeaponConfig"))

local ShotEffects = {}

-- Brief glowing sphere + PointLight near the muzzle. Camera-relative
-- accuracy only (the exact current viewmodel barrel tip is not exposed
-- here on purpose — see the Future Notes in ViewmodelController).
function ShotEffects.ShowMuzzleFlash(origin: Vector3)
	if not WeaponConfig.MuzzleEffectEnabled then
		return
	end

	local flash = Instance.new("Part")
	flash.Name = "MuzzleFlashPlaceholder"
	flash.Anchored = true
	flash.CanCollide = false
	flash.CanTouch = false
	flash.CanQuery = false
	flash.Massless = true
	flash.Shape = Enum.PartType.Ball
	flash.Material = Enum.Material.Neon
	flash.Color = Color3.fromRGB(255, 240, 180)
	flash.Size = Vector3.new(0.28, 0.28, 0.28)
	flash.CFrame = CFrame.new(origin)
	flash.Parent = Workspace

	local light = Instance.new("PointLight")
	light.Brightness = 3
	light.Range = 6
	light.Color = Color3.fromRGB(255, 240, 180)
	light.Parent = flash

	Debris:AddItem(flash, WeaponConfig.MuzzleDuration)
end

-- Thin, short-lived beam from origin to endPoint, colored with the
-- configured paint color. Purely cosmetic/predicted — never used for
-- any gameplay decision.
function ShotEffects.ShowTracer(origin: Vector3, endPoint: Vector3)
	if not WeaponConfig.TracerEnabled then
		return
	end

	local distance = (endPoint - origin).Magnitude
	if distance <= 0 then
		return
	end

	local beam = Instance.new("Part")
	beam.Name = "TracerPlaceholder"
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanTouch = false
	beam.CanQuery = false
	beam.Massless = true
	beam.Material = Enum.Material.Neon
	beam.Color = WeaponConfig.PaintColor
	beam.Size = Vector3.new(WeaponConfig.TracerThickness, WeaponConfig.TracerThickness, distance)
	beam.CFrame = CFrame.new(origin, endPoint) * CFrame.new(0, 0, -distance / 2)
	beam.Parent = Workspace

	Debris:AddItem(beam, WeaponConfig.TracerDuration)
end

-- Server-confirmed impact effect. `hit` distinguishes a real surface
-- hit (a flat paint-colored disk aligned to `normal`) from an
-- empty-space range termination (a small fading grey puff, since there
-- is no surface to align a disk to).
function ShotEffects.ShowImpact(position: Vector3, normal: Vector3?, hit: boolean)
	if not WeaponConfig.ImpactEffectEnabled then
		return
	end

	local effect = Instance.new("Part")
	effect.Anchored = true
	effect.CanCollide = false
	effect.CanTouch = false
	effect.CanQuery = false
	effect.Massless = true
	effect.Material = Enum.Material.SmoothPlastic

	if hit then
		effect.Name = "PaintImpactPlaceholder"
		effect.Shape = Enum.PartType.Cylinder
		effect.Color = WeaponConfig.PaintColor
		-- Thin along local X; CFrame below aligns local X to the surface
		-- normal so the disk sits flush against the surface.
		effect.Size = Vector3.new(0.06, 0.5, 0.5)
		local upVector = normal or Vector3.new(0, 1, 0)
		effect.CFrame = CFrame.new(position, position + upVector) * CFrame.Angles(0, math.rad(90), 0)
	else
		effect.Name = "RangeTerminationPlaceholder"
		effect.Shape = Enum.PartType.Ball
		effect.Color = Color3.fromRGB(220, 220, 220)
		effect.Transparency = 0.35
		effect.Size = Vector3.new(0.35, 0.35, 0.35)
		effect.CFrame = CFrame.new(position)
	end

	effect.Parent = Workspace
	Debris:AddItem(effect, WeaponConfig.ImpactDuration)
end

return ShotEffects
