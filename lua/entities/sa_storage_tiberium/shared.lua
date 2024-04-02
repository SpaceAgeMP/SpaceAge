ENT.Type = "anim"
ENT.Base = "sa_base_rd3_entity"
ENT.PrintName = "Tiberium Storage"

list.Set("LSEntOverlayText" , "sa_storage_tiberium", {HasOOO = nil, num = 1, strings = {"Tiberium Storage\nTiberium: ", ""}, resnames = {"tiberium"}})

ENT.IsRanked = true
ENT.RankedVars = {
	{
		MinTiberiumStorageMod = 0,
		StorageOffset = 50000,
		StorageIncrement = 5000
	},
	{
		MinTiberiumStorageMod = 1,
		StorageOffset = 1550000,
		StorageIncrement = 10000,
		RequireFaction = "legion",
	},
}
