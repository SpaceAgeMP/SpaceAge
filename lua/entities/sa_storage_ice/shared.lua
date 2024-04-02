ENT.Type = "anim"
ENT.Base = "sa_base_rd3_entity"
ENT.PrintName = "Raw Ice Storage Module"
ENT.Author = "Zup"

list.Set("LSEntOverlayText" , "sa_storage_ice", {num = -1})

ENT.IsRanked = true
ENT.RankedVars = {
	{
		ForcedModel = "models/mandrac/energy_cell/medium_cell.mdl",
		MinRawIceStorageMod = 0,
	},
	{
		ForcedModel = "models/mandrac/energy_cell/large_cell.mdl",
		MinRawIceStorageMod = 1,
	},
	{
		ForcedModel = "models/mandrac/resource_cache/huge_cache.mdl",
		MinRawIceStorageMod = 2,
	},
	{
		ForcedModel = "models/mandrac/nitrogen_tank/nitro_large.mdl",
		MinRawIceStorageMod = 3,
	},
	{
		ForcedModel = "models/mandrac/resource_cache/colossal_cache.mdl",
		MinRawIceStorageMod = 4,
		RequireFaction = "ice",
	}
}
