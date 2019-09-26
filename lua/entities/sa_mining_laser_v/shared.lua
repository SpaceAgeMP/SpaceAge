ENT.Type = "anim"
ENT.Base = "sa_mining_laser"
ENT.PrintName = "Mining Laser Mk V"

list.Set("LSEntOverlayText" , "sa_mining_laser_v", {HasOOO = true, num = 2, strings = {"Mining Laser Mk V", "\nEnergy: ", "\nOre: "}, resnames = {"energy", "ore"}})

ENT.BeamLength = 3000
ENT.MinMiningTheory = 4
ENT.EnergyBase = 3000
ENT.BeamWidthOffset = 50
ENT.YieldOffset = 30000
ENT.YieldIncrement = 200
