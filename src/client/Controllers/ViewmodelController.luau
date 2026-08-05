--!strict
--[[
	ViewmodelController.luau

	Purpose:
		Displays a local-only first-person viewmodel (placeholder arms +
		one placeholder marker) parented to the camera (TASK-004). The
		second Controller registered through the TASK-002 Bootstrap
		framework, after CameraController.

	Responsibilities:
		- Build a placeholder viewmodel Model from Parts (Option A — see
		  Future Notes) for the configured ViewmodelDefinitions entry.
		- Parent it to Workspace.CurrentCamera and keep it tracking the
		  camera every render step, without ever writing to the camera's
		  own CFrame.
		- Rebind cleanly across CurrentCamera replacement and character
		  spawn/reset/respawn/removal — never leaving more than one
		  active viewmodel.
		- Provide an obvious extension point for future weapon-driven
		  viewmodel selection and animation.

	Public API:
		ViewmodelController.Init(): ()
		ViewmodelController.Start(): ()
		ViewmodelController.Destroy(): ()
		(Loaded only via shared/Framework/ControllerLoader — never
		 require or start this module directly.)

	Dependencies:
		shared/Config/ViewmodelConfig
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
local ViewmodelDefinitions = require(Shared:WaitForChild("Weapons"):WaitForChild("ViewmodelDefinitions"))
local Logger = require(Shared.Utilities.Logger)

type ViewmodelDefinition = ViewmodelDefinitions.ViewmodelDefinition

type ViewmodelParts = {
	root: BasePart,
	leftArm: BasePart,
	rightArm: BasePart,
	marker: BasePart,
}

local ViewmodelController = {}

local RENDER_BINDING_NAME = "ViewmodelController_FollowCamera"

-- Placeholder neutral "ready" pose, relative to Root. Studs — not final,
-- see TASK-004's "Arms and Marker Presentation."
local LEFT_ARM_LOCAL_OFFSET = CFrame.new(-0.45, -0.25, -0.35)
local RIGHT_ARM_LOCAL_OFFSET = CFrame.new(0.45, -0.25, -0.35)
local MARKER_LOCAL_OFFSET = CFrame.new(0.35, -0.1, -0.9)

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

	local leftArm = newPlaceholderPart("LeftArm", Vector3.new(0.4, 0.4, 1.2), Color3.fromRGB(120, 120, 120))
	leftArm.CFrame = root.CFrame * LEFT_ARM_LOCAL_OFFSET
	leftArm.Parent = model

	local rightArm = newPlaceholderPart("RightArm", Vector3.new(0.4, 0.4, 1.2), Color3.fromRGB(120, 120, 120))
	rightArm.CFrame = root.CFrame * RIGHT_ARM_LOCAL_OFFSET
	rightArm.Parent = model

	local marker = newPlaceholderPart("Marker", Vector3.new(0.3, 0.3, 1.4), Color3.fromRGB(60, 60, 70))
	marker.CFrame = root.CFrame * MARKER_LOCAL_OFFSET
	marker.Parent = model

	viewmodelParts = { root = root, leftArm = leftArm, rightArm = rightArm, marker = marker }

	return model
end

-- Called once per render step (and once immediately on creation) to
-- track the camera. Never writes to camera.CFrame itself.
local function updateTransform()
	local parts = viewmodelParts
	local camera = Workspace.CurrentCamera
	local definition = activeDefinition
	if not parts or not camera or not definition then
		return
	end

	local rootCFrame = camera.CFrame * getBaseOffsetCFrame(definition)
	parts.root.CFrame = rootCFrame
	parts.leftArm.CFrame = rootCFrame * LEFT_ARM_LOCAL_OFFSET
	parts.rightArm.CFrame = rootCFrame * RIGHT_ARM_LOCAL_OFFSET
	parts.marker.CFrame = rootCFrame * MARKER_LOCAL_OFFSET
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
	updateTransform() -- correct pose before it's ever parented/rendered
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
