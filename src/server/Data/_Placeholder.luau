--!strict
--[[
	_Placeholder.luau (server/Data)

	Purpose:
		Reserved location for player data persistence. Empty by design —
		CLAUDE.md explicitly forbids writing production data systems
		without an approved design, and TASK-001_PROJECT_FOUNDATION.md
		excludes saving from this task.

	Responsibilities:
		None yet.

	Public API:
		None. Not intended to be required.

	Dependencies:
		None.

	Future Notes:
		When implemented: use protected calls, session locking (or an
		approved equivalent), versioned schemas, and never trust
		client-supplied values, per CLAUDE.md's Data Safety rules.
]]

return {}
