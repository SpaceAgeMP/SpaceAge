ENT.Type = "anim"
ENT.Base = "sa_base_rd3_entity"
ENT.PrintName = "Mining Drill"

list.Set("LSEntOverlayText" , "sa_mining_drill", {HasOOO = true, num = 2, strings = {"Mining Drill", "\nEnergy: ", "\nTiberium: "}, resnames = {"energy", "tiberium"}})

ENT.IsRanked = true
ENT.RankedVars = {
	{
		EnergyBase = 600,
		YieldOffset = 50,
		YieldIncrement = 10,
		MinTibDrillMod = 0,
	},
	{
		EnergyBase = 1200,
		YieldOffset = 100,
		YieldIncrement = 20,
		MinTibDrillMod = 1,
		RequireFaction = "legion",
	},
}
