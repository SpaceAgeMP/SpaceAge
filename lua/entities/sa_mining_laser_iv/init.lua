AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:GetPlayerLevel(ply)
	return ply.SAData.Research.OreLaserYield[4]
end
