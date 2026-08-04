--!strict
--[[
	RemoteRegistry.luau

	Purpose:
		Creates (server) and resolves (client/server) the RemoteEvent /
		RemoteFunction instances described in NetworkDefinitions, under a
		single Folder in ReplicatedStorage. Callers never construct
		Remote instances themselves.

	Responsibilities:
		- On the server, ensure the Remotes folder and every defined
		  Remote instance exist (idempotent).
		- On both realms, resolve a Remote instance by name.

	Public API:
		RemoteRegistry.Init(): ()              -- server-only, idempotent
		RemoteRegistry.Get(name: string): RemoteEvent | RemoteFunction

	Dependencies:
		shared/Constants/Constants (folder name)
		shared/Network/NetworkDefinitions (registry contents)

	Future Notes:
		NetworkDefinitions.Remotes is empty in this foundation task, so
		Init() currently only creates the empty folder. This module
		intentionally contains no validation or gameplay logic — that
		belongs in server/Networking handlers.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Parent.Constants.Constants)
local NetworkDefinitions = require(script.Parent.NetworkDefinitions)

local RemoteRegistry = {}

local remotesFolder: Folder? = nil

local function getOrCreateFolder(): Folder
	if remotesFolder then
		return remotesFolder
	end

	if RunService:IsServer() then
		local existing = ReplicatedStorage:FindFirstChild(Constants.REMOTES_FOLDER_NAME)
		if existing and existing:IsA("Folder") then
			remotesFolder = existing
		else
			local folder = Instance.new("Folder")
			folder.Name = Constants.REMOTES_FOLDER_NAME
			folder.Parent = ReplicatedStorage
			remotesFolder = folder
		end
	else
		remotesFolder = ReplicatedStorage:WaitForChild(Constants.REMOTES_FOLDER_NAME) :: Folder
	end

	return remotesFolder :: Folder
end

-- Ensures the Remotes folder and every instance described in
-- NetworkDefinitions.Remotes exist. Safe to call more than once. Must
-- only be called from the server — client code should only ever call Get.
function RemoteRegistry.Init()
	assert(RunService:IsServer(), "RemoteRegistry.Init must only be called from the server")

	local folder = getOrCreateFolder()

	for name, definition in NetworkDefinitions.Remotes do
		if not folder:FindFirstChild(name) then
			local instance: Instance
			if definition.Kind == "Event" then
				instance = Instance.new("RemoteEvent")
			else
				instance = Instance.new("RemoteFunction")
			end
			instance.Name = name
			instance.Parent = folder
		end
	end
end

-- Resolves a Remote instance by name. Blocks (up to 10s) on the client in
-- case the server hasn't replicated it yet.
function RemoteRegistry.Get(name: string): RemoteEvent | RemoteFunction
	local folder = getOrCreateFolder()
	local instance = folder:WaitForChild(name, 10)
	assert(instance ~= nil, string.format('RemoteRegistry.Get: remote "%s" was not found within timeout', name))
	return instance :: RemoteEvent | RemoteFunction
end

return RemoteRegistry
