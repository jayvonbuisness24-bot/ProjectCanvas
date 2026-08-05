--!strict
--[[
	ModuleLoader.luau

	Purpose:
		Internal engine shared by ServiceLoader and ControllerLoader so
		the require -> Init -> Start -> log sequence is written once.
		Not intended to be required directly by Bootstrap scripts — use
		ServiceLoader or ControllerLoader instead.

	Responsibilities:
		- Require each registered module, in order.
		- Call Init() then Start() on each module, if implemented.
		- Isolate failures per module so one broken module cannot stop
		  the rest of the registry from loading, and never hide an
		  error behind an empty pcall.
		- Build a LoadSummary describing what succeeded/failed.

	Public API:
		ModuleLoader.LoadAll(kind: string, registry: { LifecycleTypes.RegistryEntry }): LifecycleTypes.LoadSummary
			`kind` is a label ("Service" / "Controller") used only to
			prefix log lines so server/client output reads clearly.

	Dependencies:
		shared/Utilities/Logger
		shared/Framework/LifecycleTypes

	Future Notes:
		Destroy() is intentionally not called here — TASK-002 only
		covers startup. A future teardown system should walk the same
		registry and call Destroy() the same way LoadAll calls Init/Start.
]]

local Logger = require(script.Parent.Parent.Utilities.Logger)
local LifecycleTypes = require(script.Parent.LifecycleTypes)

type LifecycleModule = LifecycleTypes.LifecycleModule
type RegistryEntry = LifecycleTypes.RegistryEntry
type LoadEntry = LifecycleTypes.LoadEntry
type LoadSummary = LifecycleTypes.LoadSummary

local ModuleLoader = {}

-- Calls `stageName` on `module` if it exists and is a function. Returns
-- true if the stage doesn't exist (nothing to do) or ran without error;
-- returns false + the stringified error if it exists but threw. Never
-- lets a thrown error escape uncaught — that's what would let one
-- module silently break the rest of Bootstrap.
local function callStage(module: LifecycleModule, stageName: "Init" | "Start"): (boolean, string?)
	local fn = module[stageName]
	if typeof(fn) ~= "function" then
		return true, nil
	end

	local ok, err = pcall(fn)
	if ok then
		return true, nil
	end
	return false, tostring(err)
end

-- Requires and starts every entry in `registry`, in array order. A
-- module whose Init fails has its own Start skipped (there is nothing
-- safe to start), but unrelated modules later in the registry still
-- load — no cross-module dependency graph is assumed beyond that.
function ModuleLoader.LoadAll(kind: string, registry: { RegistryEntry }): LoadSummary
	local entries: { LoadEntry } = table.create(#registry)
	local succeeded = 0

	for _, entry in registry do
		local requireOk, requiredOrErr = pcall(require, entry.Module)

		if not requireOk then
			local errText = tostring(requiredOrErr)
			Logger.Error(string.format("[%s] %s: failed to require - %s", kind, entry.Name, errText))
			table.insert(entries, {
				Name = entry.Name,
				Succeeded = false,
				FailedStage = "Init" :: LifecycleTypes.LifecycleStage, -- closest stage; it never reached Init
				Error = errText,
			})
			continue
		end

		local module = requiredOrErr :: LifecycleModule

		local initOk, initErr = callStage(module, "Init")
		if not initOk then
			Logger.Error(string.format("[%s] %s: Init failed - %s", kind, entry.Name, initErr :: string))
			table.insert(entries, {
				Name = entry.Name,
				Succeeded = false,
				FailedStage = "Init",
				Error = initErr,
			})
			continue
		end

		local startOk, startErr = callStage(module, "Start")
		if not startOk then
			Logger.Error(string.format("[%s] %s: Start failed - %s", kind, entry.Name, startErr :: string))
			table.insert(entries, {
				Name = entry.Name,
				Succeeded = false,
				FailedStage = "Start",
				Error = startErr,
			})
			continue
		end

		Logger.Info(string.format("[%s] %s: loaded", kind, entry.Name))
		succeeded += 1
		table.insert(entries, {
			Name = entry.Name,
			Succeeded = true,
			FailedStage = nil,
			Error = nil,
		})
	end

	return {
		Total = #registry,
		Succeeded = succeeded,
		Failed = #registry - succeeded,
		Entries = entries,
	}
end

return ModuleLoader
