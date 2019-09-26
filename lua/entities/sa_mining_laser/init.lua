AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

util.PrecacheSound("common/warning.wav")
util.PrecacheSound("ambient/energy/electric_loop.wav")

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD.AddResource(self, "energy", 0, 0)
	RD.AddResource(self, "ore", 0, 0)
	self.Active = 0
	self.damage = 16

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "Output" })
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(120)
		phys:Wake()
	end
	self.lasersound = CreateSound(self, "ambient/energy/electric_loop.wav")

	self:CalcVars(self:GetTable().Founder)
end

function ENT:GetPlayerLevel(ply)
	return ply.SAData.Research.OreLaserYield[1]
end

function ENT:CalcVars(ply)
	if ply.SAData.Research.OreLaserLevel < self.MinMiningTheory then
		self:Remove()
		return
	end

	local miningmod = 1
	if ply.SAData.FactionName == "miners" or ply.SAData.FactionName == "alliance" then
		miningmod = 1.33
	elseif ply.SAData.FactionName == "starfleet" then
		miningmod = 1.11
	end
	local level = self:GetPlayerLevel(ply)
	self:SetNWInt("level", level)

	local energycost = ply.SAData.Research.MiningEnergyEfficiency * 50
	if (energycost > self.EnergyBase * 0.75) then
		energycost = self.EnergyBase * 0.75
	end
	self.consume = self.EnergyBase - energycost
	self.yield = math.floor((self.YieldOffset + (level * self.YieldIncrement)) * miningmod) * 2
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		if (RD.GetResourceAmount(self, "energy") < self.consume) then
			self:TurnOff()
			return
		end
		self.lasersound:Play()
		if WireAddon then
			Wire_TriggerOutput(self, "On", 1)
		end
		self:SetOOO(1)
		self:SetNWBool("o", true)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self.lasersound:Stop()
		if WireAddon then
			Wire_TriggerOutput(self, "On", 0)
		end
		self:SetOOO(0)
		self:SetNWBool("o", false)
	end
end

function ENT:OnRemove()
	self.lasersound:Stop()
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if (self.Active == 1) then
			if (RD.GetResourceAmount(self, "energy") >= self.consume) then
				RD.ConsumeResource(self, "energy", self.consume)
				SA.Functions.Discharge(self)
				Wire_TriggerOutput(self, "Output", self.yield)
			else
				self:TurnOff()
				Wire_TriggerOutput(self, "Output", 0)
			end
	else
		self:TurnOff()
		Wire_TriggerOutput(self, "Output", 0)
	end
	self:NextThink(CurTime() + 1)
	return true
end
