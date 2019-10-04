AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:GetPlayerLevel(ply)
	return ply.sa_data.research.ore_laser_yield[4]
end
