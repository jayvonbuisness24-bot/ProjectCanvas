--!strict
--[[
	NetworkUtils.luau

	Purpose:
		Generic, non-gameplay-specific networking helpers for future
		remote handlers — currently a per-player rate limiter, per
		CLAUDE.md's "Use rate limiting for remote requests" rule.

	Responsibilities:
		- Provide a reusable rate-limiter factory.

	Public API:
		NetworkUtils.CreateRateLimiter(maxCalls: number, windowSeconds: number): RateLimiter
			RateLimiter:IsAllowed(player: Player): boolean
			RateLimiter:ClearPlayer(player: Player): ()

	Dependencies:
		None.

	Future Notes:
		Call RateLimiter:ClearPlayer() from PlayerRemoving in whatever
		server module owns a given limiter, to avoid unbounded growth of
		its internal table over a long-running server.
]]

local NetworkUtils = {}

export type RateLimiter = {
	IsAllowed: (self: RateLimiter, player: Player) -> boolean,
	ClearPlayer: (self: RateLimiter, player: Player) -> (),
}

-- Creates a rate limiter allowing at most `maxCalls` calls per player
-- within any rolling `windowSeconds` window.
function NetworkUtils.CreateRateLimiter(maxCalls: number, windowSeconds: number): RateLimiter
	local callTimestamps: { [Player]: { number } } = {}

	local limiter = {} :: RateLimiter

	function limiter:IsAllowed(player: Player): boolean
		local now = os.clock()
		local cutoff = now - windowSeconds

		local timestamps = callTimestamps[player]
		local kept: { number } = {}
		if timestamps then
			for _, timestamp in timestamps do
				if timestamp > cutoff then
					table.insert(kept, timestamp)
				end
			end
		end

		if #kept >= maxCalls then
			callTimestamps[player] = kept
			return false
		end

		table.insert(kept, now)
		callTimestamps[player] = kept
		return true
	end

	function limiter:ClearPlayer(player: Player)
		callTimestamps[player] = nil
	end

	return limiter
end

return NetworkUtils
