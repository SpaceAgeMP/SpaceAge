AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:GetPlayerLevel(ply)
	return ply.SAData.Research.TiberiumDrillYield[2]
end

ENT.EnergyBase = 1200
ENT.YieldOffset = 100
ENT.YieldIncrement = 20
ENT.MinTibDrillMod = 1

function ENT:CalcVars(ply)
	if ply.SAData.FactionName ~= "legion" and ply.SAData.FactionName ~= "alliance" then
		self:Remove()
		return
	end
	return self.BaseClass.CalcVars(ply)
end
