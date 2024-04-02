ENT.Type = "anim"
ENT.Base = "sa_base_rd3_entity"
ENT.PrintName = "Ice Refinery"
ENT.Author = "Zup"
ENT.Category = "Asteroid"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IsRanked = true
ENT.RankedVars = {
	{
		CycleEnergy = 2500,
		CycleTime = 5,
		CycleVol = 1,
		RefineEfficiency = 0.5,
		MinIceRefineryMod = 0,
	},
	{
		CycleEnergy = 5000,
		CycleTime = 7.5,
		CycleVol = 1,
		RefineEfficiency = 0.75,
		MinIceRefineryMod = 1,
	},
	{
		CycleEnergy = 7500,
		CycleTime = 10,
		CycleVol = 1,
		RefineEfficiency = 1,
		MinIceRefineryMod = 2,
		RequireFaction = "ice",
	},
}

list.Set("LSEntOverlayText" , "sa_ice_refinery", {HasOOO = true, num = 1, strings = {"Ice Refinery\nEnergy: ", ""}, resnames = {"energy"}})
