--!strict
--[[
	CameraController.luau

	Purpose:
		Owns first-person camera behavior for the local player (TASK-003).
		The first real Controller registered through the TASK-002 Bootstrap
		framework.

	Responsibilities:
		- Force first-person camera mode and center-lock the mouse.
		- Apply the default field of view from CameraConfig and reapply it
		  whenever Roblox replaces CurrentCamera (e.g. on respawn).
		- Locally hide the parts that would otherwise obstruct the
		  first-person view (own head, own accessories) without touching
		  server-authoritative Transparency, so other players still see
		  the character normally.
		- Bind/unbind cleanly across CharacterAdded / CharacterRemoving so
		  no connections or camera state duplicate across respawns.

	Public API:
		CameraController.Init(): ()
		CameraController.Start(): ()
		CameraController.Destroy(): ()
		(Loaded only via shared/Framework/ControllerLoader — never require
		 or start this module directly.)

	Dependencies:
		shared/Config/CameraConfig
		shared/Utilities/Logger
		Players, UserInputService, RunService, Workspace (Roblox services)

	Future Notes:
		This does not take over camera rendering — it rides Roblox's
		built-in LockFirstPerson camera and Humanoid.CameraOffset instead
		of replacing the camera update loop, per TASK-003's "avoid
		fighting Roblox's camera without a clear reason." Future camera
		layers (recoil, shake, lean, head bob) should sum their
		contribution into Humanoid.CameraOffset — see the reset in
		onCharacterAdded — rather than introducing a second
		camera-driving system. Sprint/ADS/
		Spectator/Final Play FOV overrides should call setFieldOfView the
		same way applyCameraSettings does, rather than setting
		FieldOfView directly elsewhere.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Controllers live under StarterPlayerScripts.Client, a separate service
-- tree from ReplicatedStorage.Shared — script.Parent chains can't reach
-- Shared, so resolve it the same way Bootstrap.client.luau does.
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CameraConfig = require(Shared:WaitForChild("Config"):WaitForChild("CameraConfig"))
local Logger = require(Shared.Utilities.Logger)

local CameraController = {}

-- Per-character state so CharacterRemoving can fully undo what
-- CharacterAdded set up, and a respawn never doubles up connections.
type CharacterState = {
	AccessoryAddedConnection: RBXScriptConnection?,
	HiddenParts: { BasePart },
}

local localPlayer: Player? = nil
local currentCameraConnection: RBXScriptConnection? = nil
local characterAddedConnection: RBXScriptConnection? = nil
local characterRemovingConnection: RBXScriptConnection? = nil
local activeCharacterState: CharacterState? = nil

-- Applies the (currently single, future-extensible) default field of
-- view. Centralized here so future ADS/Sprint/Spectator/Final Play FOV
-- overrides have one obvious place to call into rather than setting
-- Camera.FieldOfView ad hoc from elsewhere.
local function setFieldOfView(camera: Camera, fov: number)
	camera.FieldOfView = fov
end

-- Reapplies camera settings that depend on workspace.CurrentCamera.
-- Called once at Start() and again every time Roblox swaps in a new
-- Camera instance (this happens on most respawns), so a temporarily-nil
-- CurrentCamera never leaves FOV unset on the replacement camera.
local function applyCameraSettings()
	local camera = Workspace.CurrentCamera
	if not camera then
		-- Expected transiently around respawn; the CurrentCamera
		-- changed-signal below will call this again once Roblox
		-- assigns a new one.
		return
	end

	setFieldOfView(camera, CameraConfig.DefaultFieldOfView)
end

-- Locally hides one BasePart (head or accessory handle) via
-- LocalTransparencyModifier — a client-only rendering property that
-- never replicates and never touches the server-authoritative
-- Transparency, so other players' view of this character is unaffected.
local function hidePartLocally(part: BasePart, state: CharacterState)
	part.LocalTransparencyModifier = 1
	table.insert(state.HiddenParts, part)
end

local function hideAccessory(accessory: Instance, state: CharacterState)
	local handle = accessory:FindFirstChildWhichIsA("BasePart")
	if handle then
		hidePartLocally(handle, state)
	end
end

-- Binds first-person-obstruction hiding for one freshly spawned
-- character: the head (if enabled) and every accessory present or
-- added later (if enabled). Resets CameraOffset to a clean baseline —
-- see the Future Notes header for how later camera layers should
-- extend this rather than replace it.
local function onCharacterAdded(character: Model)
	local state: CharacterState = {
		AccessoryAddedConnection = nil,
		HiddenParts = {},
	}
	activeCharacterState = state

	local humanoid = character:WaitForChild("Humanoid", 5) :: Humanoid?
	if humanoid then
		-- Clean baseline for future recoil/shake/lean/head-bob layers to
		-- sum into; TASK-003 itself applies no offset.
		humanoid.CameraOffset = Vector3.zero
	else
		Logger.Warn("CameraController: Humanoid not found on character within timeout")
	end

	if CameraConfig.HideLocalHead then
		local head = character:WaitForChild("Head", 5) :: BasePart?
		if head then
			hidePartLocally(head, state)
		else
			Logger.Warn("CameraController: Head not found on character within timeout")
		end
	end

	if CameraConfig.HideLocalAccessories then
		for _, child in character:GetChildren() do
			if child:IsA("Accessory") then
				hideAccessory(child, state)
			end
		end

		-- Avatars can finish loading accessories after CharacterAdded
		-- fires; catch those without polling every frame.
		state.AccessoryAddedConnection = character.ChildAdded:Connect(function(child)
			if child:IsA("Accessory") then
				hideAccessory(child, state)
			end
		end)
	end

	Logger.Info("CameraController: character bound")
end

-- Undoes exactly what onCharacterAdded set up: disconnects the
-- accessory-watch connection and restores every part's local
-- transparency, so nothing leaks or duplicates into the next respawn.
local function onCharacterRemoving()
	local state = activeCharacterState
	if not state then
		return
	end

	if state.AccessoryAddedConnection then
		state.AccessoryAddedConnection:Disconnect()
	end

	for _, part in state.HiddenParts do
		if part and part.Parent then
			part.LocalTransparencyModifier = 0
		end
	end

	activeCharacterState = nil
end

function CameraController.Init()
	assert(RunService:IsClient(), "CameraController.Init must only be called from the client")

	localPlayer = Players.LocalPlayer
	Logger.Info("CameraController: initialized")
end

function CameraController.Start()
	local player = assert(localPlayer, "CameraController.Start called before Init")

	if CameraConfig.FirstPersonEnabled then
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end

	if CameraConfig.MouseLockEnabled then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end

	currentCameraConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(applyCameraSettings)
	applyCameraSettings()

	characterAddedConnection = player.CharacterAdded:Connect(onCharacterAdded)
	characterRemovingConnection = player.CharacterRemoving:Connect(onCharacterRemoving)

	-- Handle the case where Start() runs after the character already
	-- exists (e.g. a slow Controller load) — CharacterAdded won't fire
	-- again for it, so bind it once here instead.
	if player.Character then
		onCharacterAdded(player.Character)
	end

	Logger.Info("CameraController: started")
end

function CameraController.Destroy()
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

	onCharacterRemoving()

	if localPlayer then
		localPlayer.CameraMode = Enum.CameraMode.Classic
	end
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	Logger.Info("CameraController: destroyed")
end

return CameraController
