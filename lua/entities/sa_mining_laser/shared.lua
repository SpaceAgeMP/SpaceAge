ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Mining Laser Mk I"

list.Set("LSEntOverlayText" , "sa_mining_laser", {HasOOO = true, num = 2, strings = {"Mining Laser Mk I", "\nEnergy: ", "\nOre: "}, resnames = {"energy", "ore"}})

ENT.BeamLength = 2000
ENT.MinMiningTheory = 0
ENT.EnergyBase = 600
ENT.BeamWidthOffset = 10
ENT.YieldOffset = 50
ENT.YieldIncrement = 6.25
