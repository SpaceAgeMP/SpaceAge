AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD.AddResource(self, "energy", 0, 0)
	self.Active = 0
	if (WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "Result" })
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(1)
		phys:Wake()
	end
	self.consume = 25
	self.beamlength = 3000
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		if ( RD.GetResourceAmount(self, "energy") < self.consume ) then
			self:TurnOff()
			return
		end
		self:SetOOO(1)
		self:SetNWBool("o",true)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self:SetOOO(0)
		self:SetNWBool("o",false)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

local function ScanRoid(ent)
	local pos = ent:GetPos()
	local up = ent:GetAngles():Up()
	local tr = util.TraceLine( {start = pos + (up * ent:OBBMaxs().z), endpos = pos + (up * ent.beamlength),filter = { ent }} )
	local hitent = tr.Entity
	if ( not hitent ) then return end
	if hitent.IsAsteroid or hitent.IsCrystal then
		ent:UpdateWireOutput(math.floor((hitent.health / hitent.maxhealth) * 10000) / 100)
	elseif hitent.IsOreStorage then
		ent:UpdateWireOutput(math.floor((RD.GetResourceAmount(hitent, "ore") / RD.GetNetworkCapacity(hitent, "ore")) * 10000) / 100)
	else
		ent:UpdateWireOutput(0)
	end
end

function ENT:UpdateWireOutput(result)
	Wire_TriggerOutput(self, "Result", result)
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then
			if ( RD.GetResourceAmount(self, "energy") >= self.consume ) then
				RD.ConsumeResource(self, "energy", self.consume)
				ScanRoid(self)
			else
				self:TurnOff()
			end
	end
	self:NextThink(CurTime() + 1)
	return true
end
