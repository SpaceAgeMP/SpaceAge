AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:GetCapacity(ply)
	if not (ply.sa_data.research.tiberium_storage_level[1] > 0 and (ply.sa_data.faction_name == "legion" or ply.sa_data.faction_name == "alliance")) then
		self:Remove()
	end
	return (1550000 + (ply.sa_data.research.tiberium_storage_capacity[1] * 10000)) * ply.sa_data.advancement_level
end
