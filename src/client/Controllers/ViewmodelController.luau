--!strict
--[[
	ViewmodelController.luau

	Purpose:
		Displays a local-only first-person viewmodel — a multi-part
		placeholder marker (TASK-006) plus supporting arms — parented to
		the camera (TASK-004). The second Controller registered through
		the TASK-002 Bootstrap framework, after CameraController.

	Responsibilities:
		- Build a placeholder viewmodel Model from Parts (Option A — see
		  Future Notes) for the configured ViewmodelDefinitions entry:
		  a Root anchor, two arms, and a six-part marker (Body, Barrel,
		  Grip, TriggerFrame, Hopper, Tank).
		- Parent it to Workspace.CurrentCamera and keep it tracking the
		  camera every render step, without ever writing to the camera's
		  own CFrame.
		- Play a small, self-contained fire "kick" on request
		  (PlayFirePresentation) — a brief position/rotation offset that
		  always returns cleanly to rest and never accumulates.
		- Rebind cleanly across CurrentCamera replacement and character
		  spawn/reset/respawn/removal — never leaving more than one
		  active viewmodel.
		- Provide an obvious extension point for future weapon-driven
		  viewmodel selection and animation.

	Public API:
		ViewmodelController.Init(): ()
		ViewmodelController.Start(): ()
		ViewmodelController.Destroy(): ()
		ViewmodelController.PlayFirePresentation(): ()
			Safe no-op if no viewmodel is currently active (e.g. not in
			first person, or between character removal and the next
			spawn). Triggers only the viewmodel kick — muzzle flash and
			shot/impact visuals are owned by WeaponController/ShotEffects,
			not this controller (see Future Notes).
		(Loaded only via shared/Framework/ControllerLoader — never
		 require or start this module directly.)

	Dependencies:
		shared/Config/ViewmodelConfig
		shared/Config/WeaponConfig (PaintColor only, to tint the Hopper)
		shared/Weapons/ViewmodelDefinitions
		shared/Utilities/Logger
		Players, RunService, Workspace (Roblox services)

	Future Notes:
		Construction uses Option A (runtime Parts, see TASK-004's
		"Viewmodel Creation" section) rather than a ReplicatedStorage
		template: this repo has no Studio-authored asset pipeline yet,
		Option A keeps the model fully in source control, and it's safe
		from free-model scripts. ViewmodelDefinition.ConstructionMethod
		already reserves room for a future "Template" method that clones
		from a ReplicatedStorage asset without changing this
		controller's public contract.

		Muzzle flash deliberately does NOT live here even though this
		controller could compute the exact barrel-tip position — putting
		it in shared/Weapons/ShotEffects instead keeps every "spawn a
		temporary world-space effect" concern in one module, alongside
		the tracer and impact effects it's visually part of. This
		controller's only presentation responsibility is animating
		itself (the kick).

		The kick is a hand-rolled two-phase per-frame lerp rather than
		TweenService + an Instance: it needs no extra Instance, no event
		cancellation handling, and resets trivially on rapid re-fire
		(see playKick/updateTransform). A future camera-kick extension
		point should be added to CameraController deliberately, not
		bolted on here — see ViewmodelConfig's CameraKickEnabled notes.

		A future weapon system should call into ViewmodelController (or
		a successor) to say *which* definition id to show, rather than
		this module owning weapon-equip logic itself. Future animation
		states (Idle/Equip/Fire/Reload/Inspect/Sprint) should drive an
		Animator/AnimationController keyed off ViewmodelDefinition's
		AnimationSetId, hooked in around buildPlaceholderModel/
		updateTransform, rather than adding ad hoc per-state branches
		here.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Controllers live under StarterPlayerScripts.Client, a separate service
-- tree from ReplicatedStorage.Shared — resolved the same way
-- CameraController does.
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ViewmodelConfig = require(Shared:WaitForChild("Config"):WaitForChild("ViewmodelConfig"))
-- WeaponConfig is only used for its PaintColor, to tint the Hopper part
-- the same color the marker fires — a cosmetic link, not a firing
-- dependency.
local WeaponConfig = require(Shared:WaitForChild("Config"):WaitForChild("WeaponConfig"))
local ViewmodelDefinitions = require(Shared:WaitForChild("Weapons"):WaitForChild("ViewmodelDefinitions"))
local Logger = require(Shared.Utilities.Logger)

type ViewmodelDefinition = ViewmodelDefinitions.ViewmodelDefinition

type ViewmodelParts = {
	root: BasePart,
	leftArm: BasePart,
	rightArm: BasePart,
	body: BasePart,
	barrel: BasePart,
	grip: BasePart,
	triggerFrame: BasePart,
	hopper: BasePart,
	tank: BasePart,
}

local ViewmodelController = {}

local RENDER_BINDING_NAME = "ViewmodelController_FollowCamera"

-- Placeholder marker/arm pose, relative to Root. Studs/CFrames — not
-- final, see TASK-006's "Viewmodel Improvements" / "Arm Pose
-- Improvements." Root's forward is -Z, up is +Y, right is +X.
local BODY_LOCAL_OFFSET = CFrame.new(0, 0, -0.3)
local BARREL_LOCAL_OFFSET = CFrame.new(0, 0.02, -1.05) * CFrame.Angles(0, math.rad(90), 0)
local GRIP_LOCAL_OFFSET = CFrame.new(0, -0.42, 0.12) * CFrame.Angles(math.rad(-12), 0, 0)
local TRIGGER_FRAME_LOCAL_OFFSET = CFrame.new(0, -0.16, 0.05)
local HOPPER_LOCAL_OFFSET = CFrame.new(0, 0.32, -0.15) * CFrame.Angles(0, 0, math.rad(90))
local TANK_LOCAL_OFFSET = CFrame.new(0, -0.5, 0.55) * CFrame.Angles(0, math.rad(90), 0)

-- Right arm sits at the Grip (reads as "holding the grip"); left arm
-- sits under the Body/Barrel front (reads as "supporting the front").
-- Both stay low/to the sides so they don't cover the crosshair.
local LEFT_ARM_LOCAL_OFFSET = CFrame.new(-0.16, -0.18, -0.75) * CFrame.Angles(math.rad(8), math.rad(10), 0)
local RIGHT_ARM_LOCAL_OFFSET = CFrame.new(0.18, -0.42, 0.12) * CFrame.Angles(math.rad(-12), math.rad(-8), 0)

local localPlayer: Player? = nil
local activeDefinition: ViewmodelDefinition? = nil

local currentViewmodel: Model? = nil
local viewmodelParts: ViewmodelParts? = nil
local renderBound = false

local currentCameraConnection: RBXScriptConnection? = nil
local characterAddedConnection: RBXScriptConnection? = nil
local characterRemovingConnection: RBXScriptConnection? = nil

local initialized = false
local started = false

-- Fire-kick state. A plain per-frame lerp (see Future Notes) rather
-- than a Tween: "In" moves toward the kicked pose over KickInDuration,
-- "Return" moves back to rest over KickReturnDuration, "Idle" holds
-- identity. Re-firing mid-kick just restarts "In" from wherever the
-- offset currently is — no cancellation needed since nothing owns this
-- but plain local state.
type KickPhase = "Idle" | "In" | "Return"
local kickPhase: KickPhase = "Idle"
local kickElapsed = 0
local kickStartCFrame = CFrame.new()
local kickTargetCFrame = CFrame.new()
local currentKickOffset = CFrame.new()

-- Builds one non-collidable, non-queryable, anchored placeholder part.
-- Anchored so it never falls under gravity/physics regardless of being
-- parented under a Camera (Parent alone does not exempt a part from
-- physics simulation) — its CFrame is instead driven entirely by
-- updateTransform every render step.
local function newPlaceholderPart(name: string, size: Vector3, color: Color3): BasePart
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false -- excludes it from Raycast / GetPartsInPart by default
	part.Massless = true
	part.CastShadow = ViewmodelConfig.CastShadow
	return part
end

-- Computes the camera-relative offset the whole viewmodel should sit at,
-- preferring a per-definition override over ViewmodelConfig's base
-- values — the seam that lets a future weapon differ without any
-- ViewmodelController changes.
local function getBaseOffsetCFrame(definition: ViewmodelDefinition): CFrame
	local position = definition.PositionOffsetOverride or ViewmodelConfig.BasePositionOffset
	local rotation = definition.RotationOffsetOverride or ViewmodelConfig.BaseRotationOffset
	return CFrame.new(position) * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
end

-- Builds the placeholder model fully — every part positioned relative
-- to an identity Root — before it is ever parented, so nothing is
-- visible at the wrong place for even one frame.
local function buildPlaceholderModel(definition: ViewmodelDefinition): Model
	local model = Instance.new("Model")
	model.Name = "Viewmodel_" .. definition.Id

	local root = newPlaceholderPart(definition.RootPartName, Vector3.new(0.2, 0.2, 0.2), Color3.new(1, 1, 1))
	root.Transparency = 1 -- invisible anchor; only its CFrame matters
	root.CFrame = CFrame.new()
	root.Parent = model
	model.PrimaryPart = root

	local leftArm = newPlaceholderPart("LeftArm", Vector3.new(0.28, 0.3, 0.55), Color3.fromRGB(120, 120, 120))
	leftArm.CFrame = root.CFrame * LEFT_ARM_LOCAL_OFFSET
	leftArm.Parent = model

	local rightArm = newPlaceholderPart("RightArm", Vector3.new(0.28, 0.5, 0.3), Color3.fromRGB(120, 120, 120))
	rightArm.CFrame = root.CFrame * RIGHT_ARM_LOCAL_OFFSET
	rightArm.Parent = model

	-- Marker: Body/Barrel/Grip/TriggerFrame/Hopper/Tank, each a simple
	-- Part (Box/Cylinder). Not final art — see TASK-006 "Viewmodel
	-- Improvements."
	local body = newPlaceholderPart("Body", Vector3.new(0.35, 0.35, 1.0), Color3.fromRGB(60, 60, 65))
	body.CFrame = root.CFrame * BODY_LOCAL_OFFSET
	body.Parent = model

	local barrel = newPlaceholderPart("Barrel", Vector3.new(0.9, 0.18, 0.18), Color3.fromRGB(35, 35, 40))
	barrel.Shape = Enum.PartType.Cylinder
	barrel.CFrame = root.CFrame * BARREL_LOCAL_OFFSET
	barrel.Parent = model

	local grip = newPlaceholderPart("Grip", Vector3.new(0.22, 0.55, 0.22), Color3.fromRGB(25, 25, 25))
	grip.CFrame = root.CFrame * GRIP_LOCAL_OFFSET
	grip.Parent = model

	local triggerFrame = newPlaceholderPart("TriggerFrame", Vector3.new(0.28, 0.18, 0.22), Color3.fromRGB(20, 20, 20))
	triggerFrame.CFrame = root.CFrame * TRIGGER_FRAME_LOCAL_OFFSET
	triggerFrame.Parent = model

	-- Tinted with the same paint color the marker fires — visually ties
	-- "what's loaded" to "what it shoots."
	local hopper = newPlaceholderPart("Hopper", Vector3.new(0.5, 0.32, 0.32), WeaponConfig.PaintColor)
	hopper.Shape = Enum.PartType.Cylinder
	hopper.CFrame = root.CFrame * HOPPER_LOCAL_OFFSET
	hopper.Parent = model

	local tank = newPlaceholderPart("Tank", Vector3.new(0.6, 0.22, 0.22), Color3.fromRGB(140, 140, 145))
	tank.Shape = Enum.PartType.Cylinder
	tank.CFrame = root.CFrame * TANK_LOCAL_OFFSET
	tank.Parent = model

	viewmodelParts = {
		root = root,
		leftArm = leftArm,
		rightArm = rightArm,
		body = body,
		barrel = barrel,
		grip = grip,
		triggerFrame = triggerFrame,
		hopper = hopper,
		tank = tank,
	}

	-- Fresh viewmodel instance: reset kick state so nothing carries over
	-- from a previous (now-destroyed) viewmodel.
	kickPhase = "Idle"
	kickElapsed = 0
	currentKickOffset = CFrame.new()

	return model
end

-- Advances the fire-kick state machine by deltaTime. Always converges
-- back to identity (CFrame.new()) — never accumulates, never overshoots.
local function stepKick(deltaTime: number)
	if kickPhase == "In" then
		kickElapsed += deltaTime
		local duration = math.max(ViewmodelConfig.KickInDuration, 1e-4)
		local alpha = math.clamp(kickElapsed / duration, 0, 1)
		currentKickOffset = kickStartCFrame:Lerp(kickTargetCFrame, alpha)
		if alpha >= 1 then
			kickPhase = "Return"
			kickElapsed = 0
			kickStartCFrame = currentKickOffset
		end
	elseif kickPhase == "Return" then
		kickElapsed += deltaTime
		local duration = math.max(ViewmodelConfig.KickReturnDuration, 1e-4)
		local alpha = math.clamp(kickElapsed / duration, 0, 1)
		currentKickOffset = kickStartCFrame:Lerp(CFrame.new(), alpha)
		if alpha >= 1 then
			kickPhase = "Idle"
			currentKickOffset = CFrame.new()
		end
	end
	-- "Idle": currentKickOffset already holds CFrame.new(); nothing to do.
end

-- Called once per render step (and once immediately on creation) to
-- track the camera. Never writes to camera.CFrame itself.
local function updateTransform(deltaTime: number?)
	local parts = viewmodelParts
	local camera = Workspace.CurrentCamera
	local definition = activeDefinition
	if not parts or not camera or not definition then
		return
	end

	stepKick(deltaTime or 0)

	local rootCFrame = camera.CFrame * getBaseOffsetCFrame(definition) * currentKickOffset
	parts.root.CFrame = rootCFrame
	parts.leftArm.CFrame = rootCFrame * LEFT_ARM_LOCAL_OFFSET
	parts.rightArm.CFrame = rootCFrame * RIGHT_ARM_LOCAL_OFFSET
	parts.body.CFrame = rootCFrame * BODY_LOCAL_OFFSET
	parts.barrel.CFrame = rootCFrame * BARREL_LOCAL_OFFSET
	parts.grip.CFrame = rootCFrame * GRIP_LOCAL_OFFSET
	parts.triggerFrame.CFrame = rootCFrame * TRIGGER_FRAME_LOCAL_OFFSET
	parts.hopper.CFrame = rootCFrame * HOPPER_LOCAL_OFFSET
	parts.tank.CFrame = rootCFrame * TANK_LOCAL_OFFSET
end

local function destroyViewmodel()
	if renderBound then
		RunService:UnbindFromRenderStep(RENDER_BINDING_NAME)
		renderBound = false
	end

	if currentViewmodel then
		currentViewmodel:Destroy()
		currentViewmodel = nil
		Logger.Info("ViewmodelController: viewmodel destroyed")
	end
	viewmodelParts = nil
	kickPhase = "Idle"
end

-- True only while the local player is actually in Roblox's first-person
-- camera mode — reading live Player state rather than the static
-- CameraConfig toggle means this stays correct automatically once a
-- future lobby/match system starts switching CameraMode at runtime.
local function isFirstPerson(): boolean
	local player = localPlayer
	return player ~= nil and player.CameraMode == Enum.CameraMode.LockFirstPerson
end

-- (Re)creates the viewmodel bound to the current camera. Always
-- destroys any existing one first, so this is safe to call from
-- multiple triggers (CharacterAdded, CurrentCamera changing) without
-- ever producing a second active viewmodel.
local function ensureViewmodel()
	destroyViewmodel()

	if not ViewmodelConfig.Enabled then
		return
	end

	local player = localPlayer
	if not player or not player.Character then
		-- No character means nothing to visually hold a marker for.
		-- CharacterAdded will call ensureViewmodel again once a new
		-- character exists.
		return
	end

	if ViewmodelConfig.HideWhenNotFirstPerson and not isFirstPerson() then
		return
	end

	local camera = Workspace.CurrentCamera
	if not camera then
		-- Expected transiently around respawn; the CurrentCamera
		-- changed-signal below will call ensureViewmodel again once
		-- Roblox assigns a new one.
		return
	end

	local definition = activeDefinition
	if not definition then
		-- Already logged as an Error in Init when the id failed to
		-- resolve; nothing further to do here.
		return
	end

	local model = buildPlaceholderModel(definition)
	updateTransform(0) -- correct pose before it's ever parented/rendered
	model.Parent = camera
	currentViewmodel = model

	RunService:BindToRenderStep(RENDER_BINDING_NAME, ViewmodelConfig.RenderPriority, updateTransform)
	renderBound = true

	Logger.Info(string.format("ViewmodelController: viewmodel created (%s)", definition.Id))
end

local function onCurrentCameraChanged()
	Logger.Info("ViewmodelController: CurrentCamera changed, rebinding viewmodel")
	ensureViewmodel()
end

local function onCharacterAdded()
	ensureViewmodel()
end

local function onCharacterRemoving()
	destroyViewmodel()
end

function ViewmodelController.Init()
	assert(RunService:IsClient(), "ViewmodelController.Init must only be called from the client")

	if initialized then
		Logger.Warn("ViewmodelController: Init called more than once, ignoring")
		return
	end
	initialized = true

	localPlayer = Players.LocalPlayer

	activeDefinition = ViewmodelDefinitions.Get(ViewmodelConfig.DefaultViewmodelId)
	if not activeDefinition then
		Logger.Error(
			string.format(
				"ViewmodelController: unknown DefaultViewmodelId %q - no viewmodel will be shown",
				ViewmodelConfig.DefaultViewmodelId
			)
		)
	end

	Logger.Info("ViewmodelController: initialized")
end

function ViewmodelController.Start()
	if started then
		Logger.Warn("ViewmodelController: Start called more than once, ignoring")
		return
	end
	started = true

	local player = assert(localPlayer, "ViewmodelController.Start called before Init")

	currentCameraConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)
	characterAddedConnection = player.CharacterAdded:Connect(onCharacterAdded)
	characterRemovingConnection = player.CharacterRemoving:Connect(onCharacterRemoving)

	-- Handle the case where Start() runs after the character already
	-- exists (e.g. a slow Controller load) — CharacterAdded won't fire
	-- again for it, so bind it once here instead.
	if player.Character then
		ensureViewmodel()
	end

	Logger.Info("ViewmodelController: started")
end

-- Triggers the fire kick. Safe no-op if no viewmodel is currently
-- active — TASK-006 requires this not to error if the viewmodel
-- disappears during a shot (e.g. respawn racing a fire input).
function ViewmodelController.PlayFirePresentation()
	if not currentViewmodel or not viewmodelParts then
		return
	end

	kickStartCFrame = currentKickOffset
	kickTargetCFrame = CFrame.new(ViewmodelConfig.KickPosition) * CFrame.Angles(
		math.rad(ViewmodelConfig.KickRotation.X),
		math.rad(ViewmodelConfig.KickRotation.Y),
		math.rad(ViewmodelConfig.KickRotation.Z)
	)
	kickPhase = "In"
	kickElapsed = 0
end

function ViewmodelController.Destroy()
	if currentCameraConnection then
		currentCameraConnection:Disconnect()
		currentCameraConnection = nil
	end
	if characterAddedConnection then
		characterAddedConnection:Disconnect()
		characterAddedConnection = nil
	end
	if characterRemovingConnection then
		characterRemovingConnection:Disconnect()
		characterRemovingConnection = nil
	end

	destroyViewmodel()

	initialized = false
	started = false

	Logger.Info("ViewmodelController: destroyed")
end

return ViewmodelController
