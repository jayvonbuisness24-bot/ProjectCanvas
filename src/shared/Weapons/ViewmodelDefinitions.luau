--!strict
--[[
	ViewmodelDefinitions.luau

	Purpose:
		Shared, weapon-agnostic registry describing available viewmodels
		by id, so ViewmodelController never hardcodes which marker it
		builds. Only one placeholder definition exists for TASK-004.

	Responsibilities:
		- Export the ViewmodelDefinition and ViewmodelConstructionMethod
		  types.
		- Resolve a definition by id.

	Public API:
		ViewmodelDefinitions.Get(id: string): ViewmodelDefinition?

	Dependencies:
		shared/Types/WeaponTypes (WeaponFamily)

	Future Notes:
		Add one entry per marker/brush/spray-can viewmodel as those
		systems are approved. PositionOffsetOverride/RotationOffsetOverride
		let a specific weapon differ from ViewmodelConfig's base offset
		without any ViewmodelController changes. AnimationSetId is
		reserved for the future animation task and is not consumed yet.
		ConstructionMethod already reserves a future "Template" value for
		a ReplicatedStorage-cloned viewmodel (TASK-004's "Option B") —
		add it only when that migration actually happens.
]]

local WeaponTypes = require(script.Parent.Parent.Types.WeaponTypes)

export type ViewmodelConstructionMethod = "PartsPlaceholder"

export type ViewmodelDefinition = {
	Id: string,
	DisplayName: string,
	WeaponFamily: WeaponTypes.WeaponFamily?,
	ConstructionMethod: ViewmodelConstructionMethod,
	RootPartName: string,
	PositionOffsetOverride: Vector3?,
	RotationOffsetOverride: Vector3?,
	-- Reserved for the future animation task; not read by TASK-004.
	AnimationSetId: string?,
}

local Definitions: { [string]: ViewmodelDefinition } = {
	default_semi_auto = {
		Id = "default_semi_auto",
		DisplayName = "Placeholder Semi-Auto Marker",
		WeaponFamily = "SemiAuto",
		ConstructionMethod = "PartsPlaceholder",
		RootPartName = "Root",
		PositionOffsetOverride = nil,
		RotationOffsetOverride = nil,
		AnimationSetId = nil,
	},
}

local ViewmodelDefinitions = {}

-- Resolves a definition by id, or nil if unknown. Callers (currently
-- just ViewmodelController) must treat nil as a recoverable failure —
-- log and skip showing a viewmodel, never hard-error.
function ViewmodelDefinitions.Get(id: string): ViewmodelDefinition?
	return Definitions[id]
end

return ViewmodelDefinitions
