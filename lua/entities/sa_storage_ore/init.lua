AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("base_rd3_entity")

function ENT:GetPlayerLevel(ply)
	return ply.sa_data.research.ore_storage_capacity[self.MinOreManage + 1]
end

function ENT:Initialize()
	BaseClass.Initialize(self)

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

function ENT:CAF_PostInit()
	self:InitializeVars()
	self:CalcVars(self:GetTable().Founder)
end

function ENT:CalcVars(ply)
	if not self:InitializeVars() then
		self:Remove()
		return
	end

	if ply.sa_data.research.ore_storage_level[1] < self.MinOreManage then
		SA.Research.RemoveEntityWithWarning(self, "ore_storage_level", self.MinOreManage)
		return
	end

	self.IsOreStorage = true
	self:AddResource("ore", (self.StorageOffset + (self:GetPlayerLevel(ply) * self.StorageIncrement)) * ply.sa_data.advancement_level, 0)
end

function ENT:Think()
	if WireAddon then
		self:UpdateWireOutput()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Ore", self:GetResourceAmount("ore"))
	Wire_TriggerOutput(self, "Max Ore", self:GetNetworkCapacity("ore"))
end