ENT.Type = "anim"
ENT.Base = "sa_base_rd3_entity"
ENT.PrintName = "Ice Mining Laser"
ENT.Author = "Zup"
ENT.Category = "Asteroid"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.LaserModel = "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl"

list.Set("LSEntOverlayText" , "sa_ice_mining_laser", {HasOOO = true, num = 1, strings = {"Ice Mining Laser\nEnergy: ", ""}, resnames = {"energy"}})

ENT.IsRanked = true
ENT.RankedVars = {
	{
		BeamLength = 1000,
		LaserExtract = 1000 * 2,
		LaserConsume = 2400 * 2,
		LaserCycle = 60,
		IceLaserModMin = 0,
	},
	{
		BeamLength = 1200,
		LaserExtract = 1000 * 2,
		LaserConsume = 5625 * 2,
		LaserCycle = 45,
		IceLaserModMin = 1,
	},
	{
		BeamLength = 1500,
		LaserExtract = 1000 * 2,
		LaserConsume = 7245 * 2,
		LaserCycle = 30,
		IceLaserModMin = 2,
		RequireFaction = "ice",
	}
}
