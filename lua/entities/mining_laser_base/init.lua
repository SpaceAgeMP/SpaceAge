AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	local myPl = self:GetTable().Founder
	if myPl and myPl:IsPlayer() then
		myPl:Kill()
		self:Remove()
	end

	self:SetModel(self.LaserModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end

	RD.AddResource(self, "energy", 0)

	self.Inputs = Wire_CreateInputs(self, { "Activate" })
	self.Outputs = Wire_CreateOutputs(self, { "Active", "Mineral", "Cycle %" })

	self:SetNWBool("m", false)

	self.nextcycle = CurTime()
	self.nextpull = CurTime()
	self.pulls = 0
	self.InputActive = false
	self.percent = 0
end

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("mining_laser_base")
	ent:SetPos(tr.HitPos + tr.HitNormal * 100)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:DoRes()
	local energyneed = self.LaserConsume / self.LaserCycle
	if (RD.GetResourceAmount(self, "energy") >= energyneed) then
		self.energytofire = true
		RD.ConsumeResource(self, "energy", energyneed)
	 	return true
	else
		self.energytofire = false
		return false
	end
end

function ENT:Mine()

	if (self.pulls == 0) then

		local ent = self:FindRoid()
		self.roidtomine = ent

		if not ent then	--No asteroids found
			self:SetNWBool("m", false)
			self:SetNWEntity("r", nil)
			self.nextcycle = CurTime()
			self.nextpull = CurTime()
			self.pulls = 0
			self.nextpull = CurTime() + 1
			Wire_TriggerOutput(self, "Active", 0)
			Wire_TriggerOutput(self, "Mineral", 0)
			return false
		end

		self:SetNWBool("m", true)
		self:SetNWEntity("r", ent:EntIndex())
		self.mining = true

		self.nextcycle = CurTime() + self.LaserCycle
	end

	local ent = self.roidtomine

	if not ent:IsValid() then	--Did it die while we were mining it?
			self:SetNWBool("m", false)
			self:SetNWEntity("r", nil)
			self.nextcycle = CurTime()
			self.nextpull = CurTime()
			self.pulls = 0
			self.nextpull = CurTime() + 1
			Wire_TriggerOutput(self, "Active", 0)
			Wire_TriggerOutput(self, "Mineral", 0)
			return false
	end
	--local range = (ent:GetPos() - self:GetPos()):Length()
	local range = (ent:NearestPoint(self:GetPos()) - self:GetPos()):Length()
	if range > self.LaserRange  then	--Did it go out of mining range?
			self:SetNWBool("m", false)
			self:SetNWEntity("r", nil)
			self.nextcycle = CurTime()
			self.nextpull = CurTime()
			self:ConsumeOre(ent, false, self.pulls)
			self.pulls = 0
			self.nextpull = CurTime() + 1
			Wire_TriggerOutput(self, "Active", 0)
			Wire_TriggerOutput(self, "Mineral", 0)
			return false
	end
	self:DoRes()

	if self.energytofire == true then
		self.nextpull = CurTime() + 1
		self:CalcOre(ent)
		Wire_TriggerOutput(self, "Active", 1)
		Wire_TriggerOutput(self, "Mineral", ent.MineralName)
	else
		self:SetNWBool("m", false)
		self:SetNWEntity("r", nil)
		self.nextcycle = CurTime()
		self.nextpull = CurTime()
		self:ConsumeOre(ent, false, self.pulls)
		self.pulls = 0
		self.nextpull = CurTime() + 1
		Wire_TriggerOutput(self, "Active", 0)
		Wire_TriggerOutput(self, "Mineral", 0)
		return false
	end
end

--Some Ore volumes could be so large that a full cycle is needed to pull just 1 unit, should the cycle break to soon, you would lose this unit
function ENT:CalcOre(ent) --Figures out how much ore to comsume once a cycle is ended or broken

	self.pulls = self.pulls + 1

	local toextract = (((self.LaserExtract / self.LaserCycle) * self.pulls) / ent.MineralVol)

	if toextract > ent.MineralAmount then
		self:ConsumeOre(ent, true, self.pulls)
		self.pulls = 0
		Wire_TriggerOutput(self, "Active", 0)
		Wire_TriggerOutput(self, "Mineral", 0)
		self:SetNWBool("m", false)
		self:SetNWEntity("r", nil)
		return
	end

	if self.pulls >= self.LaserCycle then
		self:ConsumeOre(ent, false, self.pulls)
		self.pulls = 0
	end
end

function ENT:ConsumeOre(ent, takeall, pulls) --Comsumes the Ore

	if takeall then
		ent.MineralAmount = ent.MineralAmount - ent.MineralAmount
		RD.SupplyResource(self, ent.MineralName, math.floor(ent.MineralAmount))
		self.pulls = 0
		return
	else
		local toextract = math.floor(((self.LaserExtract / self.LaserCycle) * self.pulls) / ent.MineralVol)

		ent.MineralAmount = ent.MineralAmount - toextract
		RD.SupplyResource(self, ent.MineralName, toextract)
		self.pulls = 0
	end
	if self.InputActive == false then
		self:SetNWBool("m", false)
		self:SetNWEntity("r", nil)
		Wire_TriggerOutput(self, "Active", 0)
		Wire_TriggerOutput(self, "Mineral", 0)
	end
end

function ENT:FindRoid()

	local find = ents.FindInSphere(self:GetPos(), self.LaserRange)
	local dist = {}
	local roids = {}

	for _, i in pairs(find) do
		if string.find(i:GetClass(), "asteroid") then
			local range = (i:NearestPoint(self:GetPos()) - self:GetPos()):Length()
			roids[range] = i
			table.insert(dist, range)
		end
	end

	table.sort(dist)  --Sort ranges from lowest to highest

	for _, d in pairs(dist) do  --This should take the first value (lowest range) and get the entity it belongs to off the roids table
		return roids[d]
	end
end

function ENT:OnRemove()

end

function ENT:Think()
	self.BaseClass.Think(self)

	self.percent = math.Round((self.pulls / self.LaserCycle) * 100)
	self:SetOverlayText(self.PrintName .. "\n" .. "Cycle: " .. self.percent .. "%")

	Wire_TriggerOutput(self, "Cycle %", self.percent)

	if self.InputActive and self.nextpull < CurTime() then
		self:Mine()
	elseif self.pulls < self.LaserCycle and self.pulls > 0 then
		if self.nextpull < CurTime() then
			self:Mine()
		end
	end

end

function ENT:TriggerInput(iname, value)
	if (iname == "Activate") then
		if value == 1 then
			self.InputActive = true
			self:Mine()
		else
			self.InputActive = false
		end
	end
end


