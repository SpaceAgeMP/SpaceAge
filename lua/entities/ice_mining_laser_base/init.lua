AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self:SetModel(self.LaserModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetColor(Color(0, 100, 255, 255))

	RD.AddResource(self, "energy", 0)
	RD.AddResource(self, "Blue Ice", 0)
	RD.AddResource(self, "Clear Ice", 0)
	RD.AddResource(self, "Glacial Mass", 0)
	RD.AddResource(self, "White Glaze", 0)
	RD.AddResource(self, "Dark Glitter", 0)
	RD.AddResource(self, "Glare Crust", 0)
	RD.AddResource(self, "Gelidus", 0)
	RD.AddResource(self, "Krystallos", 0)

	self.Inputs = Wire_CreateInputs(self, { "Activate" })
	self.Outputs = Wire_CreateOutputs(self, { "Active", "Mineral Amount", "Progress" })

	self:SetNWBool("o", false)

	self.IceCollected = {}

	self.ShouldMine = false
	self.IsMining = false
	self.NextPulse = 0

	self:CalcVars(self:GetTable().Founder)
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.ice_laser_level[1] < self.IceLaserModeMin then
		self:Remove()
	end
end

function ENT:Mine()
	--Before we do anything, lets make sure they have power!
	local EnergyUse = self.LaserConsume / self.LaserCycle
	local CurEnergy = RD.GetResourceAmount(self, "energy")

	if (CurEnergy < EnergyUse) then return end

	local ent = util.QuickTrace(self:GetPos(), self:GetUp() * self.LaserRange, self).Entity
	if ent and ent.IsIceroid then
		local Type = ent.MineralName
		if not self.IceCollected[Type] then
			self.IceCollected[Type] = 0
		end

		--Collect every think, rather than every cycle.
		local Gather = self.LaserExtract / self.LaserCycle
		local IceLeft = ent.MineralAmount * 1000
		self.IceCollected[Type] = self.IceCollected[Type] + Gather
		ent.MineralAmount = (IceLeft - Gather) / 1000

		--Oh look, our laser is full, dump it into cargo.
		if (self.IceCollected[Type] >= 1000) then
			self.IceCollected[Type] = self.IceCollected[Type] - 1000
			RD.SupplyResource(self, Type, 1)
		end

		--Energy Usage--
		RD.ConsumeResource(self, "energy", EnergyUse)

		--Updating shit--
		Wire_TriggerOutput(self, "Mineral Amount", math.floor(ent.MineralAmount * 10) / 10)
		Wire_TriggerOutput(self, "Progress", math.floor(self.IceCollected[Type] / 1000 * 1000) / 10)
		self:SetStatus(true)
	else
		self:SetStatus(false)
	end
end

function ENT:SetStatus(bool)
	self.IsMining = bool
	self:SetNWBool("o", bool)
	if (bool) then
		Wire_TriggerOutput(self, "Active", 1)
	else
		Wire_TriggerOutput(self, "Active", 0)
		Wire_TriggerOutput(self, "Mineral Amount", 0)
		Wire_TriggerOutput(self, "Progress", 0)
	end
end

function ENT:OnRemove()
	RD.RemoveRDEntity(self)
	Wire_Remove(self)
end

function ENT:Think()
	if self.ShouldMine and self.NextPulse < CurTime() then
		self:Mine()
		self.NextPulse = CurTime() + 1
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Activate") then
		if value == 1 then
			self.ShouldMine = true
		else
			self.ShouldMine = false
			self:SetStatus(false)
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
