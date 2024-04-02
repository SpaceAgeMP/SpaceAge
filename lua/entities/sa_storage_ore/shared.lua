ENT.Type = "anim"
ENT.Base = "sa_base_rd3_entity"
ENT.PrintName = "Ore Storage"

list.Set("LSEntOverlayText", "sa_storage_ore", {HasOOO = nil, num = 1, strings = {"Ore Storage\nOre: ", ""}, resnames = {"ore"}})

ENT.IsRanked = true
ENT.RankedVars = {
	{
		ForcedModel = "models/slyfo/sat_resourcetank.mdl",
		MinOreManage = 0,
		StorageOffset = 50000,
		StorageIncrement = 5000,
	},
	{
		ForcedModel = "models/slyfo/nacshortsleft.mdl",
		MinOreManage = 1,
		StorageOffset = 1600000,
		StorageIncrement = 10000,
	},
	{
		ForcedModel = "models/slyfo/nacshuttleright.mdl",
		MinOreManage = 2,
		StorageOffset = 4600000,
		StorageIncrement = 20000,
	},
	{
		ForcedModel = "models/slyfo/crate_resource_small.mdl",
		MinOreManage = 3,
		StorageOffset = 9600000,
		StorageIncrement = 40000,
	},
	{
		ForcedModel = "models/slyfo/crate_resource_large.mdl",
		MinOreManage = 4,
		StorageOffset = 19600000,
		StorageIncrement = 80000,
		RequireFaction = "miners",
	}
}
