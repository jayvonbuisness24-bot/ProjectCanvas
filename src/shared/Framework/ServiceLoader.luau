--!strict
--[[
	ServiceLoader.luau

	Purpose:
		Public loading API for src/server/Bootstrap.server.luau. Brings
		up the explicit, approved list of server Services in order.

	Responsibilities:
		- Delegate to the shared ModuleLoader engine with kind = "Service"
		  so log lines read "[Service] RoundService: loaded", etc.

	Public API:
		ServiceLoader.LoadAll(registry: { LifecycleTypes.RegistryEntry }): LifecycleTypes.LoadSummary

	Dependencies:
		shared/Framework/ModuleLoader
		shared/Framework/LifecycleTypes

	Future Notes:
		Do not add auto-discovery (e.g. scanning ServerScriptService.Server
		or src/server/Services for children) here. TASK-002 requires
		explicit, controlled registration only — new Services are added
		to Bootstrap.server.luau's registry as they are approved.
]]

local ModuleLoader = require(script.Parent.ModuleLoader)
local LifecycleTypes = require(script.Parent.LifecycleTypes)

local ServiceLoader = {}

function ServiceLoader.LoadAll(registry: { LifecycleTypes.RegistryEntry }): LifecycleTypes.LoadSummary
	return ModuleLoader.LoadAll("Service", registry)
end

return ServiceLoader
