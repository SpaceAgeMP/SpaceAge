AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self.vent = false
	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Inputs = { }
		self.Outputs = Wire_CreateOutputs(self, { "Permafrost", "TerraCrystal", "Dark Matter", "Max Permafrost", "Max TerraCrystal", "Max Dark Matter" })
	else
		self.Inputs = { }
	end
	RD.AddResource(self, "terracrystal", 1000000)
	RD.AddResource(self, "dark matter", 1000000)
	RD.AddResource(self, "permafrost", 1000000)
	self.caf.custom.masschangeoverride = true
	local pl = self:GetTable().Founder
	if pl and pl:IsValid() and pl:IsPlayer() and pl.SAData.TotalCredits and pl.SAData.TotalCredits < 1000000 then
		self:Remove()
		return
	end
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct(self, true)
	end
end

function ENT:UpdateMass()
end

function ENT:Think()
	self.BaseClass.Think(self)

	if WireAddon ~= nil then
		self:UpdateWireOutput()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local dm = RD.GetResourceAmount(self, "dark matter")
	local tc = RD.GetResourceAmount(self, "terracrystal")
	local pf = RD.GetResourceAmount(self, "permafrost")
	local maxdm = RD.GetNetworkCapacity(self, "dark matter")
	local maxtc = RD.GetNetworkCapacity(self, "terracrystal")
	local maxpf = RD.GetNetworkCapacity(self, "permafrost")

	Wire_TriggerOutput(self, "Dark Matter", dm)
	Wire_TriggerOutput(self, "Permafrost", pf)
	Wire_TriggerOutput(self, "TerraCrystal", tc)
	Wire_TriggerOutput(self, "Max Dark Matter", maxdm)
	Wire_TriggerOutput(self, "Max Permafrost", maxpf)
	Wire_TriggerOutput(self, "Max TerraCrystal", maxtc)
end
