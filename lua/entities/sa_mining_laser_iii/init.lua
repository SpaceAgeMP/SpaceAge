AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:GetPlayerLevel(ply)
	return ply.SAData.research.ore_laser_yield[3]
end
