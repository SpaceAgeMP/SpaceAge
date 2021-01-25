AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("sa_base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.damaged = 0
	self.WireDebugName = self.PrintName
	self.Outputs = Wire_CreateOutputs(self, {
	"Blue Ice",
	"Clear Ice",
	"Glacial Mass",
	"White Glaze",
	"Dark Glitter",
	"Glare Crust",
	"Gelidus",
	"Krystallos",
	"Max Blue Ice",
	"Max Clear Ice",
	"Max Glacial Mass",
	"Max White Glaze",
	"Max Dark Glitter",
	"Max Glare Crust",
	"Max Gelidus",
	"Max Krystallos"})
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.ice_raw_storage_level[1] < self.MinRawIceStorageMod then
		SA.Research.RemoveEntityWithWarning(self, "ice_raw_storage_level", self.MinRawIceStorageMod)
		return
	end

	local Capacity = math.floor(8 * (4.5 ^ self.rank)) * ply.sa_data.advancement_level

	self:AddResource("blue ice", Capacity)
	self:AddResource("clear ice", Capacity)
	self:AddResource("glacial mass", Capacity)
	self:AddResource("white glaze", Capacity)
	self:AddResource("dark glitter", Capacity)
	self:AddResource("glare crust", Capacity)
	self:AddResource("gelidus", Capacity)
	self:AddResource("krystallos", Capacity)
end

function ENT:Think()
	BaseClass.Think(self)
	self:UpdateWireOutput()
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Blue Ice", self:GetResourceAmount("blue ice"))
	Wire_TriggerOutput(self, "Clear Ice", self:GetResourceAmount("clear ice"))
	Wire_TriggerOutput(self, "Glacial Mass", self:GetResourceAmount("glacial mass"))
	Wire_TriggerOutput(self, "White Glaze", self:GetResourceAmount("white glaze"))
	Wire_TriggerOutput(self, "Dark Glitter", self:GetResourceAmount("dark glitter"))
	Wire_TriggerOutput(self, "Glare Crust", self:GetResourceAmount("glare crust"))
	Wire_TriggerOutput(self, "Gelidus", self:GetResourceAmount("gelidus"))
	Wire_TriggerOutput(self, "Krystallos", self:GetResourceAmount("krystallos"))

	Wire_TriggerOutput(self, "Max Blue Ice", self:GetNetworkCapacity("blue ice"))
	Wire_TriggerOutput(self, "Max Clear Ice", self:GetNetworkCapacity("clear ice"))
	Wire_TriggerOutput(self, "Max Glacial Mass", self:GetNetworkCapacity("glacial mass"))
	Wire_TriggerOutput(self, "Max White Glaze", self:GetNetworkCapacity("white glaze"))
	Wire_TriggerOutput(self, "Max Dark Glitter", self:GetNetworkCapacity("dark glitter"))
	Wire_TriggerOutput(self, "Max Glare Crust", self:GetNetworkCapacity("glare crust"))
	Wire_TriggerOutput(self, "Max Gelidus",  self:GetNetworkCapacity("gelidus"))
	Wire_TriggerOutput(self, "Max Krystallos", self:GetNetworkCapacity("krystallos"))
end
