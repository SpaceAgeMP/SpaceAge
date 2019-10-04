AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("ore_storage")

ENT.ForcedModel = "models/slyfo/crate_resource_large.mdl"
ENT.MinOreManage = 4
ENT.StorageOffset = 19600000
ENT.StorageIncrement = 80000

function ENT:CalcVars(ply)
	if ply.sa_data.faction_name ~= "starfleet" and ply.sa_data.faction_name ~= "miners" and ply.sa_data.faction_name ~= "alliance" then
		self:Remove()
		return
	end
	return self.CalcVars(self, ply)
end
