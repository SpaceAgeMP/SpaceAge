AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("sa_mining_drill")

function ENT:GetPlayerLevel(ply)
	return ply.SAData.research.tiberium_drill_yield[2]
end

ENT.EnergyBase = 1200
ENT.YieldOffset = 100
ENT.YieldIncrement = 20
ENT.MinTibDrillMod = 1

function ENT:CalcVars(ply)
	if ply.SAData.faction_name ~= "legion" and ply.SAData.faction_name ~= "alliance" then
		self:Remove()
		return
	end
	return BaseClass.CalcVars(self, ply)
end
