AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:GetPlayerLevel(ply)
	return ply.SAData.Research.OreLaserYield[6]
end

function ENT:CalcVars(ply)
	if ply.SAData.FactionName ~= "miners" and ply.SAData.FactionName ~= "alliance" then
		self:Remove()
		return
	end
	return self.BaseClass.CalcVars(self, ply)
end
