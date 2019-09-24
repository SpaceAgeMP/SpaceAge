ENT.Type = "anim"
ENT.Base = "base_wire_entity"
ENT.PrintName = "Mining Laser Base"
ENT.Author = "Zup"
ENT.Category = "Asteroid"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.LaserModel = "models/Combine_Helicopter/helicopter_bomb01.mdl"
ENT.LaserRange = 1000 --Radius
ENT.LaserExtract = 16 -- Extract per cycle m3
ENT.LaserConsume = 200 --Energy per cycle
ENT.LaserCycle = 15 --Time is second to complete a cycle
ENT.LaserActive = false

ENT.pulls = 0 --Stores minerals for the cycle
ENT.nextcycle = CurTime()
