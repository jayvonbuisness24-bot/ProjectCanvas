--!strict
--[[
	ControllerLoader.luau

	Purpose:
		Public loading API for src/client/Bootstrap.client.luau. Brings
		up the explicit, approved list of client Controllers in order.

	Responsibilities:
		- Delegate to the shared ModuleLoader engine with kind =
		  "Controller" so log lines read "[Controller] CameraController:
		  loaded", etc.

	Public API:
		ControllerLoader.LoadAll(registry: { LifecycleTypes.RegistryEntry }): LifecycleTypes.LoadSummary

	Dependencies:
		shared/Framework/ModuleLoader
		shared/Framework/LifecycleTypes

	Future Notes:
		Do not add auto-discovery (e.g. scanning StarterPlayerScripts.Client
		or src/client/Controllers for children) here. TASK-002 requires
		explicit, controlled registration only — new Controllers are
		added to Bootstrap.client.luau's registry as they are approved.
]]

local ModuleLoader = require(script.Parent.ModuleLoader)
local LifecycleTypes = require(script.Parent.LifecycleTypes)

local ControllerLoader = {}

function ControllerLoader.LoadAll(registry: { LifecycleTypes.RegistryEntry }): LifecycleTypes.LoadSummary
	return ModuleLoader.LoadAll("Controller", registry)
end

return ControllerLoader
