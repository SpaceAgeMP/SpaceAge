AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

local IceTypes = {
	"Blue Ice",
	"Clear Ice",
	"Glacial Mass",
	"White Glaze",
	"Dark Glitter",
	"Glare Crust",
	"Gelidus",
	"Krystallos"
}

local GiveTranslate = {
	liquidnitrogen = "liquid nitrogen",
	heavywater = "heavy water",
	water = "water",
	oxygen = "Oxygen Isotopes",
	hydrogen = "Hydrogen Isotopes",
	helium = "Helium Isotopes",
	nitrogen = "Nitrogen Isotopes",
	ozone = "Liquid Ozone",
	strontium = "Strontium Clathrates"
}

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end

	RD.AddResource(self, "energy", 0)
	RD.AddResource(self, "liquid nitrogen", 0)
	RD.AddResource(self, "water", 0)
	RD.AddResource(self, "heavy water", 0)

	for _, Type in pairs(IceTypes) do
		RD.AddResource(self, Type, 0)
	end

	RD.AddResource(self, "Oxygen Isotopes", 0)
	RD.AddResource(self, "Hydrogen Isotopes", 0)
	RD.AddResource(self, "Helium Isotopes", 0)
	RD.AddResource(self, "Nitrogen Isotopes", 0)
	RD.AddResource(self, "Liquid Ozone", 0)
	RD.AddResource(self, "Strontium Clathrates", 0)

	self:SetOverlayText(self.PrintName .. "\n" .. "Progress: 0%")

	self.Inputs = Wire_CreateInputs(self, { "Activate" })
	self.Outputs = Wire_CreateOutputs(self, { "Active", "Progress" })

	self.ShouldRefine = false;
	self.CurrentRef = nil;
	self.Volume = 0;
	self.NextCycle = 0;

	self:CalcVars(self:GetTable().Founder)
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.ice_refinery_level[1] < self.MinIceRefineryMod then
		return self:Remove()
	end
end

function ENT:Refine()
	local CurEnergy = RD.GetResourceAmount(self, "energy")
	local EnergyReq = self.CycleEnergy / self.CycleTime

	if (CurEnergy > EnergyReq) then
		if not self.CurrentRef then
			for _, Type in pairs(IceTypes) do
				local Avail = RD.GetResourceAmount(self, Type)
				if (Avail > 0) then
					self.CurrentRef = Type
					self.Volume = 1000
					RD.ConsumeResource(self, Type, 1)
					Wire_TriggerOutput(self, "Active", 1)
					break
				end
			end
		end
		if (self.CurrentRef) then
			RD.ConsumeResource(self, "energy", EnergyReq)

			local RefSpeed = (self.CycleVol / self.CycleTime) * 1000
			self.Volume = self.Volume - RefSpeed
			local Progress = math.Clamp((1000-self.Volume) / 10, 0, 100)
			Wire_TriggerOutput(self, "Progress", Progress)
			self:SetOverlayText(self.PrintName .. "\nProgress: " .. tostring(Progress) .. "%")
			if (self.Volume <= 0) then
				local Gives = SA.Ice.GetRefined(self.CurrentRef, self.RefineEfficiency)
				for Res, Count in pairs(Gives) do
					RD.SupplyResource(self, GiveTranslate[Res], Count)
				end
				self.CurrentRef = nil
				Wire_TriggerOutput(self, "Active", 0)
				Wire_TriggerOutput(self, "Progress", 0)
				self:SetOverlayText(self.PrintName .. "\nProgress: 0%")
			end
		end
	end
end

function ENT:Think()
	if (self.ShouldRefine and self.NextCycle < CurTime()) then
		self:Refine()
		self.NextCycle = CurTime() + 1
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Activate") then
		if value == 1 then
			self.ShouldRefine = true
		else
			self.ShouldRefine = false
			Wire_TriggerOutput(self, "Active", 0)
			Wire_TriggerOutput(self, "Progress", 0)
			self:SetOverlayText(self.PrintName .. "\nProgress: 0%")
		end
	end
end

function ENT:PreEntityCopy()
	RD.BuildDupeInfo(self)
	local DupeInfo = self:BuildDupeInfo()
	if DupeInfo then
		duplicator.StoreEntityModifier(self, "WireDupeInfo", DupeInfo)
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	RD.ApplyDupeInfo(Ent, CreatedEntities)
	if Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		self.Owner = ply
		Ent:ApplyDupeInfo(ply, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
