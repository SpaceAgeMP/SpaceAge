ENT.Type = "anim"
ENT.Base = "sa_base_rd3_entity"
ENT.PrintName = "Asteroid Mining Laser"

list.Set("LSEntOverlayText" , "sa_mining_laser", {HasOOO = true, num = 2, strings = {"Asteroid Mining Laser", "\nEnergy: ", "\nOre: "}, resnames = {"energy", "ore"}})

ENT.IsRanked = true
ENT.RankedVars = {
	{
		MinMiningTheory = 0,
		EnergyBase = 600,
		YieldOffset = 100,
		YieldIncrement = 12.5,

		BeamLength = 2000,
		BeamWidthOffset = 10,
	},
	{
		MinMiningTheory = 1,
		EnergyBase = 1200,
		YieldOffset = 4000,
		YieldIncrement = 25,

		BeamLength = 2250,
		BeamWidthOffset = 20,
	},
	{
		MinMiningTheory = 2,
		EnergyBase = 1800,
		YieldOffset = 12000,
		YieldIncrement = 50,

		BeamLength = 2500,
		BeamWidthOffset = 30,
	},
	{
		MinMiningTheory = 3,
		EnergyBase = 2400,
		YieldOffset = 30000,
		YieldIncrement = 100,

		BeamLength = 2750,
		BeamWidthOffset = 40,
	},
	{
		MinMiningTheory = 4,
		EnergyBase = 3000,
		YieldOffset = 60000,
		YieldIncrement = 200,

		BeamLength = 3000,
		BeamWidthOffset = 50,
	},
	{
		MinMiningTheory = 5,
		EnergyBase = 5000,
		YieldOffset = 120000,
		YieldIncrement = 400,

		BeamLength = 5000,
		BeamWidthOffset = 60,

		RequireFaction = "miners",
	},
}
