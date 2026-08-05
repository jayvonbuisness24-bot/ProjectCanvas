--!strict
--[[
	Bootstrap.server.luau

	Purpose:
		Server startup entry point (TASK-002). Brings up every approved
		server Service, in order, through the Init/Start lifecycle.
		Contains no gameplay logic itself.

	Responsibilities:
		- Own the explicit, ordered list of approved Services.
		- Drive that list up via ServiceLoader.
		- Log a final startup summary.

	Public API:
		None — this is a top-level Script, never required by anything.

	Dependencies:
		shared/Framework/ServiceLoader
		shared/Framework/LifecycleTypes
		shared/Utilities/Logger

	Future Notes:
		Register new Services here as they are approved and implemented,
		e.g.:
			{ Name = "RoundService", Module = script.Parent.Services.RoundService }
		Do not require Services directly from any other script — this
		registry is the single, predictable place startup order is
		controlled from (see TASK-002_FRAMEWORK_BOOTSTRAP.md).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ServiceLoader = require(Shared:WaitForChild("Framework"):WaitForChild("ServiceLoader"))
local LifecycleTypes = require(Shared.Framework.LifecycleTypes)
local Logger = require(Shared.Utilities.Logger)

-- Explicit, ordered registry of approved server Services. Add entries
-- above the LoadAll call as each Service is approved — never auto-scan
-- src/server/Services.
local ApprovedServices: { LifecycleTypes.RegistryEntry } = {
	{ Name = "WeaponService", Module = script.Parent.Services.WeaponService },
}

local summary = ServiceLoader.LoadAll(ApprovedServices)

Logger.Info(string.format("Server bootstrap complete: %d/%d service(s) loaded", summary.Succeeded, summary.Total))

if summary.Failed > 0 then
	Logger.Error(string.format("Server bootstrap finished with %d failed service(s)", summary.Failed))
end
