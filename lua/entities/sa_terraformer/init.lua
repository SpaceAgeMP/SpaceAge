AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

DEFINE_BASECLASS("base_rd3_entity")

local SB = CAF.GetAddon("Spacebuild")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.Active = 0
	self.Stability = 1000
	self.FinalSpazzed = false
	self.State = 0
	self.StateTicks = 0
	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, {"On", "Stability", "State" })
	else
		self.Inputs = {{ Name = "On" }}
	end
	self:RegisterNonStorageDevice(self)
	local pl = self:GetTable().Founder
	if pl and pl:IsValid() and pl:IsPlayer() and pl.sa_data.score and pl.sa_data.score < 100000000 then
		pl:AddHint("You need 100.000.000 score to spawn a terraformer", NOTIFY_ERROR, 5)
		self:Remove()
		return
	end
end

function ENT:ChangeStability(change)
	if change == 0 then return end
	self.Stability = self.Stability + change
	if (self.Stability > 1000) then
		self.Stability = 1000
	end
	if WireAddon ~= nil then Wire_TriggerOutput(self, "Stability", self.Stability) end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		BaseClass.SetActive(self, value)
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		if (not self.environment) or self.environment.IsProtected or self.environment == SB.GetSpace() then return end
		self:EmitSound("apc_engine_start")
		self.Active = 1
		if WireAddon ~= nil then
			Wire_TriggerOutput(self, "On", self.Active)
			self:SetState(0)
		end
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self:StopSound("apc_engine_start")
		self:EmitSound("apc_engine_stop")
		self.Active = 0
		if WireAddon ~= nil then
			Wire_TriggerOutput(self, "On", self.Active)
			self:SetState(0)
		end
		self:SetOOO(0)
	end
end

function ENT:SetState(myState)
	if (self.State ~= myState) then
		self.State = myState
		self.StateTicks = 0
		Wire_TriggerOutput(self, "State", self.State)
	end
end

function ENT:OnTakeDamage(DmgInfo)
	if self.Shield then
		self.Shield:ShieldDamage(DmgInfo:GetDamage())
		return
	end
	self:ChangeStability(-DmgInfo:GetDamage())
end

function ENT:Repair()
	BaseClass.Repair(self)
	self:SetColor(color_white)
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct(self, true)
	end
end

function ENT:OnRemove()
	self:StopSound("apc_engine_start")
	BaseClass.OnRemove(self)
end

function ENT:Think()
	BaseClass.Think(self)
	self.StateTicks = self.StateTicks + 1
	if (self.Active == 1) then
		if self.environment.IsProtected or (not self.environment:IsPlanet()) or self.environment == SB.GetSpace() then
			self.TurnOff()
			return
		end
		if self.Stability > 0 then
			SA.Terraformer.Run(self)
		else
			SA.Terraformer.SpazzOut(self, false)
		end
	else
		self:ChangeStability(math.random(1, 3))
		if (self.Stability <= -300) then
			SA.Terraformer.SpazzOut(self, false)
		end
	end
	self:NextThink(CurTime() + 1)
	return true
end
