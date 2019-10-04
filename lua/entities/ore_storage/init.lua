AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("base_rd3_entity")

local RD = CAF.GetAddon("Resource Distribution")

ENT.ForcedModel = "models/slyfo/sat_resourcetank.mdl"
ENT.MinOreManage = 0
ENT.StorageOffset = 50000
ENT.StorageIncrement = 5000

function ENT:GetPlayerLevel(ply)
	return ply.sa_data.research.ore_storage_capacity[1]
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	local ply = self:GetTable().Founder

	if not ply:IsAdmin() then
		self:SetModel(self.ForcedModel)
	end

	self:CalcVars(ply)
	if WireAddon then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self, { "Ore", "Max Ore" })
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(500)
	end
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.ore_storage_level[1] < self.MinOreManage then
		self:Remove()
		return
	end

	self.IsOreStorage = true
	RD.AddResource(self, "ore", (self.StorageOffset + (self:GetPlayerLevel(ply) * self.StorageIncrement)) * ply.sa_data.advancement_level, 0)
end

function ENT:Think()
	if WireAddon then
		self:UpdateWireOutput()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Ore", RD.GetResourceAmount(self, "ore"))
	Wire_TriggerOutput(self, "Max Ore", RD.GetNetworkCapacity(self, "ore"))
end
