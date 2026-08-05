--!strict
--[[
	LifecycleTypes.luau

	Purpose:
		Shared type definitions for the Init/Start/Destroy lifecycle
		convention used by server Services and client Controllers, and
		for the results ModuleLoader reports back to Bootstrap scripts.

	Responsibilities:
		- Define the optional-method shape a lifecycle module may
		  implement (LifecycleModule).
		- Define one registry entry (a name paired with the ModuleScript
		  to require).
		- Define the per-module and aggregate results a load pass
		  produces.

	Public API:
		LifecycleTypes.LifecycleStage
		LifecycleTypes.LifecycleModule
		LifecycleTypes.RegistryEntry
		LifecycleTypes.LoadEntry
		LifecycleTypes.LoadSummary

	Dependencies:
		None.

	Future Notes:
		Destroy is part of the convention but is not invoked by TASK-002's
		Bootstrap scripts (startup-only). Whichever future system adds
		teardown (e.g. a server game:BindToClose handler, or per-player
		controller cleanup) should reuse RegistryEntry/LifecycleModule
		rather than defining a second lifecycle shape.
]]

export type LifecycleStage = "Init" | "Start" | "Destroy"

-- A Service or Controller ModuleScript may optionally implement any of
-- these functions. None are required — a module implementing none of
-- them is valid (e.g. a pure data module) but pointless to register.
export type LifecycleModule = {
	Init: (() -> ())?,
	Start: (() -> ())?,
	Destroy: (() -> ())?,
	[any]: any,
}

-- One registry entry: a human-readable name (used in logs) paired with
-- the ModuleScript instance Bootstrap should require.
export type RegistryEntry = {
	Name: string,
	Module: ModuleScript,
}

-- Per-module outcome from one load pass.
export type LoadEntry = {
	Name: string,
	Succeeded: boolean,
	FailedStage: LifecycleStage?,
	Error: string?,
}

-- Aggregate result of a full ModuleLoader.LoadAll pass, used by
-- Bootstrap scripts to log a startup summary.
export type LoadSummary = {
	Total: number,
	Succeeded: number,
	Failed: number,
	Entries: { LoadEntry },
}

return {}
