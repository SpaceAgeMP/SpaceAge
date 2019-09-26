AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.ForcedModel = "models/slyfo/crate_resource_large.mdl"
ENT.MinOreManage = 4
ENT.StorageOffset = 19600000
ENT.StorageIncrement = 80000

function ENT:CalcVars(ply)
	if ply.SAData.FactionName ~= "starfleet" and ply.SAData.FactionName ~= "miners" and ply.SAData.FactionName ~= "alliance" then
		self:Remove()
		return
	end
	return self.BaseClass.CalcVars(self, ply)
end
