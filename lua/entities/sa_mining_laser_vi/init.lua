AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("sa_mining_laser")

function ENT:GetPlayerLevel(ply)
	return ply.SAData.research.ore_laser_yield[6]
end

function ENT:CalcVars(ply)
	if ply.SAData.faction_name ~= "miners" and ply.SAData.faction_name ~= "alliance" then
		self:Remove()
		return
	end
	return BaseClass.CalcVars(self, ply)
end
