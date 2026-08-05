--!strict
--[[
	TestArenaConfig.luau

	Purpose:
		Configuration for the temporary First Playable test arena
		(TASK-007) — spawn placement, zone identity colors, and the
		distance-marker list. Everything here is development-only, not
		final map/art direction.

	Responsibilities:
		Export a single, typed TestArenaConfig table.

	Public API:
		TestArenaConfig.ArenaRootName: string
		TestArenaConfig.SpawnPositions: { CFrame }
		TestArenaConfig.DistanceMarkerDistances: { number }
		TestArenaConfig.Colors: { ... }

	Dependencies:
		None.

	Future Notes:
		Only genuinely reusable/tunable values live here (spawn
		placement, zone colors, marker distances) — per-part blockout
		geometry (wall sizes, cover positions) stays local to
		server/TestArena/ArenaBuilder.luau as named constants, the same
		way ViewmodelController keeps its own part-offset constants
		local rather than in ViewmodelConfig. This arena, and this
		config, are meant to be deleted wholesale once a real map exists
		— do not build permanent gameplay architecture on top of it.
]]

export type TestArenaConfig = {
	ArenaRootName: string,
	SpawnPositions: { CFrame },
	DistanceMarkerDistances: { number },
	Colors: {
		Neutral: Color3,
		SpawnGroupA: Color3,
		SpawnGroupB: Color3,
		LongRangeLane: Color3,
		ElevatedArea: Color3,
		Cover: Color3,
	},
}

local TestArenaConfig: TestArenaConfig = {
	-- Name of the Model this generates under Workspace, and the marker
	-- GenerateTestArena.server.luau checks to detect/replace an
	-- existing arena.
	ArenaRootName = "TestArena",

	-- Four spawns in two pairs, tucked into the Close-Range (east) and
	-- Medium-Range (south) entrances — opposite sides of the central
	-- hub, separated by cover, not facing each other. See
	-- ArenaBuilder's Future Notes for the coordinate convention.
	SpawnPositions = {
		CFrame.new(40, 0.6, 8) * CFrame.Angles(0, math.rad(90), 0),
		CFrame.new(40, 0.6, -8) * CFrame.Angles(0, math.rad(90), 0),
		CFrame.new(0, 0.6, -40) * CFrame.Angles(0, math.rad(180), 0),
		CFrame.new(10, 0.6, -40) * CFrame.Angles(0, math.rad(180), 0),
	},

	-- Studs down the Long-Range Lane. Not final — just readable
	-- reference points for range/tracer validation.
	DistanceMarkerDistances = { 10, 25, 50, 100 },

	-- Development readability only — not final art direction.
	Colors = {
		Neutral = Color3.fromRGB(140, 140, 145),
		SpawnGroupA = Color3.fromRGB(60, 120, 220), -- blue
		SpawnGroupB = Color3.fromRGB(200, 70, 70), -- red
		LongRangeLane = Color3.fromRGB(210, 190, 60), -- yellow
		ElevatedArea = Color3.fromRGB(70, 170, 90), -- green
		Cover = Color3.fromRGB(110, 110, 115),
	},
}

return TestArenaConfig
