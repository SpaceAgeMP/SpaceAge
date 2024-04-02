ENT.Type = "anim"
ENT.Base = "sa_base_rd3_entity"
ENT.PrintName = "Ice Product Storage Module"
ENT.Author = "Zup"

list.Set("LSEntOverlayText" , "sa_storage_ice_product", {num = -1})

ENT.IsRanked = true
ENT.RankedVars = {
	{
		ForcedModel = "models/mandrac/hw_tank/hw_tank_large.mdl",
		MinIceProductStorageMod = 0,
	},
	{
		ForcedModel = "models/mandrac/resource_cache/hangar_container.mdl",
		MinIceProductStorageMod = 1,
	},
	{
		ForcedModel = "models/mandrac/water_storage/water_storage_large.mdl",
		MinIceProductStorageMod = 2,
	},
	{
		ForcedModel = "models/mandrac/resource_cache/colossal_cache.mdl",
		MinIceProductStorageMod = 3,
	},
	{
		ForcedModel = "models/spacebuild/medbridge2_fighterbay3.mdl",
		MinIceProductStorageMod = 4,
	},
	{
		ForcedModel = "models/slyfo/carrierbay.mdl",
		MinIceProductStorageMod = 5,
	},
	{
		ForcedModel = "models/slyfo/doublecarrier.mdl",
		MinIceProductStorageMod = 6,
		RequireFaction = "ice",
	},
}
