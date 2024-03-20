AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

util.PrecacheSound("common/warning.wav")
util.PrecacheSound("ambient/energy/electric_loop.wav")

DEFINE_BASECLASS("sa_base_rd3_entity")

include("shared.lua")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:AddResource("energy", 0, 0)
	self:AddResource("ore", 0, 0)
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
end

function ENT:GetPlayerLevel(ply)
	return ply.sa_data.research.ore_laser_yield[self.MinMiningTheory + 1]
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.ore_laser_level[1] < self.MinMiningTheory then
		SA.Research.RemoveEntityWithWarning(self, "ore_laser_level", self.MinMiningTheory)
		return
	end

	local miningmod = 1
	if ply.sa_data.faction_name == "miners" then
		miningmod = 1.33
	elseif ply.sa_data.faction_name == "corporation" then
		miningmod = 1.11
	end
	local level = self:GetPlayerLevel(ply)
	self:SetNWInt("level", level)

	local energycost = ply.sa_data.research.mining_energy_efficiency[1] * 50
	if (energycost > self.EnergyBase * 0.75) then
		energycost = self.EnergyBase * 0.75
	end
	self.consume = self.EnergyBase - energycost
	self.yield = math.floor((self.YieldOffset + (level * self.YieldIncrement)) * miningmod)
end

function ENT:TurnOn()
	if self.Active == 0 then
		self.Active = 1
		self.lasersound:Play()
		if WireAddon then
			Wire_TriggerOutput(self, "On", 1)
		end
		self:SetOOO(1)
		self:SetNWBool("o", true)
	end
end

function ENT:TurnOff()
	if self.Active == 1 then
		self.Active = 0
		self.lasersound:Stop()
		if WireAddon then
			Wire_TriggerOutput(self, "On", 0)
			Wire_TriggerOutput(self, "Output", 0)
		end
		self:SetOOO(0)
		self:SetNWBool("o", false)
	end
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)
	self.lasersound:Stop()
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		self:SetActive(value)
	end
end

function ENT:Think()
	BaseClass.Think(self)

	if self.Active == 1 then
		if self:ConsumeResource("energy", self.consume) < self.consume then
			self:TurnOff()
			Wire_TriggerOutput(self, "Output", 0)
		else
			SA.Ore.Mine(self)
			Wire_TriggerOutput(self, "Output", self.yield)
		end
	end

	self:NextThink(CurTime() + 1)
	return true
end
