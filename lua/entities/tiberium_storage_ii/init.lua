AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:GetCapacity(ply)
	if not (ply.SAData.research.tiberium_storage_level[1] > 0 and (ply.SAData.faction_name == "legion" or ply.SAData.faction_name == "alliance")) then
		self:Remove()
	end
	return (1550000 + (ply.SAData.research.tiberium_storage_capacity[1] * 10000)) * ply.SAData.advancement_level
end
