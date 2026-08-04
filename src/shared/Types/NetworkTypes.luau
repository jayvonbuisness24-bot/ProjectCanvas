--!strict
--[[
	NetworkTypes.luau

	Purpose:
		Generic envelope type for data sent over Remotes. No gameplay
		networking exists yet — this is scaffolding for future remote
		payloads.

	Responsibilities:
		Export the NetworkPayload type.

	Public API:
		NetworkTypes.NetworkPayload<T>

	Dependencies:
		None.

	Future Notes:
		Use NetworkPayload<T> to wrap concrete payload shapes (e.g.
		NetworkPayload<DamageRequest>) once gameplay remotes are added in
		shared/Network/NetworkDefinitions.
]]

export type NetworkPayload<T> = {
	RequestId: string,
	Timestamp: number,
	Data: T,
}

return {}
