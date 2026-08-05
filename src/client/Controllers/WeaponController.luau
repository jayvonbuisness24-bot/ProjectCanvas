--!strict
--[[
	WeaponController.luau

	Purpose:
		Client-side firing input for the semi-auto marker prototype
		(TASK-005), extended with immediate local presentation and
		server-confirmed impact placement (TASK-006). The third
		Controller registered through the TASK-002 Bootstrap framework,
		after CameraController and ViewmodelController.

	Responsibilities:
		- Turn left-click into a single fire attempt, respecting the
		  configured fire rate client-side (a UX/bandwidth throttle
		  only — the server independently re-validates fire rate and
		  never trusts this).
		- Request immediate local presentation: the viewmodel kick (via
		  ViewmodelController.PlayFirePresentation), a muzzle flash, and
		  a predicted tracer (via client/Weapons/ShotEffects) — all
		  purely cosmetic, never used to decide a hit.
		- Send a minimal FireWeapon request to the server (origin,
		  direction, weapon id, timestamp), per CLAUDE.md's Networking
		  Rules.
		- Listen for the server's FireConfirmation and show the impact
		  effect only once confirmed — the client never invents a
		  confirmed target.

	Public API:
		WeaponController.Init(): ()
		WeaponController.Start(): ()
		WeaponController.Destroy(): ()
		(Loaded only via shared/Framework/ControllerLoader — never
		 require or start this module directly.)

	Dependencies:
		shared/Config/WeaponConfig
		shared/Weapons/WeaponDefinitions
		client/Weapons/ShotEffects
		shared/Network/RemoteRegistry
		shared/Types/{CombatTypes, NetworkTypes}
		shared/Utilities/Logger
		client/Controllers/ViewmodelController (sibling Controller — see
		Future Notes)
		Players, UserInputService, RunService, Workspace, HttpService
		(Roblox services)

	Future Notes:
		WeaponController requires ViewmodelController directly (a
		same-folder sibling require, not a Bootstrap bypass) to call its
		narrow PlayFirePresentation() method. This is safe only because
		Bootstrap.client.luau's registry is processed strictly in order
		(CameraController, then ViewmodelController, then
		WeaponController) — by the time this Controller's Start() runs,
		ViewmodelController is already fully started. Do not reorder the
		registry without re-checking this assumption.

		No hit/damage confirmation beyond FireConfirmation is read from
		the server, on purpose — TASK-006 is presentation-only. A future
		hit-validation/damage task should extend FireConfirmation (or add
		a new confirmation) rather than this controller inferring
		anything from its own local raycast. onWeaponFired is where a
		future Animator should play a Fire animation, keyed off
		WeaponDefinition's future AnimationSetId.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Controllers live under StarterPlayerScripts.Client, a separate service
-- tree from ReplicatedStorage.Shared — resolved the same way
-- CameraController/ViewmodelController do.
local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponConfig = require(Shared:WaitForChild("Config"):WaitForChild("WeaponConfig"))
local WeaponDefinitions = require(Shared:WaitForChild("Weapons"):WaitForChild("WeaponDefinitions"))
local RemoteRegistry = require(Shared:WaitForChild("Network"):WaitForChild("RemoteRegistry"))
local CombatTypes = require(Shared.Types.CombatTypes)
local NetworkTypes = require(Shared.Types.NetworkTypes)
local Logger = require(Shared.Utilities.Logger)

-- Both are same-tree client-only siblings — no ReplicatedStorage
-- indirection needed. See Future Notes above for why the
-- ViewmodelController require in particular is safe here.
local ShotEffects = require(script.Parent.Parent.Weapons.ShotEffects)
local ViewmodelController = require(script.Parent.ViewmodelController)

type WeaponDefinition = WeaponDefinitions.WeaponDefinition

local WeaponController = {}

local localPlayer: Player? = nil
local activeDefinition: WeaponDefinition? = nil
local fireWeaponRemote: RemoteEvent? = nil

local lastLocalFireTime: number? = nil
local inputBeganConnection: RBXScriptConnection? = nil
local fireConfirmedConnection: RBXScriptConnection? = nil

local initialized = false
local started = false

-- Obvious, deliberately empty extension point for a future fire
-- animation — see the Future Notes header. TASK-005/006 do not create
-- animations.
local function onWeaponFired()
	-- Future: play the equipped WeaponDefinition's Fire animation via an
	-- Animator/AnimationController here.
end

local function isValidConfirmationShape(confirmation: any): boolean
	if typeof(confirmation) ~= "table" then
		return false
	end
	if typeof(confirmation.RequestId) ~= "string" then
		return false
	end
	if typeof(confirmation.Hit) ~= "boolean" then
		return false
	end
	if typeof(confirmation.Position) ~= "Vector3" then
		return false
	end
	return true
end

-- Server-confirmed result of a previously sent FireWeapon request. Only
-- source of truth for where the impact effect appears — this handler
-- never invents a confirmed target from local prediction.
local function onFireConfirmed(confirmation: any)
	if not isValidConfirmationShape(confirmation) then
		Logger.Warn("WeaponController: received a malformed FireWeapon confirmation")
		return
	end

	local normal = confirmation.Normal
	ShotEffects.ShowImpact(confirmation.Position, if typeof(normal) == "Vector3" then normal else nil, confirmation.Hit)
end

local function tryFire()
	local player = localPlayer
	local definition = activeDefinition
	local remote = fireWeaponRemote
	if not player or not definition or not remote then
		return
	end

	local character = player.Character
	local camera = Workspace.CurrentCamera
	if not character or not camera then
		return
	end

	-- Client-side fire-rate throttle: purely a UX/bandwidth courtesy so
	-- a held-down mouse button doesn't spam the remote. WeaponService
	-- re-validates fire rate independently using its own clock and is
	-- the only check that actually matters for fairness.
	local now = os.clock()
	if lastLocalFireTime and (now - lastLocalFireTime) < definition.FireRate then
		return
	end
	lastLocalFireTime = now

	local origin = camera.CFrame.Position
	local direction = camera.CFrame.LookVector

	-- Local-only predicted raycast for the immediate tracer. The local
	-- viewmodel already has CanQuery = false on every part (see
	-- TASK-004's ViewmodelController), so it is automatically excluded
	-- here without needing an explicit filter entry.
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	local result = Workspace:Raycast(origin, direction * definition.MaximumRange, raycastParams)
	local endPoint = if result then result.Position else origin + direction * definition.MaximumRange

	-- Immediate local presentation. All purely cosmetic — the impact
	-- effect specifically is NOT shown here; it waits for
	-- onFireConfirmed's server-confirmed position.
	ViewmodelController.PlayFirePresentation()
	ShotEffects.ShowMuzzleFlash(origin)
	ShotEffects.ShowTracer(origin, endPoint)
	onWeaponFired()

	local payload: NetworkTypes.NetworkPayload<CombatTypes.FireWeaponRequest> = {
		RequestId = HttpService:GenerateGUID(false),
		Timestamp = now,
		Data = {
			WeaponId = definition.Id,
			Origin = origin,
			Direction = direction,
			Timestamp = now,
		},
	}

	remote:FireServer(payload)

	Logger.Info(string.format("WeaponController: fired %s", definition.Id))
end

local function onInputBegan(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		tryFire()
	end
end

function WeaponController.Init()
	assert(RunService:IsClient(), "WeaponController.Init must only be called from the client")

	if initialized then
		Logger.Warn("WeaponController: Init called more than once, ignoring")
		return
	end
	initialized = true

	localPlayer = Players.LocalPlayer

	activeDefinition = WeaponDefinitions.Get(WeaponConfig.WeaponId)
	if not activeDefinition then
		Logger.Error(
			string.format("WeaponController: unknown WeaponId %q - firing will be disabled", WeaponConfig.WeaponId)
		)
	end

	fireWeaponRemote = RemoteRegistry.Get("FireWeapon") :: RemoteEvent

	Logger.Info("WeaponController: initialized")
end

function WeaponController.Start()
	if started then
		Logger.Warn("WeaponController: Start called more than once, ignoring")
		return
	end
	started = true

	inputBeganConnection = UserInputService.InputBegan:Connect(onInputBegan)

	local remote = fireWeaponRemote
	if remote then
		fireConfirmedConnection = remote.OnClientEvent:Connect(onFireConfirmed)
	end

	Logger.Info("WeaponController: started")
end

function WeaponController.Destroy()
	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end
	if fireConfirmedConnection then
		fireConfirmedConnection:Disconnect()
		fireConfirmedConnection = nil
	end

	initialized = false
	started = false

	Logger.Info("WeaponController: destroyed")
end

return WeaponController
