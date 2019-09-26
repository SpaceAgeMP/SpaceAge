AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:GetCapacity(ply)
	if not (ply.SAData.Research.TiberiumStorageLevel > 0 and (ply.SAData.FactionName == "legion" or ply.SAData.FactionName == "alliance")) then
		self:Remove()
	end
	return (1550000 + (ply.SAData.Research.TiberiumStorageCapacity[1] * 10000)) * ply.SAData.Research.GlobalMultiplier
end
