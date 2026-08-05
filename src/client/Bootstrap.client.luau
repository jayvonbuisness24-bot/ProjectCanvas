--!strict
--[[
	Bootstrap.client.luau

	Purpose:
		Client startup entry point (TASK-002). Brings up every approved
		client Controller, in order, through the Init/Start lifecycle.
		Contains no gameplay logic itself.

	Responsibilities:
		- Own the explicit, ordered list of approved Controllers.
		- Drive that list up via ControllerLoader.
		- Log a final startup summary.

	Public API:
		None — this is a top-level LocalScript, never required by
		anything.

	Dependencies:
		shared/Framework/ControllerLoader
		shared/Framework/LifecycleTypes
		shared/Utilities/Logger

	Future Notes:
		Register new Controllers here as they are approved and
		implemented, e.g.:
			{ Name = "InputController", Module = script.Parent.Controllers.InputController }
		Do not require Controllers directly from any other script — this
		registry is the single, predictable place startup order is
		controlled from (see TASK-002_FRAMEWORK_BOOTSTRAP.md). Order is
		significant: entries load strictly in array order (see
		TASK-004_VIEWMODEL_SYSTEM.md).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ControllerLoader = require(Shared:WaitForChild("Framework"):WaitForChild("ControllerLoader"))
local LifecycleTypes = require(Shared.Framework.LifecycleTypes)
local Logger = require(Shared.Utilities.Logger)

-- Explicit, ordered registry of approved client Controllers. Add
-- entries above the LoadAll call as each Controller is approved — never
-- auto-scan src/client/Controllers.
local ApprovedControllers: { LifecycleTypes.RegistryEntry } = {
	{ Name = "CameraController", Module = script.Parent.Controllers.CameraController },
	{ Name = "ViewmodelController", Module = script.Parent.Controllers.ViewmodelController },
	{ Name = "WeaponController", Module = script.Parent.Controllers.WeaponController },
}

local summary = ControllerLoader.LoadAll(ApprovedControllers)

Logger.Info(string.format("Client bootstrap complete: %d/%d controller(s) loaded", summary.Succeeded, summary.Total))

if summary.Failed > 0 then
	Logger.Error(string.format("Client bootstrap finished with %d failed controller(s)", summary.Failed))
end
