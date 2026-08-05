--!strict
--[[
	WeaponService.luau

	Purpose:
		Server-authoritative validation and raycasting for the semi-auto
		marker prototype (TASK-005), extended with a confirmed-result
		response and throttled rejection logging (TASK-006). The first
		server Service, registered through the TASK-002 Bootstrap
		framework.

	Responsibilities:
		- Ensure the FireWeapon RemoteEvent exists (via RemoteRegistry).
		- Validate every FireWeapon request: payload shape, weapon id,
		  shooter's character/origin sanity, and fire rate — using the
		  server's own clock, never the client-supplied Timestamp, for
		  the rate gate.
		- Perform the authoritative raycast, ignoring the shooter's own
		  character.
		- Send a CombatTypes.FireConfirmation back to the requesting
		  player over the same FireWeapon RemoteEvent (FireClient) —
		  never damage, health, or elimination data.
		- Log fire attempts and validation failures, throttling ordinary
		  fire-rate-rejection spam without weakening the rejection itself.

	Public API:
		WeaponService.Init(): ()
		WeaponService.Start(): ()
		WeaponService.Destroy(): ()
		(Loaded only via shared/Framework/ServiceLoader — never require
		 or start this module directly.)

	Dependencies:
		shared/Config/WeaponConfig
		shared/Weapons/WeaponDefinitions
		shared/Network/{RemoteRegistry, NetworkUtils}
		shared/Types/CombatTypes
		shared/Utilities/Logger
		Players, Workspace, RunService (Roblox services)

	Future Notes:
		This intentionally reports no hit/damage back to anyone beyond
		FireConfirmation's Hit/Position/Normal — a future
		HitValidationService/damage task should read the same raycast
		result this Service already computes (or call into a shared
		raycast helper) rather than duplicating this validation chain.
		Other players currently see no indication that a shot was fired
		(no third-person tracer) — see TASK-004's note that third-person
		weapon presentation is a separate future task.

		Rejection-abuse detection reuses shared/Network/NetworkUtils'
		RateLimiter (rather than a bespoke counter) to answer "is this
		player rejecting requests at an abnormal rate" — the extra
		per-player last-warning-time is only to throttle repeat warnings,
		which the rate limiter itself doesn't do.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponConfig = require(Shared:WaitForChild("Config"):WaitForChild("WeaponConfig"))
local WeaponDefinitions = require(Shared:WaitForChild("Weapons"):WaitForChild("WeaponDefinitions"))
local RemoteRegistry = require(Shared:WaitForChild("Network"):WaitForChild("RemoteRegistry"))
local NetworkUtils = require(Shared:WaitForChild("Network"):WaitForChild("NetworkUtils"))
local CombatTypes = require(Shared.Types.CombatTypes)
local Logger = require(Shared.Utilities.Logger)

type WeaponDefinition = WeaponDefinitions.WeaponDefinition

local WeaponService = {}

-- Generous tolerance between a claimed shot Origin and the shooter's
-- own HumanoidRootPart — enough slack for the camera-vs-root offset,
-- tight enough to reject a claim of firing from an arbitrary map
-- location. Not part of any config module: this is an anti-spoof
-- implementation detail, not a tunable gameplay value.
local MAX_ORIGIN_DISTANCE_STUDS = 10

local activeDefinition: WeaponDefinition? = nil
local fireWeaponRemote: RemoteEvent? = nil
local fireEventConnection: RBXScriptConnection? = nil
local playerRemovingConnection: RBXScriptConnection? = nil

local lastFireTimeByPlayer: { [Player]: number } = {}

-- Detects "is this player rejecting requests at an abnormal rate" —
-- IsAllowed returns false once a player has been rejected more than
-- RejectedRequestWarningThreshold times within RejectedRequestWindowSeconds.
local rejectionAbuseLimiter = NetworkUtils.CreateRateLimiter(
	WeaponConfig.RejectedRequestWarningThreshold,
	WeaponConfig.RejectedRequestWindowSeconds
)
local lastAbuseWarningByPlayer: { [Player]: number } = {}

local function isValidPayloadShape(payload: any): boolean
	if typeof(payload) ~= "table" then
		return false
	end
	if typeof(payload.Timestamp) ~= "number" or typeof(payload.RequestId) ~= "string" then
		return false
	end

	local data = payload.Data
	if typeof(data) ~= "table" then
		return false
	end
	if typeof(data.WeaponId) ~= "string" then
		return false
	end
	if typeof(data.Origin) ~= "Vector3" or typeof(data.Direction) ~= "Vector3" then
		return false
	end

	return true
end

-- Ordinary fast clicking hits this branch constantly and must not flood
-- Output (Logger.Debug is silent unless SetDebugEnabled(true) was
-- called, which nothing in this codebase does). Sustained abnormal
-- rejection rates still surface as a single throttled Warn — see the
-- Future Notes header for why this reuses NetworkUtils' RateLimiter.
local function recordFireRateRejection(player: Player)
	Logger.Debug(string.format("WeaponService: %s fired faster than the configured fire rate", player.Name))

	if rejectionAbuseLimiter:IsAllowed(player) then
		return
	end

	local now = os.clock()
	local lastWarning = lastAbuseWarningByPlayer[player]
	if not lastWarning or (now - lastWarning) >= WeaponConfig.RejectedRequestWarningCooldown then
		Logger.Warn(
			string.format(
				"WeaponService: %s is rejecting FireWeapon requests at an abnormal rate (possible abuse)",
				player.Name
			)
		)
		lastAbuseWarningByPlayer[player] = now
	end
end

local function onFireWeaponRequest(player: Player, payload: any)
	local definition = activeDefinition
	if not definition then
		-- Already logged as an Error in Init; nothing to validate against.
		return
	end

	if not isValidPayloadShape(payload) then
		Logger.Warn(string.format("WeaponService: malformed FireWeapon payload from %s", player.Name))
		return
	end

	local data = payload.Data

	if data.WeaponId ~= definition.Id then
		Logger.Warn(string.format("WeaponService: %s sent unknown WeaponId %q", player.Name, tostring(data.WeaponId)))
		return
	end

	local character = player.Character
	if not character then
		Logger.Warn(string.format("WeaponService: %s fired without a character", player.Name))
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not rootPart then
		Logger.Warn(string.format("WeaponService: %s fired without a HumanoidRootPart", player.Name))
		return
	end

	if data.Direction.Magnitude < 1e-4 then
		Logger.Warn(string.format("WeaponService: %s sent a zero-length Direction", player.Name))
		return
	end

	-- Reject a claimed Origin that isn't near the shooter's own
	-- character — the server never trusts the client's Origin outright.
	if (data.Origin - rootPart.Position).Magnitude > MAX_ORIGIN_DISTANCE_STUDS then
		Logger.Warn(string.format("WeaponService: %s sent an Origin too far from their character", player.Name))
		return
	end

	local now = os.clock()
	local lastFireTime = lastFireTimeByPlayer[player]
	if lastFireTime and (now - lastFireTime) < definition.FireRate then
		recordFireRateRejection(player)
		return
	end

	local direction = data.Direction.Unit
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	local result = Workspace:Raycast(data.Origin, direction * definition.MaximumRange, raycastParams)

	-- Only commit the fire-rate window on a fully validated shot, so a
	-- rejected (too-fast) attempt never extends the next valid window.
	lastFireTimeByPlayer[player] = now

	local confirmedPosition = if result then result.Position else (data.Origin + direction * definition.MaximumRange)
	local confirmation: CombatTypes.FireConfirmation = {
		RequestId = payload.RequestId,
		Hit = result ~= nil,
		Position = confirmedPosition,
		Normal = if result then result.Normal else nil,
	}

	local remote = fireWeaponRemote
	if remote then
		remote:FireClient(player, confirmation)
	end

	local hitDescription = if result and result.Instance then result.Instance:GetFullName() else "no hit"
	Logger.Info(string.format("WeaponService: %s fired %s (%s)", player.Name, definition.Id, hitDescription))
end

function WeaponService.Init()
	assert(RunService:IsServer(), "WeaponService.Init must only be called from the server")

	activeDefinition = WeaponDefinitions.Get(WeaponConfig.WeaponId)
	if not activeDefinition then
		Logger.Error(
			string.format(
				"WeaponService: unknown WeaponId %q - FireWeapon requests will be ignored",
				WeaponConfig.WeaponId
			)
		)
	end

	-- Idempotent; WeaponService is the first Service that needs the
	-- Remotes folder/instances to exist.
	RemoteRegistry.Init()
	fireWeaponRemote = RemoteRegistry.Get("FireWeapon") :: RemoteEvent

	Logger.Info("WeaponService: initialized")
end

function WeaponService.Start()
	local remote = assert(fireWeaponRemote, "WeaponService.Start called before Init")

	fireEventConnection = remote.OnServerEvent:Connect(onFireWeaponRequest)
	playerRemovingConnection = Players.PlayerRemoving:Connect(function(player: Player)
		lastFireTimeByPlayer[player] = nil
		lastAbuseWarningByPlayer[player] = nil
		rejectionAbuseLimiter:ClearPlayer(player)
	end)

	Logger.Info("WeaponService: started")
end

function WeaponService.Destroy()
	if fireEventConnection then
		fireEventConnection:Disconnect()
		fireEventConnection = nil
	end
	if playerRemovingConnection then
		playerRemovingConnection:Disconnect()
		playerRemovingConnection = nil
	end
	lastFireTimeByPlayer = {}
	lastAbuseWarningByPlayer = {}

	Logger.Info("WeaponService: destroyed")
end

return WeaponService
