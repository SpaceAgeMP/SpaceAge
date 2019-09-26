AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:CalcVars(self:GetTable().Founder)
	self.damaged = 0
	self.WireDebugName = self.PrintName
	self.Outputs = Wire_CreateOutputs(self, {
	"Oxygen Isotopes",
	"Hydrogen Isotopes",
	"Helium Isotopes",
	"Nitrogen Isotopes",
	"Liquid Ozone",
	"Heavy Water",
	"Strontium Clathrates",
	"Max Oxygen Isotopes",
	"Max Hydrogen Isotopes",
	"Max Helium Isotopes",
	"Max Nitrogen Isotopes",
	"Max Liquid Ozone",
	"Max Heavy Water",
	"Max Strontium Clathrates"})
end

function ENT:CalcVars(ply)
	local reqLvl = SA.Ice.GetLevelForProductStorageModel(self:GetModel())
	if ((reqLvl == nil) or (ply.SAData.Research.IceProductStorageLevel < reqLvl)) then self:Remove() return end

	local Capacity = math.floor(30000 * (2.25 ^ reqLvl)) * ply.SAData.Research.GlobalMultiplier

	RD.AddResource(self, "Oxygen Isotopes", Capacity)
	RD.AddResource(self, "Hydrogen Isotopes", Capacity)
	RD.AddResource(self, "Helium Isotopes", Capacity)
	RD.AddResource(self, "Nitrogen Isotopes", Capacity)
	RD.AddResource(self, "Liquid Ozone", Capacity)
	RD.AddResource(self, "heavy water", Capacity)
	RD.AddResource(self, "Strontium Clathrates", Capacity)

end

function ENT:Think()
	self.BaseClass.Think(self)
	self:UpdateWireOutput()
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Oxygen Isotopes", RD.GetResourceAmount(self, "Oxygen Isotopes"))
	Wire_TriggerOutput(self, "Hydrogen Isotopes", RD.GetResourceAmount(self, "Hydrogen Isotopes"))
	Wire_TriggerOutput(self, "Helium Isotopes", RD.GetResourceAmount(self, "Helium Isotopes"))
	Wire_TriggerOutput(self, "Nitrogen Isotopes", RD.GetResourceAmount(self, "Nitrogen Isotopes"))
	Wire_TriggerOutput(self, "Liquid Ozone", RD.GetResourceAmount(self, "Liquid Ozone"))
	Wire_TriggerOutput(self, "Heavy Water", RD.GetResourceAmount(self, "Heavy Water"))
	Wire_TriggerOutput(self, "Strontium Clathrates", RD.GetResourceAmount(self, "Strontium Clathrates"))

	Wire_TriggerOutput(self, "Max Oxygen Isotopes", RD.GetNetworkCapacity(self, "Oxygen Isotopes"))
	Wire_TriggerOutput(self, "Max Hydrogen Isotopes", RD.GetNetworkCapacity(self, "Hydrogen Isotopes"))
	Wire_TriggerOutput(self, "Max Helium Isotopes", RD.GetNetworkCapacity(self, "Helium Isotopes"))
	Wire_TriggerOutput(self, "Max Nitrogen Isotopes", RD.GetNetworkCapacity(self, "Nitrogen Isotopes"))
	Wire_TriggerOutput(self, "Max Liquid Ozone", RD.GetNetworkCapacity(self, "Liquid Ozone"))
	Wire_TriggerOutput(self, "Max Heavy Water", RD.GetNetworkCapacity(self, "Heavy Water"))
	Wire_TriggerOutput(self, "Max Strontium Clathrates", RD.GetNetworkCapacity(self, "Strontium Clathrates"))
end



