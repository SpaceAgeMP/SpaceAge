AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("sa_base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetNWBool("o", false)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end

	self:AddResource("energy", 0)
	self:AddResource("liquid nitrogen", 0)
	self:AddResource("water", 0)
	self:AddResource("heavy water", 0)

	for type, _ in pairs(SA.Ice.Types) do
		self:AddResource(type, 0)
	end

	self:AddResource("oxygen isotopes", 0)
	self:AddResource("hydrogen isotopes", 0)
	self:AddResource("helium isotopes", 0)
	self:AddResource("nitrogen isotopes", 0)
	self:AddResource("carbon isotopes", 0)
	self:AddResource("strontium clathrates", 0)

	self.Inputs = Wire_CreateInputs(self, { "On" })
	self.Outputs = Wire_CreateOutputs(self, { "On", "Active", "Progress" })

	self.Active = 0
	self.CurrentRef = nil
	self.Volume = 0
	self.NextCycle = 0
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.ice_refinery_level[1] < self.MinIceRefineryMod then
		SA.Research.RemoveEntityWithWarning(self, "ice_refinery_level", self.MinIceRefineryMod)
	end
end

function ENT:Refine()
	local own = self:CPPIGetOwner()
	if not IsValid(own) or own.IsAFK then return end

	if not self.CurrentRef then
		for type, _ in pairs(SA.Ice.Types) do
			local Avail = self:GetResourceAmount(type)
			if (Avail > 0) then
				self.CurrentRef = type
				self.Volume = 1000
				self:ConsumeResource(type, 1)
				Wire_TriggerOutput(self, "Active", 1)
				break
			end
		end
	end

	if self.CurrentRef then
		local EnergyReq = self.CycleEnergy / self.CycleTime
		if self:ConsumeResource("energy", EnergyReq) < EnergyReq then
			self:TurnOff()
			return
		end

		local RefSpeed = (self.CycleVol / self.CycleTime) * 1000
		self.Volume = self.Volume - RefSpeed
		local Progress = math.Clamp((1000-self.Volume) / 10, 0, 100)
		Wire_TriggerOutput(self, "Progress", Progress)
		if (self.Volume <= 0) then
			local gives = SA.Ice.GetRefined(own, self.CurrentRef, self.RefineEfficiency)
			for res, count in pairs(gives) do
				self:SupplyResource(res, count)
			end
			self.CurrentRef = nil
			Wire_TriggerOutput(self, "Active", 0)
			Wire_TriggerOutput(self, "Progress", 0)
		end
	end
end

function ENT:Think()
	BaseClass.Think(self)

	if self.Active == 1 and self.NextCycle < CurTime() then
		self:Refine()
		self.NextCycle = CurTime() + 1
	end
end

function ENT:TurnOn()
	if self.Active == 0 then
		self.Active = 1
		Wire_TriggerOutput(self, "On", 1)
		self:SetOOO(1)
		self:SetNWBool("o", true)
	end
end

function ENT:TurnOff()
	if self.Active == 1 then
		self.Active = 0
		Wire_TriggerOutput(self, "Active", 0)
		Wire_TriggerOutput(self, "Progress", 0)
		Wire_TriggerOutput(self, "On", 0)
		self:SetOOO(0)
		self:SetNWBool("o", false)
		self.CurrentRef = nil
		self.Volume = 0
		self.NextCycle = 0
	end
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value == 1 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end
