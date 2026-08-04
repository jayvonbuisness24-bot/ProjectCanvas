--!strict
--[[
	Logger.luau

	Purpose:
		Centralized logging so the codebase never relies on raw print/warn
		calls scattered across files. Every message is tagged with the
		project prefix, the realm it was logged from (Server/Client), and
		its severity.

	Responsibilities:
		- Format and emit Info, Warn, Error, and Debug level messages.
		- Gate Debug output behind an explicit opt-in so it never spams
		  the output window in normal play or production.

	Public API:
		Logger.Info(...: any)
		Logger.Warn(...: any)
		Logger.Error(...: any)
		Logger.Debug(...: any)
		Logger.SetDebugEnabled(enabled: boolean)

	Dependencies:
		shared/Constants/Constants (for the log prefix).

	Future Notes:
		If structured/remote logging (e.g. shipping logs to an external
		service) is ever approved, add it here rather than introducing a
		second logging module.
]]

local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Parent.Constants.Constants)

local Logger = {}

local debugEnabled = false

local function realmTag(): string
	if RunService:IsServer() then
		return "Server"
	end
	return "Client"
end

local function formatMessage(level: string, ...: any): string
	local argCount = select("#", ...)
	local parts = table.create(argCount)
	for i = 1, argCount do
		parts[i] = tostring(select(i, ...))
	end
	return string.format("[%s][%s][%s] %s", Constants.LOG_PREFIX, realmTag(), level, table.concat(parts, " "))
end

-- Enables/disables Logger.Debug output. Intended to be called once at
-- startup (e.g. from a developer settings module) — not exposed to clients
-- as a gameplay-affecting toggle.
function Logger.SetDebugEnabled(enabled: boolean)
	debugEnabled = enabled
end

function Logger.Info(...: any)
	print(formatMessage("INFO", ...))
end

function Logger.Warn(...: any)
	warn(formatMessage("WARN", ...))
end

function Logger.Error(...: any)
	warn(formatMessage("ERROR", ...))
end

function Logger.Debug(...: any)
	if debugEnabled then
		print(formatMessage("DEBUG", ...))
	end
end

return Logger
